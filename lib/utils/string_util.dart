import 'dart:math';

class ImagePaths {
  static const String logo = 'assets/images/dorms_logo.png';
  static const String bg = 'assets/images/dorm_bg.png';
}

class StorageFields {
  static const String studentIDs = 'studentIDs';
  static const String profilePics = 'profilePics';
  static const String dormImages = 'dormImages';
  static const String proofOfOwnerships = 'proofOfOwnerships';
  static const String proofOfEnrollments = 'proofOfEnrollments';
  static const String payments = 'payments';
}

class UserTypes {
  static const String renter = 'RENTER';
  static const String owner = 'OWNER';
  static const String admin = 'ADMIN';
}

class Collections {
  static const String users = 'users';
  static const String faqs = 'faqs';
  static const String dorms = 'dorms';
  static const String rentals = 'rentals';
  static const String payments = 'payments';
}

class UserFields {
  static const String email = 'email';
  static const String password = 'password';
  static const String firstName = 'firstName';
  static const String lastName = 'lastName';
  static const String userType = 'userType';
  static const String profileImageURL = 'profileImageURL';
  static const String isVerified = 'isVerified';
  static const String studentID = 'studentID';
  static const String proofOfEnrollment = 'proofOfEnrollment';
}

class DormFields {
  static const String ownerID = 'ownerID';
  static const String name = 'name';
  static const String address = 'address';
  static const String description = 'description';
  static const String isVerified = 'isVerified';
  static const String proofOfOwnership = 'proofOfOwnership';
  static const String isAvailable = 'isAvailable';
  static const String dormImageURLs = 'dormImageURLs';
  static const String monthlyRent = 'monthlyRent';
}

class RentalFields {
  static const String renterID = 'renterID';
  static const String ownerID = 'ownerID';
  static const String dormID = 'dormID';
  static const String status = 'status';
  static const String dateStart = 'dateStart';
  static const String dateEnd = 'dateEnd';
  static const String dateRequested = 'dateRequested';
  static const String dateProcessed = 'dateProcessed';
  static const String nextPaymentDeadline = 'nextPaymentDeadline';
  static const String monthsRequested = 'monthsRequested';
}

class RentalStatus {
  static const String pending = 'PENDING';
  static const String denied = 'DENIED';
  static const String cancelled = 'CANCELLED';
  static const String evicted = 'EVICTED';
  static const String pendingPayment = 'PENDING PAYMENT';
  static const String processingPayment = 'PROCESSING PAYMENT';
  static const String inUse = 'IN USE';
  static const String completed = 'COMPLETED';
}

class PaymentFields {
  static const String userID = 'userID';
  static const String rentalID = 'rentalID';
  static const String amount = 'amount';
  static const String paymentStatus = 'paymentStatus';
  static const String isVerified = 'isVerified';
  static const String proofOfPaymentURL = 'proofOfPaymentURL';
  static const String paymentMethod = 'paymentMethod';
  static const String dateSettled = 'dateSettled';
  static const String dateProcessed = 'dateProcessed';
}

class PaymentStatuses {
  static const String pending = 'PENDING';
  static const String approved = 'APPROVED';
  static const String denied = 'DENIED';
}

class FAQFields {
  static const String question = 'question';
  static const String answer = 'answer';
}

String generateRandomHexString(int length) {
  final random = Random();
  final codeUnits = List.generate(length ~/ 2, (index) {
    return random.nextInt(255);
  });

  final hexString =
      codeUnits.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
  return hexString;
}

String formatPrice(double amount) {
  // Round the amount to two decimal places
  amount = double.parse((amount).toStringAsFixed(2));

  // Convert the double to a string and split it into whole and decimal parts
  List<String> parts = amount.toString().split('.');

  // Format the whole part with commas
  String formattedWhole = '';
  for (int i = 0; i < parts[0].length; i++) {
    if (i != 0 && (parts[0].length - i) % 3 == 0) {
      formattedWhole += ',';
    }
    formattedWhole += parts[0][i];
  }

  // If there's a decimal part, add it back
  String formattedAmount = formattedWhole;
  if (parts.length > 1) {
    formattedAmount += '.${parts[1].length == 1 ? '${parts[1]}0' : parts[1]}';
  } else {
    // If there's no decimal part, append '.00'
    formattedAmount += '.00';
  }

  return formattedAmount;
}
