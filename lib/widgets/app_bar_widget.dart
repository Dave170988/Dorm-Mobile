import 'package:dormbnb/utils/color_util.dart';
import 'package:dormbnb/utils/string_util.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget appBarWidget(
    {bool hasLeading = false, List<Widget>? actions}) {
  return AppBar(
      automaticallyImplyLeading: hasLeading,
      title: Image.asset(
        ImagePaths.logo,
        scale: 10,
      ),
      centerTitle: true,
      iconTheme: const IconThemeData(color: CustomColors.midnightBlue),
      actionsIconTheme: const IconThemeData(color: CustomColors.midnightBlue),
      actions: actions);
}
