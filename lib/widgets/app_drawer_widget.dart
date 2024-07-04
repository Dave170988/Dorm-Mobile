import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../utils/color_util.dart';
import '../utils/navigator_util.dart';
import 'custom_text_widgets.dart';

Drawer appDrawer(BuildContext context, WidgetRef ref,
    {required String userType,
    required String currentPath,
    Color backgroundColor = CustomColors.dirtyWhite}) {
  return Drawer(
    backgroundColor: backgroundColor,
    child: Column(
      children: [
        Flexible(
          flex: 1,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const Gap(20),
              _home(context,
                  userType: userType,
                  currentPath: currentPath,
                  thisPath: 'HOME'),
              _faq(context,
                  currentPath: currentPath, thisPath: NavigatorRoutes.faqs),
            ],
          ),
        ),
        _logOutButton(context)
      ],
    ),
  );
}

Widget _home(BuildContext context,
    {required String userType,
    required String currentPath,
    required String thisPath}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: ListTile(
      leading: const Icon(Icons.home, color: Colors.black),
      title: blackHelveticaBold('HOME'),
      onTap: () {
        Navigator.of(context).pop();
        if (currentPath == thisPath) {
          return;
        }
        Navigator.of(context).pushReplacementNamed(NavigatorRoutes.home);
      },
    ),
  );
}

Widget _faq(BuildContext context,
    {required String currentPath, required String thisPath}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: ListTile(
      leading: const Icon(Icons.question_mark, color: Colors.black),
      title: blackHelveticaBold('FAQ'),
      onTap: () {
        Navigator.of(context).pop();
        if (currentPath == thisPath) {
          return;
        }
        Navigator.of(context).pushNamed(NavigatorRoutes.faqs);
      },
    ),
  );
}

Widget _logOutButton(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Container(
      decoration: BoxDecoration(
          color: CustomColors.pearlWhite,
          border: Border.all(color: CustomColors.pearlWhite),
          borderRadius: BorderRadius.circular(50)),
      child: ListTile(
        leading: const Icon(Icons.logout, color: CustomColors.midnightBlue),
        title: Center(child: blackHelveticaBold('LOG-OUT')),
        onTap: () {
          FirebaseAuth.instance.signOut().then((value) {
            Navigator.popUntil(context, (route) => route.isFirst);
          });
        },
      ),
    ),
  );
}
