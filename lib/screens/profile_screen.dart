import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormbnb/utils/color_util.dart';
import 'package:dormbnb/utils/navigator_util.dart';
import 'package:dormbnb/widgets/app_bottom_nav_bar_widget.dart';
import 'package:dormbnb/widgets/app_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../providers/loading_provider.dart';
import '../providers/user_data_provider.dart';
import '../utils/future_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String formattedName = '';
  List<DocumentSnapshot> rentalDocs = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);

        final userDoc = await getCurrentUserDoc();
        final userData = userDoc.data() as Map<dynamic, dynamic>;
        formattedName =
            '${userData[UserFields.firstName]} ${userData[UserFields.lastName]}';
        ref
            .read(userDataProvider)
            .setProfileImage(userData[UserFields.profileImageURL]);
        rentalDocs = await getUserRentalDocs();
        ref.read(loadingProvider.notifier).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting user profile: $error')));
        ref.read(loadingProvider.notifier).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
      appBar: appBarWidget(hasLeading: true, actions: [
        IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(NavigatorRoutes.editProfile),
            icon: const Icon(Icons.edit))
      ]),
      drawer: appDrawer(context, ref,
          userType: UserTypes.renter,
          currentPath: NavigatorRoutes.renterProfile),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: bottomFloatingActionNavigator(context,
          path: NavigatorRoutes.renterProfile),
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading,
          Column(
            children: [_basicProfileDetails(), Divider(), _rentalHistory()],
          )),
    );
  }

  Widget _basicProfileDetails() {
    return all20Pix(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildProfileImageWidget(
              profileImageURL: ref.read(userDataProvider).profileImageURL,
              radius: MediaQuery.of(context).size.width * 0.14),
          all10Pix(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              blackHelveticaBold(formattedName, fontSize: 20),
              //blackInterRegular('Contact Number')
            ],
          )),
        ],
      ),
    );
  }

  Widget _rentalHistory() {
    return Container(
      width: MediaQuery.of(context).size.width - 10,
      decoration: BoxDecoration(
          color: CustomColors.pearlWhite,
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(children: [blackHelveticaBold('RENTAL HISTORY', fontSize: 20)]),
          Gap(8),
          rentalDocs.isNotEmpty
              ? ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: rentalDocs.length,
                  separatorBuilder: (context, index) => Gap(10),
                  itemBuilder: (context, index) {
                    return rentalHistoryEntry(rentalDocs[index]);
                  })
              : blackHelveticaBold('You have not yet rented any dormitories.')
        ],
      ),
    );
  }

  Widget rentalHistoryEntry(DocumentSnapshot rentalDoc) {
    final rentalData = rentalDoc.data() as Map<dynamic, dynamic>;
    String dormID = rentalData[RentalFields.dormID];
    String status = rentalData[RentalFields.status];
    DateTime dateStart =
        (rentalData[RentalFields.dateStart] as Timestamp).toDate();
    DateTime dateEnd = (rentalData[RentalFields.dateEnd] as Timestamp).toDate();
    num monthsRequested = rentalData[RentalFields.monthsRequested];
    return FutureBuilder(
      future: getThisDormDoc(dormID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData ||
            snapshot.hasError) return snapshotHandler(snapshot);
        final dormData = snapshot.data!.data() as Map<dynamic, dynamic>;
        List<dynamic> dormImageURLs = dormData[DormFields.dormImageURLs];
        String name = dormData[DormFields.name];
        String address = dormData[DormFields.address];
        num monthlyRent = dormData[DormFields.monthlyRent];
        return Container(
          decoration: BoxDecoration(
              color: CustomColors.pearlWhite,
              borderRadius: BorderRadius.circular(5)),
          padding: EdgeInsets.all(10),
          child: Row(
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(border: Border.all()),
                child: Image.network(
                  dormImageURLs.first,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              Gap(10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  blackHelveticaBold(name),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 185,
                    child: blackHelveticaRegular(address,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Gap(10),
                  blackHelveticaBold(
                      'Monthyl Rent: PHP ${formatPrice(monthlyRent.toDouble())}'),
                  blackHelveticaRegular(
                      'Rental Period: $monthsRequested months'),
                  blackHelveticaRegular(
                      '${DateFormat('MMM dd, yyyy').format(dateStart)} - ${DateFormat('MMM dd, yyyy').format(dateEnd)}'),
                  Gap(10),
                  blackHelveticaBold(status)
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
