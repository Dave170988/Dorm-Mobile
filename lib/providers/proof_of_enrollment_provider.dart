import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProofOfEnrollmentNotifier extends ChangeNotifier {
  File? studentID;
  Uint8List? proofOfEnrollment;
  String proofOfEnrollmentFileName = '';

  void setStudentID() async {
    ImagePicker imagePicker = ImagePicker();
    final selectedXFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedXFile != null) {
      studentID = File(selectedXFile.path);
      notifyListeners();
    }
  }

  void setProofOfEnrollment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      proofOfEnrollment = await File(result.files.single.path!).readAsBytes();

      //print('proof file: ${proofOfEnrollment != null}');

      proofOfEnrollmentFileName = result.files.single.name;
      notifyListeners();
    }
  }

  void resetProofOfEnrollment() {
    studentID = null;
    proofOfEnrollment = null;
    proofOfEnrollmentFileName = '';
    notifyListeners();
  }
}

final proofOfEnrollmentProvider =
    ChangeNotifierProvider((ref) => ProofOfEnrollmentNotifier());
