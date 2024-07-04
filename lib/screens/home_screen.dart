import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormbnb/providers/loading_provider.dart';
import 'package:dormbnb/utils/date_util.dart';
import 'package:dormbnb/utils/future_util.dart';
import 'package:dormbnb/utils/navigator_util.dart';
import 'package:dormbnb/widgets/app_bar_widget.dart';
import 'package:dormbnb/widgets/app_bottom_nav_bar_widget.dart';
import 'package:dormbnb/widgets/custom_padding_widgets.dart';
import 'package:dormbnb/widgets/custom_text_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../providers/settle_payment_provider.dart';
import '../utils/color_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';

class RenterHomeScreen extends ConsumerStatefulWidget {
  const RenterHomeScreen({super.key});

  @override
  ConsumerState<RenterHomeScreen> createState() => _RenterHomeScreenState();
}

class _RenterHomeScreenState extends ConsumerState<RenterHomeScreen> {
  List<DocumentSnapshot> allDormDocs = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        allDormDocs = await getAllDormDocs(context);
        allDormDocs = allDormDocs.where((dormDoc) {
          final dormData = dormDoc.data() as Map<dynamic, dynamic>;
          return dormData[DormFields.isVerified];
        }).toList();
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error initializing home screen: $error')));
        ref.read(loadingProvider).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: appBarWidget(hasLeading: true),
        drawer: appDrawer(context, ref,
            userType: UserTypes.renter, currentPath: 'HOME'),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton:
            bottomFloatingActionNavigator(context, path: NavigatorRoutes.home),
        /*bottomNavigationBar:
            renterBottomNavBar(context, path: NavigatorRoutes.home),*/
        body: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _pendingPaymentRentalRequestsContainer(),
                dormsContainer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pendingPaymentRentalRequestsContainer() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(Collections.rentals)
          .where(RentalFields.renterID,
              isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where(RentalFields.status, isEqualTo: RentalStatus.pendingPayment)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData ||
            snapshot.hasError) return snapshotHandler(snapshot);
        List<DocumentSnapshot> availableRentalRequests = snapshot.data!.docs;
        return availableRentalRequests.isNotEmpty
            ? all20Pix(
                child: ExpansionTile(
                  title: blackHelveticaBold('PENDING PAYMENTS', fontSize: 18),
                  backgroundColor: CustomColors.pearlWhite,
                  collapsedBackgroundColor: CustomColors.pearlWhite,
                  iconColor: Colors.black,
                  collapsedIconColor: Colors.black,
                  collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableRentalRequests.length,
                        itemBuilder: (context, index) {
                          return rentalRequestEntry(
                              availableRentalRequests[index]);
                        })
                  ],
                ),
              )
            : Container();
      },
    );
  }

  Widget rentalRequestEntry(DocumentSnapshot rentalDoc) {
    final rentalData = rentalDoc.data() as Map<dynamic, dynamic>;
    String ownerID = rentalData[RentalFields.ownerID];
    String dormID = rentalData[RentalFields.dormID];
    DateTime dateStart =
        (rentalData[RentalFields.dateStart] as Timestamp).toDate();
    return FutureBuilder(
        future: getThisUserDoc(ownerID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData ||
              snapshot.hasError) return snapshotHandler(snapshot);
          final userData = snapshot.data!.data() as Map<dynamic, dynamic>;
          String formattedName =
              '${userData[UserFields.firstName]} ${userData[UserFields.lastName]}';
          return FutureBuilder(
            future: getThisDormDoc(dormID),
            builder: (context, dormSnapshot) {
              if (dormSnapshot.connectionState == ConnectionState.waiting ||
                  !dormSnapshot.hasData ||
                  dormSnapshot.hasError) return snapshotHandler(dormSnapshot);
              final dormData =
                  dormSnapshot.data!.data() as Map<dynamic, dynamic>;
              String name = dormData[DormFields.name];
              num monthlyRent = dormData[DormFields.monthlyRent];
              List<dynamic> dormImageURLs = dormData[DormFields.dormImageURLs];

              return Container(
                decoration: BoxDecoration(border: Border.all()),
                padding: EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: CustomColors.midnightBlue)),
                          child: Image.network(
                            dormImageURLs.first,
                            height: 100,
                            fit: BoxFit.fitHeight,
                          )),
                    ),
                    Gap(10),
                    Flexible(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          blackHelveticaBold(name),
                          blackHelveticaRegular('Owner: $formattedName'),
                          Gap(21),
                          blackHelveticaBold(
                              'PHP ${formatPrice(monthlyRent.toDouble())}'),
                          blackHelveticaRegular(
                              'Rental Payment Duration:\n${DateFormat('MMM dd, yyyy').format(dateStart)} - ${DateFormat('MMM dd, yyyy').format(addMonths(dateStart, 1))}',
                              textAlign: TextAlign.left),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(settlePaymentProvider)
                                        .resetProvider();
                                    NavigatorRoutes.renterSettlePayment(context,
                                        rentalID: rentalDoc.id);
                                  },
                                  child: whiteHelveticaBold('SETTLE PAYMENT')),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  Widget dormsContainer() {
    return all10Pix(
      child: allDormDocs.isNotEmpty
          ? Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  blackHelveticaBold('AVAILABLE DORMS', fontSize: 24)
                ]),
                Gap(20),
                Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.spaceAround,
                    spacing: 10,
                    //runSpacing: 20,
                    children: allDormDocs
                        .map((dormDoc) => dormGridEntry(dormDoc))
                        .toList()),
              ],
            )
          : Center(
              child: blackHelveticaBold('NO DORMS AVAILABLE'),
            ),
    );
  }

  Widget dormGridEntry(DocumentSnapshot dormDoc) {
    final dormData = dormDoc.data() as Map<dynamic, dynamic>;
    List<dynamic> dormImageURLs = dormData[DormFields.dormImageURLs];
    String name = dormData[DormFields.name];
    String address = dormData[DormFields.address];
    num monthlyRent = dormData[DormFields.monthlyRent];
    return InkWell(
      onTap: () =>
          NavigatorRoutes.renterSelectedDorm(context, dormID: dormDoc.id),
      child: Container(
        width: 170,
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          image: NetworkImage(dormImageURLs.first),
                          fit: BoxFit.cover)),
                ),
                Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(50)),
                      child: Row(
                        children: [
                          yellowStarFilled(),
                          yellowStarFilled(),
                          yellowStarFilled(),
                          yellowStarFilled(),
                          Icon(Icons.star_outline,
                              color: Color.fromARGB(255, 216, 196, 41)),
                        ],
                      ),
                    )),
                Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(50)),
                        child: Icon(Icons.favorite_outline,
                            color: Colors.white, size: 20)))
              ],
            ),
            all10Pix(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 150,
                      child: blackHelveticaBold(name,
                          fontSize: 18,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis)),
                  blackHelveticaRegular(address,
                      fontSize: 12,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis),
                  Gap(4),
                  blackHelveticaBold(
                      'PHP ${formatPrice(monthlyRent.toDouble())}')
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
