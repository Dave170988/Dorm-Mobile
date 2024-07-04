import 'package:flutter/material.dart';

void displayDeleteEntryDialog(BuildContext context,
    {required String message,
    String deleteWord = 'Delete',
    required Function deleteEntry}) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteEntry();
              },
              child: Text(deleteWord),
            ),
          ],
        );
      });
}
