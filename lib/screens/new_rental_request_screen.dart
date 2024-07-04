import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../providers/loading_provider.dart';
import '../providers/rentals_provider.dart';
import '../utils/date_util.dart';
import '../utils/future_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class NewRentalRequestScreen extends ConsumerStatefulWidget {
  const NewRentalRequestScreen({super.key});

  @override
  ConsumerState<NewRentalRequestScreen> createState() =>
      _NewRentalRequestScreenState();
}

class _NewRentalRequestScreenState
    extends ConsumerState<NewRentalRequestScreen> {
  String name = '';
  String address = '';
  List<dynamic> dormImageURLs = [];
  num rentalPrice = 0;
  String formattedName = '';
  DateTime? startDate;
  String ownerID = '';
  int numberOfMonths = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        ref.read(loadingProvider).toggleLoading(true);
        final dormDoc =
            await getThisDormDoc(ref.read(rentalsProvider).selectedDormID);
        final dormData = dormDoc.data() as Map<dynamic, dynamic>;
        print(dormData);
        name = dormData[DormFields.name];
        address = dormData[DormFields.address];
        dormImageURLs = dormData[DormFields.dormImageURLs];
        rentalPrice = dormData[DormFields.monthlyRent];
        ownerID = dormData[DormFields.ownerID];
        final ownerDoc = await getThisUserDoc(ownerID);
        final ownerData = ownerDoc.data() as Map<dynamic, dynamic>;
        formattedName =
            '${ownerData[UserFields.firstName]} ${ownerData[UserFields.lastName]}';
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error getting this dorm data: $error')));
        ref.read(loadingProvider).toggleLoading(false);
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return Scaffold(
      appBar: appBarWidget(hasLeading: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: all10Pix(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: startDate != null
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.end,
          children: [
            if (startDate != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  blackHelveticaRegular('Total:', fontSize: 16),
                  blackHelveticaBold(
                      'PHP ${formatPrice((rentalPrice * numberOfMonths).toDouble())}',
                      fontSize: 20),
                ],
              ),
            if (!ref.read(loadingProvider).isLoading)
              ElevatedButton(
                  onPressed: startDate != null && numberOfMonths != 0
                      ? () => makeRentalRequest(context, ref,
                          ownerID: ownerID,
                          dormID: ref.read(rentalsProvider).selectedDormID,
                          dateStart: startDate!,
                          dateEnd: startDate!
                              .add(Duration(days: numberOfMonths * 30)),
                          monthsRequested: numberOfMonths)
                      : null,
                  child: whiteHelveticaBold('SEND\nRENTAL REQUEST')),
          ],
        ),
      ),
      body: stackedLoadingContainer(
          context,
          ref.read(loadingProvider).isLoading,
          SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              child: all10Pix(
                  child: Column(
                children: [
                  _newRentalHeader(),
                  Divider(),
                  _dateSelectionContainer(),
                  if (startDate != null) _durationSlider()
                ],
              )),
            ),
          )),
    );
  }

  Widget _newRentalHeader() {
    return Column(children: [
      blackHelveticaBold('NEW RENTAL REQUEST', fontSize: 26),
      vertical20Pix(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              blackHelveticaRegular(name, fontSize: 20),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: blackHelveticaRegular('Address: $address',
                      fontSize: 16, textAlign: TextAlign.left)),
              Gap(20),
              blackHelveticaBold(
                  'Rent: PHP ${formatPrice(rentalPrice.toDouble())}/month'),
              blackHelveticaRegular('Owner: $formattedName')
            ]),
            if (dormImageURLs.isNotEmpty)
              Container(
                decoration: BoxDecoration(border: Border.all()),
                child: Image.network(
                  dormImageURLs[0],
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

  Widget _dateSelectionContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        blackHelveticaBold('Start Date', fontSize: 24),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 60,
          child: ElevatedButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: startDate ?? DateTime.now().add(Duration(days: 7)),
                firstDate: DateTime.now().add(Duration(days: 7)),
                lastDate: DateTime(2100),
              );
              if (picked != null && picked != DateTime.now()) {
                setState(() {
                  startDate = picked;
                  numberOfMonths = 0;
                });
              }
            },
            child: whiteHelveticaBold(
                startDate != null
                    ? DateFormat('MMM dd, yyyy').format(startDate!)
                    : 'Select Start Date',
                fontSize: 20),
          ),
        ),
      ],
    );
  }

  Widget _durationSlider() {
    return vertical10Pix(
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(), borderRadius: BorderRadius.circular(10)),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(children: [
              blackHelveticaBold('Number of Months: $numberOfMonths',
                  fontSize: 20)
            ]),
            Slider(
              value: numberOfMonths.toDouble(),
              min: 0,
              max: 12,
              onChanged: (value) {
                setState(() {
                  numberOfMonths = value.toInt();
                });
              },
            ),
            if (numberOfMonths != 0)
              blackHelveticaBold(
                  'RENTAL END DATE: ${DateFormat('MMM dd, yyyy').format(addMonths(startDate!, numberOfMonths))}'),
          ],
        ),
      ),
    );
  }
}
