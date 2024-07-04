import 'package:dormbnb/widgets/custom_text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/faqs_provider.dart';
import '../providers/loading_provider.dart';
import '../providers/user_data_provider.dart';
import '../utils/future_util.dart';
import '../utils/navigator_util.dart';
import '../utils/string_util.dart';
import '../widgets/app_bar_widget.dart';
import '../widgets/app_drawer_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';

class FAQsScreen extends ConsumerStatefulWidget {
  const FAQsScreen({super.key});

  @override
  ConsumerState<FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends ConsumerState<FAQsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        ref.read(loadingProvider).toggleLoading(true);
        ref.read(faqsProvider).setFAQDocs(await getAllFAQDocs());
        ref.read(loadingProvider).toggleLoading(false);
      } catch (error) {
        scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Error getting all FAQ docs: $error')));
        ref.read(loadingProvider).toggleLoading(false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loadingProvider);
    ref.watch(faqsProvider);
    return Scaffold(
      appBar: appBarWidget(hasLeading: true),
      drawer: appDrawer(context, ref,
          userType: ref.read(userDataProvider).userType,
          currentPath: NavigatorRoutes.faqs),
      body: switchedLoadingContainer(
          ref.read(loadingProvider).isLoading,
          SingleChildScrollView(
            child: all20Pix(
                child: ref.read(faqsProvider).faqDocs.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: ref.read(faqsProvider).faqDocs.length,
                        itemBuilder: (context, index) {
                          final faqData = ref
                              .read(faqsProvider)
                              .faqDocs[index]
                              .data() as Map<dynamic, dynamic>;
                          String question = faqData[FAQFields.question];
                          String answer = faqData[FAQFields.answer];
                          return Container(
                            decoration: BoxDecoration(border: Border.all()),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                blackHelveticaBold(question),
                                blackHelveticaRegular(answer)
                              ],
                            ),
                          );
                        })
                    : vertical20Pix(
                        child: blackHelveticaBold('NO FAQS AVAILABLE',
                            fontSize: 50))),
          )),
    );
  }
}
