//==============================================================================
//USERS=========================================================================
//==============================================================================
// ignore_for_file: unnecessary_cast

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dormbnb/providers/proof_of_enrollment_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/loading_provider.dart';
import '../providers/settle_payment_provider.dart';
import '../providers/user_data_provider.dart';
import 'navigator_util.dart';
import 'string_util.dart';

bool hasLoggedInUser() {
  return FirebaseAuth.instance.currentUser != null;
}

Future registerNewUser(BuildContext context, WidgetRef ref,
    {required String userType,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required TextEditingController confirmPasswordController,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all given fields.')));
      return;
    }
    if (!emailController.text.contains('@') ||
        !emailController.text.contains('.com')) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please input a valid email address')));
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('The passwords do not match')));
      return;
    }
    if (passwordController.text.length < 6) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('The password must be at least six characters long')));
      return;
    }
    if (ref.read(proofOfEnrollmentProvider).studentID == null) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Please upload an image of your student ID.')));
      return;
    }
    if (ref.read(proofOfEnrollmentProvider).proofOfEnrollment == null) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(
              'Please upload a document showing your proof of enrollment.')));
      return;
    }
    //  Create user with Firebase Auth
    ref.read(loadingProvider).toggleLoading(true);
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(), password: passwordController.text);

    //  Create new document is Firestore database
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      UserFields.email: emailController.text.trim(),
      UserFields.password: passwordController.text,
      UserFields.firstName: firstNameController.text.trim(),
      UserFields.lastName: lastNameController.text.trim(),
      UserFields.userType: userType,
      UserFields.profileImageURL: '',
      UserFields.isVerified: false
    });

    //  Upload student ID
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.studentIDs)
        .child('${FirebaseAuth.instance.currentUser!.uid}.png');
    final uploadTask =
        storageRef.putFile(ref.read(proofOfEnrollmentProvider).studentID!);
    final taskSnapshot = await uploadTask;
    final String studentID = await taskSnapshot.ref.getDownloadURL();

    //  Upload proof of enrollment ID
    final storageRef2 = FirebaseStorage.instance
        .ref()
        .child(StorageFields.proofOfEnrollments)
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child(ref.read(proofOfEnrollmentProvider).proofOfEnrollmentFileName);
    final uploadTask2 = storageRef2
        .putData(ref.read(proofOfEnrollmentProvider).proofOfEnrollment!);
    final taskSnapshot2 = await uploadTask2;
    final String proofOfEnrollment = await taskSnapshot2.ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      UserFields.studentID: studentID,
      UserFields.proofOfEnrollment: proofOfEnrollment
    });
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Successfully registered new user')));
    await FirebaseAuth.instance.signOut();
    ref.read(proofOfEnrollmentProvider).resetProofOfEnrollment();
    ref.read(loadingProvider.notifier).toggleLoading(false);

    navigator.pushReplacementNamed(NavigatorRoutes.login);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error registering new user: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future logInUser(BuildContext context, WidgetRef ref,
    {required TextEditingController emailController,
    required TextEditingController passwordController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Please fill up all given fields.')));
      return;
    }
    ref.read(loadingProvider.notifier).toggleLoading(true);
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text, password: passwordController.text);
    final userDoc = await getCurrentUserDoc();
    final userData = userDoc.data() as Map<dynamic, dynamic>;
    if (userData[UserFields.userType] != UserTypes.renter) {
      ref.read(loadingProvider).toggleLoading(false);
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('This mobile app is for students only.')));
      return;
    }

    if (!userData[UserFields.isVerified]) {
      ref.read(loadingProvider).toggleLoading(false);
      scaffoldMessenger.showSnackBar(const SnackBar(
          content:
              Text('Your account has not yet been verified by the admin.')));
      return;
    }
    //  reset the password in firebase in case client reset it using an email link.
    if (userData[UserFields.password] != passwordController.text) {
      await FirebaseFirestore.instance
          .collection(Collections.users)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({UserFields.password: passwordController.text});
    }
    await updateRenterRentalDocs(FirebaseAuth.instance.currentUser!.uid);
    ref.read(loadingProvider.notifier).toggleLoading(false);
    ref
        .read(userDataProvider)
        .setProfileImage(userData[UserFields.profileImageURL]);
    ref.read(userDataProvider).setUserType(userData[UserFields.userType]);
    emailController.clear();
    passwordController.clear();
    navigator.pushNamed(NavigatorRoutes.home);
  } catch (error) {
    scaffoldMessenger
        .showSnackBar(SnackBar(content: Text('Error logging in: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future sendResetPasswordEmail(BuildContext context, WidgetRef ref,
    {required TextEditingController emailController}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  if (!emailController.text.contains('@') ||
      !emailController.text.contains('.com')) {
    scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please input a valid email address.')));
    return;
  }
  try {
    ref.read(loadingProvider.notifier).toggleLoading(true);
    final filteredUsers = await FirebaseFirestore.instance
        .collection(Collections.users)
        .where(UserFields.email, isEqualTo: emailController.text.trim())
        .get();

    if (filteredUsers.docs.isEmpty) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('There is no user with that email address.')));
      ref.read(loadingProvider.notifier).toggleLoading(false);
      return;
    }
    if (filteredUsers.docs.first.data()[UserFields.userType] ==
        UserTypes.admin) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('This feature is for users and collectors only.')));
      ref.read(loadingProvider.notifier).toggleLoading(false);
      return;
    }
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: emailController.text.trim());
    ref.read(loadingProvider.notifier).toggleLoading(false);
    scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Successfully sent password reset email!')));
    navigator.pop();
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error sending password reset email: $error')));
    ref.read(loadingProvider.notifier).toggleLoading(false);
  }
}

Future uploadProfilePicture(BuildContext context, WidgetRef ref) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    ImagePicker imagePicker = ImagePicker();
    final selectedXFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedXFile == null) {
      return;
    }
    //  Upload proof of employment to Firebase Storage
    ref.read(loadingProvider).toggleLoading(true);
    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.profilePics)
        .child('${FirebaseAuth.instance.currentUser!.uid}.png');
    final uploadTask = storageRef.putFile(File(selectedXFile.path));
    final taskSnapshot = await uploadTask;
    final String downloadURL = await taskSnapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({UserFields.profileImageURL: downloadURL});
    ref.read(userDataProvider).setProfileImage(downloadURL);
    ref.read(loadingProvider).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error uploading new profile picture: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

Future removeProfilePicture(BuildContext context, WidgetRef ref) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  try {
    //  Remove profile pic from cloud storage
    ref.read(loadingProvider).toggleLoading(true);
    await FirebaseStorage.instance
        .ref()
        .child(StorageFields.profilePics)
        .child('${FirebaseAuth.instance.currentUser!.uid}.png')
        .delete();

    //Set profileImageURL paramter to ''
    await FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({UserFields.profileImageURL: ''});
    ref.read(userDataProvider).setProfileImage('');
    ref.read(loadingProvider).toggleLoading(false);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error removing profile picture: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

Future updateProfile(BuildContext context, WidgetRef ref,
    {required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required String userType}) async {
  if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill up all given fields.')));
    return;
  }
  try {
    ref.read(loadingProvider).toggleLoading(true);
    FirebaseFirestore.instance
        .collection(Collections.users)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      UserFields.firstName: firstNameController.text.trim(),
      UserFields.lastName: lastNameController.text.trim()
    });
    ref.read(loadingProvider).toggleLoading(false);
    Navigator.of(context).pop();

    Navigator.of(context).pushReplacementNamed(NavigatorRoutes.renterProfile);
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${error.toString()}')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

Future<DocumentSnapshot> getCurrentUserDoc() async {
  return await getThisUserDoc(FirebaseAuth.instance.currentUser!.uid);
}

Future<String> getCurrentUserType() async {
  final userDoc = await getCurrentUserDoc();
  final userData = userDoc.data() as Map<dynamic, dynamic>;
  return userData[UserFields.userType];
}

Future<DocumentSnapshot> getThisUserDoc(String userID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.users)
      .doc(userID)
      .get();
}

Future<List<DocumentSnapshot>> getAllRenterDocs() async {
  final users = await FirebaseFirestore.instance
      .collection(Collections.users)
      .where(UserFields.userType, isEqualTo: UserTypes.renter)
      .get();
  return users.docs.map((user) => user as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getAllOwnerDocs() async {
  final users = await FirebaseFirestore.instance
      .collection(Collections.users)
      .where(UserFields.userType, isEqualTo: UserTypes.owner)
      .get();
  return users.docs.map((user) => user as DocumentSnapshot).toList();
}

//==============================================================================
//DORMS=========================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getAllDormDocs(BuildContext context) async {
  final dorms =
      await FirebaseFirestore.instance.collection(Collections.dorms).get();
  return dorms.docs.map((e) => e as DocumentSnapshot).toList();
}

Future<DocumentSnapshot> getThisDormDoc(String dormID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.dorms)
      .doc(dormID)
      .get();
}

Future<List<DocumentSnapshot>> getAllOwnerDormDocs(BuildContext context,
    {required String ownerID}) async {
  final dorms = await FirebaseFirestore.instance
      .collection(Collections.dorms)
      .where(DormFields.ownerID, isEqualTo: ownerID)
      .get();
  return dorms.docs.map((e) => e as DocumentSnapshot).toList();
}

Future<List<DocumentSnapshot>> getUserDormDocs(BuildContext context) async {
  return getAllOwnerDormDocs(context,
      ownerID: FirebaseAuth.instance.currentUser!.uid);
}

//==============================================================================
//RENTALS=======================================================================
//==============================================================================
Future<DocumentSnapshot> getThisRentalDoc(String rentalID) async {
  return await FirebaseFirestore.instance
      .collection(Collections.rentals)
      .doc(rentalID)
      .get();
}

Future<List<DocumentSnapshot>> getUserRentalDocs() async {
  final rentals = await FirebaseFirestore.instance
      .collection(Collections.rentals)
      .where(RentalFields.renterID,
          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .get();
  return rentals.docs.map((e) => e as DocumentSnapshot).toList();
}

Future updateRenterRentalDocs(String renterID) async {
  final rentals = await FirebaseFirestore.instance
      .collection(Collections.rentals)
      .where(RentalFields.renterID, isEqualTo: renterID)
      .where(RentalFields.status, isEqualTo: RentalStatus.inUse)
      .get();
  for (var rentalDoc in rentals.docs) {
    final rentalData = rentalDoc.data() as Map<dynamic, dynamic>;
    DateTime nextPaymentDeadline =
        (rentalData[RentalFields.nextPaymentDeadline] as Timestamp).toDate();
    int monthsRequested = rentalData[RentalFields.monthsRequested];
    int paymentsMade = await getRentalApprovedPaymentDocsCount(rentalDoc.id);
    if (DateTime.now().difference(nextPaymentDeadline).inDays <= 7) {
      await FirebaseFirestore.instance
          .collection(Collections.rentals)
          .doc(rentalDoc.id)
          .update({
        RentalFields.status: monthsRequested == paymentsMade
            ? RentalStatus.completed
            : RentalStatus.pendingPayment
      });
    }
  }
}

Future makeRentalRequest(BuildContext context, WidgetRef ref,
    {required String ownerID,
    required String dormID,
    required DateTime dateStart,
    required DateTime dateEnd,
    required num monthsRequested}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    ref.read(loadingProvider).toggleLoading(true);
    await FirebaseFirestore.instance.collection(Collections.rentals).add({
      RentalFields.renterID: FirebaseAuth.instance.currentUser!.uid,
      RentalFields.ownerID: ownerID,
      RentalFields.dormID: dormID,
      RentalFields.dateStart: dateStart,
      RentalFields.dateEnd: dateEnd,
      RentalFields.status: RentalStatus.pending,
      RentalFields.monthsRequested: monthsRequested,
      RentalFields.dateRequested: DateTime.now(),
      RentalFields.dateProcessed: DateTime(1970),
      RentalFields.nextPaymentDeadline: dateStart
    });
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Successfully created new rental request')));
    ref.read(loadingProvider).toggleLoading(false);
    navigator.pop();
    NavigatorRoutes.renterSelectedDorm(context,
        dormID: dormID, isReplacing: true);
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error making new rental request: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

Future<bool> isCurrentlyRentingThisDorm(String dormID) async {
  final rentals = await FirebaseFirestore.instance
      .collection(Collections.rentals)
      .where(RentalFields.renterID,
          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where(RentalFields.dormID, isEqualTo: dormID)
      .where(RentalFields.status, whereIn: [
    RentalStatus.pending,
    RentalStatus.pendingPayment,
    RentalStatus.processingPayment,
    RentalStatus.inUse
  ]).get();
  return rentals.docs.isNotEmpty;
}

//==============================================================================
//PAYMENTS======================================================================
//==============================================================================
Future settlePendingPayment(BuildContext context, WidgetRef ref,
    {required String rentalID, required num amount}) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    ref.read(loadingProvider).toggleLoading(true);
    final paymentReference =
        await FirebaseFirestore.instance.collection(Collections.payments).add({
      PaymentFields.userID: FirebaseAuth.instance.currentUser!.uid,
      PaymentFields.isVerified: false,
      PaymentFields.rentalID: rentalID,
      PaymentFields.paymentStatus: PaymentStatuses.pending,
      PaymentFields.proofOfPaymentURL: '',
      PaymentFields.paymentMethod:
          ref.read(settlePaymentProvider).selectedPaymentMethod,
      PaymentFields.amount: amount,
      PaymentFields.dateSettled: DateTime.now(),
      PaymentFields.dateProcessed: DateTime.now(),
    });

    final storageRef = FirebaseStorage.instance
        .ref()
        .child(StorageFields.payments)
        .child('${paymentReference.id}.png');
    final uploadTask = storageRef
        .putFile(File(ref.read(settlePaymentProvider).paymentImage!.path));
    final taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();
    await FirebaseFirestore.instance
        .collection(Collections.payments)
        .doc(paymentReference.id)
        .update({PaymentFields.proofOfPaymentURL: downloadURL});

    await FirebaseFirestore.instance
        .collection(Collections.rentals)
        .doc(rentalID)
        .update({RentalFields.status: RentalStatus.processingPayment});
    scaffoldMessenger.showSnackBar(SnackBar(
        content: Text(
            'Successfully settled pending payment for this rental request.')));
    ref.read(loadingProvider).toggleLoading(false);
    navigator.pop();
  } catch (error) {
    scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error settling pending payment: $error')));
    ref.read(loadingProvider).toggleLoading(false);
  }
}

Future<int> getRentalApprovedPaymentDocsCount(String rentalID) async {
  final payments = await FirebaseFirestore.instance
      .collection(Collections.payments)
      .where(PaymentFields.rentalID, isEqualTo: rentalID)
      .where(PaymentFields.isVerified, isEqualTo: true)
      .where(PaymentFields.paymentStatus, isEqualTo: PaymentStatuses.approved)
      .get();
  return payments.docs.length;
}

//==============================================================================
//FAQS==========================================================================
//==============================================================================
Future<List<DocumentSnapshot>> getAllFAQDocs() async {
  final faqs =
      await FirebaseFirestore.instance.collection(Collections.faqs).get();
  return faqs.docs;
}
