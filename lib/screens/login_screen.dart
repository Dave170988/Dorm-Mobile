import 'package:dormbnb/utils/color_util.dart';
import 'package:dormbnb/utils/string_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../providers/loading_provider.dart';
import '../widgets/custom_miscellaneous_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        //appBar: appBarWidget(),
        extendBodyBehindAppBar: true,
        body: stackedLoadingContainer(
            context,
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: Stack(
                children: [
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
                                color:
                                    CustomColors.pearlWhite.withOpacity(0.8)),
                            padding: EdgeInsets.all(20),
                            child: Image.asset(ImagePaths.logo, scale: 3)),
                        Gap(60),
                        loginFieldsContainer(context, ref,
                            emailController: emailController,
                            passwordController: passwordController)
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
