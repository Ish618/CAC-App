import 'package:flutter/material.dart';

import '../languages.dart';
import '../models/analysis.dart';
import '../widgets/common.dart';

class ExplainScreen extends StatelessWidget {
  final Analysis analysis;
  const ExplainScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final a = analysis;
    final lang = languageByApiName(a.language);

    // Older history items may not have Q&A; fall back to the summary.
    final qa = a.simpleQa.isNotEmpty
        ? a.simpleQa
        : [QA('What is this?', a.simpleSummary.isNotEmpty ? a.simpleSummary : a.documentType)];

    return Directionality(
      textDirection: lang.rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const ScreenHeader(title: "Explain Like I'm 70", icon: Icons.face_rounded),
        body: SafeArea(
          child: PhoneWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
              children: [
                SoftCard(
                  color: const Color(0xFFFFF6E5),
                  borderColor: Colors.transparent,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < qa.length; i++)
                        Padding(
                          padding: EdgeInsets.only(bottom: i == qa.length - 1 ? 0 : 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(qa[i].question,
                                  style: const TextStyle(
                                      fontSize: 21, fontWeight: FontWeight.w700, color: AppColors.text)),
                              const SizedBox(height: 4),
                              Text(qa[i].answer,
                                  style: const TextStyle(
                                      fontSize: 20, height: 1.4, color: AppColors.text)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ListenButton(
                  label: 'Read To Me',
                  text: qa.map((q) => '${q.question} ${q.answer}').join('\n'),
                  language: lang,
                  primary: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
