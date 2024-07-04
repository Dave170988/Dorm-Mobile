import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class DormsNotifier extends ChangeNotifier {
  List<DocumentSnapshot> dormDocs = [];
  List<dynamic> existingDormImages = [];
  List<File> dormImages = [];
  File? dormOwnership;

  void setDormDocs(List<DocumentSnapshot> dorms) {
    dormDocs = dorms;
    notifyListeners();
  }

  Future setDormNetworkImages(List<dynamic> networkImages) async {
    existingDormImages = networkImages;
    notifyListeners();
  }

  Future setDormImages() async {
    ImagePicker imagePicker = ImagePicker();
    final selectedXFiles = await imagePicker.pickMultiImage();
    for (var file in selectedXFiles) {
      dormImages.add(File(file.path));
    }
    notifyListeners();
  }

  void removeDormFileImage(File file) {
    print('removing');
    dormImages.remove(file);
    notifyListeners();
  }

  Future setProofOfOwnership() async {
    ImagePicker imagePicker = ImagePicker();
    final selectedXFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedXFile != null) {
      dormOwnership = File(selectedXFile.path);
      notifyListeners();
    }
  }

  void resetDorm() {
    existingDormImages.clear();
    dormImages.clear();
    dormOwnership = null;
    notifyListeners();
  }
}

final dormsProvider =
    ChangeNotifierProvider<DormsNotifier>((ref) => DormsNotifier());
