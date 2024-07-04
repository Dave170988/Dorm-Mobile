import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormbnb/utils/date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../providers/loading_provider.dart';
import '../providers/settle_payment_provider.dart';
import '../utils/color_util.dart';
import '../utils/future_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_widgets.dart';
import '../widgets/dropdown_widget.dart';

class RenterSettlePaymentScreen extends ConsumerStatefulWidget {
  final String rentalID;
  const RenterSettlePaymentScreen({super.key, required this.rentalID});

  @override
  ConsumerState<RenterSettlePaymentScreen> createState() =>
      _RenterSettlePaymentScreenState();
}

class _RenterSettlePaymentScreenState
    extends ConsumerState<RenterSettlePaymentScreen> {
  //  RENTAL VARIABLES
  num monthlyRent = 0;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  //  OWNER VARIABLES
  String formattedName = '';

  //  VEHICLE VARIABLES
  String name = '';
  List<dynamic> dormImageURLs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);

        //  Get Rental Data
        final rentalDoc = await getThisRentalDoc(widget.rentalID);
        final rentalData = rentalDoc.data() as Map<dynamic, dynamic>;
        startDate = (rentalData[RentalFields.dateStart] as Timestamp).toDate();
        endDate = (rentalData[RentalFields.dateEnd] as Timestamp).toDate();

        //  Get Owner Data
        String ownerID = rentalData[RentalFields.ownerID];
        final ownerDoc = await getThisUserDoc(ownerID);
        final ownerData = ownerDoc.data() as Map<dynamic, dynamic>;
        formattedName =
            '${ownerData[UserFields.firstName]} ${ownerData[UserFields.lastName]}';

        //  Get Vehicle Data
        String dormID = rentalData[RentalFields.dormID];
        final dormDoc = await getThisDormDoc(dormID);
        final dormData = dormDoc.data() as Map<dynamic, dynamic>;
        name = dormData[DormFields.name];
        dormImageURLs = dormData[DormFields.dormImageURLs];
        monthlyRent = dormData[DormFields.monthlyRent];
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting rental data: $error')));
        ref.read(loadingProvider).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(settlePaymentProvider);
    return Scaffold(
      appBar: appBarWidget(hasLeading: true),
      body: stackedLoadingContainer(
          context,
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
            child: all10Pix(
                child: Column(
              children: [_settleRentHeader(), Divider(), paymentWidgets()],
            )),
          )),
    );
  }

  Widget _settleRentHeader() {
    return Column(children: [
      blackHelveticaBold('SETTLE PENDING PAYMENT', fontSize: 26),
      vertical20Pix(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              blackHelveticaBold(name, fontSize: 20),
              blackHelveticaRegular('Owner: $formattedName'),
              blackHelveticaRegular(
                  'Rental Payment Duration:\n${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(addMonths(startDate, 1))}',
                  textAlign: TextAlign.left),
              const Gap(20),
              blackHelveticaBold(
                  'Total Rent: PHP ${formatPrice(monthlyRent.toDouble())}'),
            ]),
            if (dormImageURLs.isNotEmpty)
              Container(
                decoration: BoxDecoration(border: Border.all()),
                child: Image.network(
                  dormImageURLs.first,
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.width * 0.3,
                  fit: BoxFit.cover,
                ),
              )
          ],
        ),
      )
    ]);
  }

  Widget paymentWidgets() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: CustomColors.pearlWhite,
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.all(10),
          child: Column(children: [
            _paymentMethod(),
            if (ref
                .read(settlePaymentProvider)
                .selectedPaymentMethod
                .isNotEmpty)
              _uploadPayment(),
          ]),
        ),
        _checkoutButton()
      ],
    );
  }

  Widget _paymentMethod() {
    return all10Pix(
        child: Column(
      children: [
        Row(children: [blackHelveticaBold('PAYMENT METHOD')]),
        Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          child: dropdownWidget(
              ref.read(settlePaymentProvider).selectedPaymentMethod, (newVal) {
            ref.read(settlePaymentProvider).setSelectedPaymentMethod(newVal!);
          }, ['GCASH', 'PAYMAYA'], 'Select your payment method', false),
        )
      ],
    ));
  }

  Widget _uploadPayment() {
    return all10Pix(
        child: Column(
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                blackHelveticaBold('SEND YOUR PAYMENT HERE', fontSize: 18),
                if (ref.read(settlePaymentProvider).selectedPaymentMethod ==
                    'GCASH')
                  blackHelveticaBold('GCASH: +639221234567', fontSize: 14)
                else if (ref
                        .read(settlePaymentProvider)
                        .selectedPaymentMethod ==
                    'PAYMAYA')
                  blackHelveticaBold('PAYMAYA: +639221234567', fontSize: 14)
              ],
            )
          ],
        ),
        if (ref.read(settlePaymentProvider).paymentImage != null)
          Image.file(ref.read(settlePaymentProvider).paymentImage!,
              width: 200, height: 200),
        ElevatedButton(
            onPressed: () async =>
                ref.read(settlePaymentProvider).setPaymentImage(),
            child: blackHelveticaBold('UPLOAD PAYMENT IMAGE'))
      ],
    ));
  }

  Widget _checkoutButton() {
    return Container(
      child: ElevatedButton(
          onPressed:
              ref.read(settlePaymentProvider).selectedPaymentMethod.isEmpty ||
                      ref.read(settlePaymentProvider).paymentImage == null
                  ? null
                  : () => settlePendingPayment(context, ref,
                      rentalID: widget.rentalID, amount: monthlyRent),
          style: ElevatedButton.styleFrom(
              disabledBackgroundColor: CustomColors.pearlWhite),
          child: blackHelveticaBold('PROCESS PAYMENT')),
    );
  }
}
