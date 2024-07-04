import 'package:flutter/material.dart';

Padding all20Pix({required Widget child}) {
  return Padding(padding: const EdgeInsets.all(20), child: child);
}

Padding all10Pix({required Widget child}) {
  return Padding(padding: const EdgeInsets.all(10), child: child);
}

Padding vertical10Pix({required Widget child}) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10), child: child);
}

Padding vertical20Pix({required Widget child}) {
  return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20), child: child);
}

Padding horizontal5Pix({required Widget child}) {
  return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5), child: child);
}
