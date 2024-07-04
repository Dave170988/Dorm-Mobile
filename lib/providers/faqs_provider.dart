import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FAQsNotifier extends ChangeNotifier {
  List<DocumentSnapshot> faqDocs = [];

  void setFAQDocs(List<DocumentSnapshot> docs) {
    faqDocs = docs;
    notifyListeners();
  }
}

final faqsProvider = ChangeNotifierProvider((ref) => FAQsNotifier());
