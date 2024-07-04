import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class SettlePaymentNotifier extends ChangeNotifier {
  File? paymentImage;
  String selectedPaymentMethod = '';

  Future setPaymentImage() async {
    ImagePicker imagePicker = ImagePicker();
    final selectedXFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedXFile != null) {
      paymentImage = File(selectedXFile.path);
      notifyListeners();
    }
  }

  void setSelectedPaymentMethod(String paymentMethod) {
    selectedPaymentMethod = paymentMethod;
    notifyListeners();
  }

  void resetProvider() {
    selectedPaymentMethod = '';
    paymentImage = null;
    notifyListeners();
  }
}

final settlePaymentProvider = ChangeNotifierProvider<SettlePaymentNotifier>(
    (ref) => SettlePaymentNotifier());
