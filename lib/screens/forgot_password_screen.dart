import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../providers/loading_provider.dart';
import '../utils/color_util.dart';
import '../utils/future_util.dart';
import '../utils/string_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_text_widgets.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.white)),
        extendBodyBehindAppBar: true,
        body: stackedLoadingContainer(
            context,
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: Stack(children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(ImagePaths.bg),
                            fit: BoxFit.fill))),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: CustomColors.midnightBlue.withOpacity(0.8)),
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                          width: 400,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: CustomColors.murkyGreen),
                              color: CustomColors.pearlWhite.withOpacity(0.8)),
                          padding: EdgeInsets.all(20),
                          child: Image.asset(ImagePaths.logo, scale: 3)),
                      Gap(150),
                      Column(
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color:
                                      CustomColors.murkyGreen.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(20)),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  blackHelveticaBold('RESET PASSWORD',
                                      fontSize: 35,
                                      fontStyle: FontStyle.italic),
                                  emailAddressTextField(
                                      emailController: emailController),
                                  sendPasswordResetEmailButton(
                                      onPress: () => sendResetPasswordEmail(
                                          context, ref,
                                          emailController: emailController)),
                                ],
                              ))
                        ],
                      )
                    ],
                  ),
                ),
              ]),
            )),
      ),
    );
  }
}
