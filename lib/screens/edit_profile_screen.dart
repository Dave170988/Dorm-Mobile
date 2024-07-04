import 'package:dormbnb/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/loading_provider.dart';
import '../providers/user_data_provider.dart';
import '../utils/future_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  String userType = UserTypes.owner;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        final userDoc = await getCurrentUserDoc();
        final userData = userDoc.data() as Map<dynamic, dynamic>;
        firstNameController.text = userData[UserFields.firstName];
        lastNameController.text = userData[UserFields.lastName];
        userType = userData[UserFields.userType];
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting profile details: $error')));
        ref.read(loadingProvider).toggleLoading(false);
        navigator.pop();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: appBarWidget(hasLeading: true),
        body: stackedLoadingContainer(
            context,
            ref.read(loadingProvider).isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildProfileImageWidget(
                          profileImageURL:
                              ref.read(userDataProvider).profileImageURL,
                          radius: MediaQuery.of(context).size.width * 0.15),
                      Column(
                        children: [
                          if (ref
                              .read(userDataProvider)
                              .profileImageURL
                              .isNotEmpty)
                            ElevatedButton(
                                onPressed: () =>
                                    removeProfilePicture(context, ref),
                                child: whiteHelveticaBold(
                                    'REMOVE\nPROFILE PICTURE')),
                          ElevatedButton(
                              onPressed: () =>
                                  uploadProfilePicture(context, ref),
                              child:
                                  whiteHelveticaBold('UPLOAD\nPROFILE PICTURE'))
                        ],
                      )
                    ],
                  ),
                  regularTextField(
                      label: 'First Name', textController: firstNameController),
                  regularTextField(
                      label: 'Last Name', textController: lastNameController),
                  const Gap(40),
                  ElevatedButton(
                      onPressed: () => updateProfile(context, ref,
                          firstNameController: firstNameController,
                          lastNameController: lastNameController,
                          userType: userType),
                      child: whiteHelveticaBold('UPDATE PROFILE DETAILS'))
                ],
              )),
            )),
      ),
    );
  }
}
