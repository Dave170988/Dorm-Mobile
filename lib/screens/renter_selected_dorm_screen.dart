import 'package:dormbnb/utils/color_util.dart';
import 'package:dormbnb/widgets/app_bar_widget.dart';
import 'package:dormbnb/widgets/custom_miscellaneous_widgets.dart';
import 'package:dormbnb/widgets/custom_padding_widgets.dart';
import 'package:dormbnb/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/loading_provider.dart';
import '../providers/rentals_provider.dart';
import '../utils/future_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';

class SelectedDormScreen extends ConsumerStatefulWidget {
  final String dormID;
  const SelectedDormScreen({super.key, required this.dormID});

  @override
  ConsumerState<SelectedDormScreen> createState() => _SelectedDormScreenState();
}

class _SelectedDormScreenState extends ConsumerState<SelectedDormScreen> {
  //  DORM VARIABLES
  String name = '';
  String address = '';
  String description = '';
  num monthlyRent = 0;
  List<dynamic> imageURLs = [];
  bool isRentingThisVehicle = false;

  //  LOCAL VARIABLES
  int currentImageIndex = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        final dorm = await getThisDormDoc(widget.dormID);
        final dormData = dorm.data() as Map<dynamic, dynamic>;
        name = dormData[DormFields.name];
        address = dormData[DormFields.address];
        description = dormData[DormFields.description];
        imageURLs = dormData[DormFields.dormImageURLs];
        monthlyRent = dormData[DormFields.monthlyRent];
        isRentingThisVehicle = await isCurrentlyRentingThisDorm(widget.dormID);
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(SnackBar(
            content: Text('Error getting selected dorm detials: $error')));
        ref.read(loadingProvider).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
        appBar: appBarWidget(hasLeading: true),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: isRentingThisVehicle
              ? blackHelveticaBold('You have already requested this dorm',
                  fontSize: 16)
              : ElevatedButton(
                  onPressed: () {
                    ref.read(rentalsProvider).setSelectedDormID(widget.dormID);
                    Navigator.of(context)
                        .pushNamed(NavigatorRoutes.renterNewRental);
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: whiteHelveticaBold('BOOK', fontSize: 24)),
        ),
        body: switchedLoadingContainer(
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
                child: Column(children: [
              _dormHeader(),
              if (imageURLs.isNotEmpty) _dormImages(),
              _dormDescription(),
              _rating(),
              _dormReviews()
            ]))));
  }

  Widget _dormHeader() {
    return all10Pix(
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              blackHelveticaBold(name, fontSize: 24),
              blackHelveticaBold(address,
                  fontSize: 14, textAlign: TextAlign.left)
            ])),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: blackHelveticaBold('${formatPrice(monthlyRent.toDouble())}',
                fontSize: 30))
      ]),
    );
  }

  Widget _dormImages() {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          all10Pix(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 300,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                      image: NetworkImage(imageURLs[currentImageIndex]),
                      fit: BoxFit.cover)),
            ),
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                  onPressed: () {
                    if (currentImageIndex == 0) return;
                    setState(() {
                      currentImageIndex--;
                    });
                  },
                  icon: Icon(Icons.arrow_left, color: CustomColors.tangerine))),
          Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  onPressed: () {
                    if (currentImageIndex == imageURLs.length - 1) {
                      return;
                    }
                    setState(() {
                      currentImageIndex++;
                    });
                  },
                  icon: Icon(Icons.arrow_right, color: CustomColors.tangerine)))
        ],
      ),
    );
  }

  Widget _dormDescription() {
    return vertical10Pix(
      child: Container(
          width: double.infinity,
          decoration: BoxDecoration(border: Border.all()),
          padding: const EdgeInsets.all(4),
          child: blackHelveticaRegular(description, textAlign: TextAlign.left)),
    );
  }

  Widget _rating() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(50)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              yellowStarFilled(size: 40),
              yellowStarFilled(size: 40),
              yellowStarFilled(size: 40),
              yellowStarFilled(size: 40),
              Icon(Icons.star_outline,
                  color: Color.fromARGB(255, 216, 196, 41), size: 40),
            ],
          ),
          horizontal5Pix(
              child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: whiteHelveticaBold('MESSAGE')))
        ],
      ),
    );
  }

  Widget _dormReviews() {
    return all20Pix(
        child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: CustomColors.pearlWhite,
          borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.all(5),
      child: Column(
        children: [
          blackHelveticaBold('DORM REVIEWS', fontSize: 24),
          const Divider(color: Colors.black),
          blackHelveticaRegular('No Reviews Available')
        ],
      ),
    ));
  }
}
