import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormbnb/providers/dorms_provider.dart';
import 'package:dormbnb/providers/proof_of_enrollment_provider.dart';
import 'package:dormbnb/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../utils/color_util.dart';
import '../utils/future_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import 'custom_button_widgets.dart';
import 'custom_padding_widgets.dart';
import 'custom_text_field_widget.dart';
import 'custom_text_widgets.dart';

Widget stackedLoadingContainer(
    BuildContext context, bool isLoading, Widget child) {
  return Stack(children: [
    child,
    if (isLoading)
      Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withOpacity(0.5),
          child: const Center(child: CircularProgressIndicator()))
  ]);
}

Widget switchedLoadingContainer(bool isLoading, Widget child) {
  return isLoading ? const Center(child: CircularProgressIndicator()) : child;
}

Widget authenticationIcon(BuildContext context, {required IconData iconData}) {
  return Container(
      width: MediaQuery.of(context).size.width * 0.45,
      height: 150,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: CustomColors.tangerine),
      child: Transform.scale(
          scale: 5, child: Icon(iconData, color: Colors.white)));
}

Widget loginFieldsContainer(BuildContext context, WidgetRef ref,
    {required TextEditingController emailController,
    required TextEditingController passwordController}) {
  return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: CustomColors.murkyGreen.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          blackHelveticaBold('LOG-IN',
              fontSize: 40, fontStyle: FontStyle.italic),
          emailAddressTextField(emailController: emailController),
          passwordTextField(
              label: 'Password', passwordController: passwordController),
          loginButton(
              onPress: () => logInUser(context, ref,
                  emailController: emailController,
                  passwordController: passwordController)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamed(NavigatorRoutes.forgotPassword),
                  child: blackHelveticaRegular('Forgot Password?',
                      fontSize: 12, textDecoration: TextDecoration.underline))
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            blackHelveticaRegular('Don\'t have an account?', fontSize: 12),
            TextButton(
                onPressed: () {
                  ref.read(proofOfEnrollmentProvider).resetProofOfEnrollment();
                  Navigator.of(context)
                      .pushNamed(NavigatorRoutes.renterRegister);
                },
                child: blackHelveticaRegular('Create an account',
                    fontSize: 12, textDecoration: TextDecoration.underline))
          ])
        ],
      ));
}

Widget registerFieldsContainer(BuildContext context, WidgetRef ref,
    {required String userType,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController}) {
  return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: CustomColors.midnightBlue.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Gap(50),
          whiteHelveticaBold('RENTER REGISTRATION',
              fontSize: 28, fontStyle: FontStyle.italic),
          emailAddressTextField(
              emailController: emailController, isBlack: false),
          passwordTextField(
              label: 'Password',
              passwordController: passwordController,
              isBlack: false),
          passwordTextField(
              label: 'Confirm Password',
              passwordController: confirmPasswordController,
              isBlack: false),
          Divider(),
          regularTextField(
              label: 'First Name',
              textController: firstNameController,
              isBlack: false),
          regularTextField(
              label: 'Last Name',
              textController: lastNameController,
              isBlack: false),
          Divider(),
          studentIDUploadWidget(context, ref),
          Gap(20),
          proofOfEnrollmentUploadWidget(context, ref),
          Divider(),
          registerButton(
              onPress: () => registerNewUser(context, ref,
                  userType: userType,
                  emailController: emailController,
                  passwordController: passwordController,
                  confirmPasswordController: confirmPasswordController,
                  firstNameController: firstNameController,
                  lastNameController: lastNameController)),
        ],
      ));
}

Widget studentIDUploadWidget(BuildContext context, WidgetRef ref) {
  return Column(
    children: [
      Row(children: [whiteHelveticaBold('Student ID', fontSize: 18)]),
      if (ref.read(proofOfEnrollmentProvider).studentID != null)
        Image.file(ref.read(proofOfEnrollmentProvider).studentID!,
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.width * 0.3,
            fit: BoxFit.cover),
      ElevatedButton(
          onPressed: () => ref.read(proofOfEnrollmentProvider).setStudentID(),
          child: blackHelveticaBold('SELECT STUDENT ID', fontSize: 12))
    ],
  );
}

Widget proofOfEnrollmentUploadWidget(BuildContext context, WidgetRef ref) {
  return Column(
    children: [
      Row(children: [whiteHelveticaBold('Proof of Enrollment', fontSize: 18)]),
      if (ref.read(proofOfEnrollmentProvider).proofOfEnrollment != null)
        whiteHelveticaBold(
            ref.read(proofOfEnrollmentProvider).proofOfEnrollmentFileName,
            textDecoration: TextDecoration.underline),
      ElevatedButton(
          onPressed: () =>
              ref.read(proofOfEnrollmentProvider).setProofOfEnrollment(),
          child: blackHelveticaBold('SELECT PROOF OF ENROLLMENT', fontSize: 12))
    ],
  );
}

Widget emailAddressTextField(
    {required TextEditingController emailController, bool isBlack = true}) {
  return all10Pix(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isBlack
            ? blackHelveticaBold('Email Address', fontSize: 18)
            : whiteHelveticaBold('Email Address', fontSize: 18),
        CustomTextField(
            text: 'Email Address',
            controller: emailController,
            textInputType: TextInputType.emailAddress,
            displayPrefixIcon: const Icon(Icons.email)),
      ],
    ),
  );
}

Widget passwordTextField(
    {required String label,
    required TextEditingController passwordController,
    bool isBlack = true}) {
  return all10Pix(
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      isBlack
          ? blackHelveticaBold(label, fontSize: 18)
          : whiteHelveticaBold(label, fontSize: 18),
      CustomTextField(
          text: label,
          controller: passwordController,
          textInputType: TextInputType.visiblePassword,
          displayPrefixIcon: const Icon(Icons.lock)),
    ],
  ));
}

Widget regularTextField(
    {required String label,
    required TextEditingController textController,
    bool isBlack = true}) {
  return all10Pix(
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      isBlack
          ? blackHelveticaBold(label, fontSize: 18)
          : whiteHelveticaBold(label, fontSize: 18),
      CustomTextField(
          text: label,
          controller: textController,
          textInputType: TextInputType.name,
          displayPrefixIcon: null),
    ],
  ));
}

Widget numberTextField(
    {required String label, required TextEditingController textController}) {
  return all10Pix(
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      blackHelveticaBold(label, fontSize: 18),
      CustomTextField(
          text: label,
          controller: textController,
          textInputType: TextInputType.number,
          displayPrefixIcon: null),
    ],
  ));
}

Widget multiLineTextField(
    {required String label, required TextEditingController textController}) {
  return all10Pix(
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      blackHelveticaBold(label, fontSize: 18),
      CustomTextField(
          text: label,
          controller: textController,
          textInputType: TextInputType.multiline,
          displayPrefixIcon: null),
    ],
  ));
}

Widget selectedFileImage(BuildContext context, WidgetRef ref,
    {required File image}) {
  return all10Pix(
    child: Column(
      children: [
        Image.file(image,
            width: MediaQuery.of(context).size.width * 0.3,
            height: MediaQuery.of(context).size.width * 0.3,
            fit: BoxFit.cover),
        ElevatedButton(
            onPressed: () => ref.read(dormsProvider).removeDormFileImage(image),
            child: const Icon(Icons.delete, color: Colors.white))
      ],
    ),
  );
}

Widget proofOfOwnershipUploadWidget(BuildContext context, WidgetRef ref) {
  return SizedBox(
    width: double.infinity,
    child: Column(
      children: [
        Row(children: [blackHelveticaBold('Proof of Ownership', fontSize: 18)]),
        if (ref.read(dormsProvider).dormOwnership != null)
          Image.file(ref.read(dormsProvider).dormOwnership!,
              width: MediaQuery.of(context).size.width * 0.3),
        ElevatedButton(
            onPressed: () => ref.read(dormsProvider).setProofOfOwnership(),
            child:
                blackHelveticaBold('UPLOAD PROOF OF OWNERSHIP', fontSize: 12))
      ],
    ),
  );
}

Widget buildProfileImageWidget(
    {required String profileImageURL, double radius = 40}) {
  return Column(children: [
    profileImageURL.isNotEmpty
        ? CircleAvatar(
            radius: radius, backgroundImage: NetworkImage(profileImageURL))
        : CircleAvatar(
            radius: radius,
            backgroundColor: CustomColors.pearlWhite,
            child: Icon(
              Icons.person,
              size: radius * 1.5,
              color: Colors.black,
            )),
  ]);
}

Widget userNameContainer(String formattedName) {
  return vertical20Pix(
    child: Container(
      height: 50,
      color: CustomColors.pearlWhite,
      child: Center(
        child: all10Pix(
          child: Row(
            children: [blackHelveticaBold(formattedName, fontSize: 20)],
          ),
        ),
      ),
    ),
  );
}

Widget yellowStarFilled({double size = 20}) {
  return Icon(Icons.star, color: Color.fromARGB(255, 216, 196, 41), size: size);
}

Widget snapshotHandler(AsyncSnapshot snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator());
  } else if (!snapshot.hasData) {
    return const Text('No data found');
  } else if (snapshot.hasError) {
    return Text('Error gettin data: ${snapshot.error.toString()}');
  }
  return Container();
}

Widget welcomeWidgets(WidgetRef ref,
    {required String userType,
    Color containerColor = CustomColors.midnightBlue}) {
  return SizedBox(
    width: double.infinity,
    child: Column(
      children: [
        all10Pix(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            blackHelveticaBold('WELCOME,\n$userType', fontSize: 30),
            buildProfileImageWidget(
                profileImageURL: ref.read(userDataProvider).profileImageURL)
          ]),
        ),
        Container(height: 15, color: containerColor)
      ],
    ),
  );
}

Widget userRecordEntry(BuildContext context, WidgetRef ref,
    {required DocumentSnapshot userDoc,
    required Function onTap,
    bool displayButtons = false}) {
  final userData = userDoc.data() as Map<dynamic, dynamic>;
  String formattedName =
      '${userData[UserFields.firstName]} ${userData[UserFields.lastName]}';
  String profileImageURL = userData[UserFields.profileImageURL];
  return GestureDetector(
    onTap: () => onTap(),
    child: Container(
      decoration: BoxDecoration(
          color: CustomColors.pearlWhite,
          border: Border.all(color: Colors.black, width: 1)),
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        buildProfileImageWidget(profileImageURL: profileImageURL),
        const Gap(16),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: blackHelveticaBold(formattedName, fontSize: 20),
        )
      ]),
    ),
  );
}
