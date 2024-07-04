import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/color_util.dart';
import 'custom_padding_widgets.dart';
import 'custom_text_widgets.dart';

/*Widget welcomeButton(BuildContext context,
    {required Function onPress,
    required IconData iconData,
    required String label}) {
  return all20Pix(
    child: Container(
      width: MediaQuery.of(context).size.width * 0.5,
      height: 120,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: ElevatedButton(
        onPressed: () => onPress(),
        style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.chryslerBlue,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20))),
        child: Column(
          children: [
            Expanded(
                child: Transform.scale(
                    scale: 4, child: Icon(iconData, color: Colors.white))),
            interText(label,
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)
          ],
        ),
      ),
    ),
  );
}*/

Widget loginButton({required Function onPress}) {
  return all10Pix(
      child: ElevatedButton(
          onPressed: () => onPress(), child: blackHelveticaBold('LOG-IN')));
}

Widget registerButton({required Function onPress}) {
  return all10Pix(
      child: ElevatedButton(
          onPressed: () => onPress(), child: blackHelveticaBold('REGISTER')));
}

Widget sendPasswordResetEmailButton({required Function onPress}) {
  return all10Pix(
      child: ElevatedButton(
          onPressed: () => onPress(),
          child: blackHelveticaBold('SEND PASSWORD\nRESET EMAIL')));
}

Widget forgotPasswordButton({required Function onPress}) {
  return TextButton(
      onPressed: () => onPress(),
      child: blackHelveticaBold('Forgot Password?',
          textDecoration: TextDecoration.underline));
}

Widget dontHaveAccountButton({required Function onPress}) {
  return TextButton(
      onPressed: () => onPress(),
      child: blackHelveticaBold('Don\'t have an account?',
          textDecoration: TextDecoration.underline));
}

Widget adminHomeButton(BuildContext context,
    {required String label, required int count, required Function onPress}) {
  return all10Pix(
      child: SizedBox(
          width: double.infinity,
          height: 75,
          child: ElevatedButton(
              onPressed: () => onPress(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.tangerine),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  blackHelveticaBold(label, fontSize: 20),
                  const Gap(5),
                  blackHelveticaBold('$count AVAILABLE')
                ],
              ))));
}
