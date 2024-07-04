import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/color_util.dart';
import '../utils/navigator_util.dart';
import 'custom_padding_widgets.dart';

Widget bottomFloatingActionNavigator(BuildContext context,
    {required String path}) {
  return all20Pix(
      child: Container(
    width: double.infinity,
    decoration: BoxDecoration(
        color: CustomColors.pearlWhite.withOpacity(0.90),
        borderRadius: BorderRadius.circular(40)),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
            onPressed: () => path == NavigatorRoutes.home
                ? null
                : Navigator.of(context).pushNamed(NavigatorRoutes.home),
            icon: Icon(path == NavigatorRoutes.home
                ? Icons.home
                : Icons.home_outlined)),
        IconButton(
            onPressed: () => path == NavigatorRoutes.messages ? null : () {},
            icon: Icon(Icons.favorite_border)),
        IconButton(
            onPressed: () => path == NavigatorRoutes.messages ? null : () {},
            icon: Icon(Icons.mail_outlined)),
        IconButton(
            onPressed: () => path == NavigatorRoutes.renterProfile
                ? null
                : Navigator.of(context)
                    .pushNamed(NavigatorRoutes.renterProfile),
            icon: Icon(path == NavigatorRoutes.renterProfile
                ? Icons.person
                : Icons.person_outlined)),
      ],
    ),
  ));
}

Widget renterBottomNavBar(BuildContext context, {required String path}) {
  return BottomAppBar(
    color: CustomColors.pearlWhite,
    height: 85,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Column(
            children: [
              IconButton(
                  onPressed: () => path == NavigatorRoutes.home
                      ? null
                      : Navigator.of(context).pushNamed(NavigatorRoutes.home),
                  icon: Icon(Icons.home,
                      color: path == NavigatorRoutes.home
                          ? CustomColors.midnightBlue
                          : CustomColors.pearlWhite)),
              Text('HOME',
                  style: GoogleFonts.inter(
                      fontSize: 8,
                      color: path == NavigatorRoutes.home
                          ? CustomColors.midnightBlue
                          : CustomColors.pearlWhite))
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Column(
            children: [
              IconButton(
                  onPressed: () =>
                      path == NavigatorRoutes.messages ? null : () {},
                  icon: Icon(Icons.room_outlined,
                      color: path == NavigatorRoutes.messages
                          ? CustomColors.midnightBlue
                          : CustomColors.pearlWhite)),
              Text('MESSAGES',
                  style: GoogleFonts.inter(
                      fontSize: 8,
                      color: path == NavigatorRoutes.messages
                          ? CustomColors.midnightBlue
                          : CustomColors.pearlWhite))
            ],
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: Column(
            children: [
              IconButton(
                  onPressed: () => path == NavigatorRoutes.renterProfile
                      ? null
                      : Navigator.of(context)
                          .pushNamed(NavigatorRoutes.renterProfile),
                  icon: Icon(Icons.person,
                      color: path == NavigatorRoutes.renterProfile
                          ? CustomColors.midnightBlue
                          : CustomColors.pearlWhite)),
              Text('PROFILE',
                  style: GoogleFonts.inter(
                      fontSize: 8,
                      color: path == NavigatorRoutes.renterProfile
                          ? CustomColors.midnightBlue
                          : CustomColors.pearlWhite))
            ],
          ),
        ),
      ],
    ),
  );
}
