import 'package:dormbnb/screens/edit_profile_screen.dart';
import 'package:dormbnb/screens/faqs_screen.dart';
import 'package:dormbnb/screens/forgot_password_screen.dart';
import 'package:dormbnb/screens/home_screen.dart';
import 'package:dormbnb/screens/new_rental_request_screen.dart';
import 'package:dormbnb/screens/profile_screen.dart';
import 'package:dormbnb/screens/register_screen.dart';
import 'package:dormbnb/screens/renter_selected_dorm_screen.dart';
import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
import '../screens/settle_payment_screen.dart';

class NavigatorRoutes {
  static const login = 'login';
  static const selectUserType = 'selectUserType';
  static const forgotPassword = 'forgotPassword';
  static const editProfile = 'editProfile';
  static const faqs = 'faqs';
  static const messages = 'messages';

  static const renterRegister = 'renterRegister';
  static const home = 'home';
  static const renterProfile = 'renterProfile';
  static void renterSelectedDorm(BuildContext context,
      {required String dormID, isReplacing = false}) {
    if (isReplacing) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => SelectedDormScreen(dormID: dormID)));
    } else {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => SelectedDormScreen(dormID: dormID)));
    }
  }

  static const renterNewRental = 'renterNewRental';
  static void renterSettlePayment(BuildContext context,
      {required String rentalID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RenterSettlePaymentScreen(rentalID: rentalID)));
  }
}

final Map<String, WidgetBuilder> routes = {
  NavigatorRoutes.login: (context) => const LoginScreen(),
  NavigatorRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
  NavigatorRoutes.editProfile: (context) => const EditProfileScreen(),
  NavigatorRoutes.faqs: (context) => const FAQsScreen(),

  //  RENTER
  NavigatorRoutes.renterRegister: (context) => const RegisterScreen(),
  NavigatorRoutes.home: (context) => const RenterHomeScreen(),
  NavigatorRoutes.renterProfile: (context) => const ProfileScreen(),
  NavigatorRoutes.renterNewRental: (context) => const NewRentalRequestScreen(),
};
