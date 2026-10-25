import 'package:flutter/material.dart';

import '../languages.dart';
import '../models/analysis.dart';
import '../widgets/common.dart';

/// "Ask before you sign": the full list of guided questions, with Read Aloud.
class QuestionsScreen extends StatelessWidget {
  final Analysis analysis;
  const QuestionsScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final a = analysis;
    final lang = languageByApiName(a.language);
    final questions = a.questionsToAsk;

    return Directionality(
      textDirection: lang.rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const ScreenHeader(title: 'Ask Before You Sign', icon: Icons.help_outline_rounded),
        body: SafeArea(
          child: PhoneWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
              children: [
                const Text(
                  'Good questions to ask the other person before you sign or pay:',
                  style: TextStyle(fontSize: 18, height: 1.4, color: AppColors.text),
                ),
                const SizedBox(height: 14),
                for (var i = 0; i < questions.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SoftCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.blueBg,
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(questions[i],
                                style: const TextStyle(
                                    fontSize: 19, height: 1.4, color: AppColors.text)),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                ListenButton(
                  label: 'Read Questions To Me',
                  text: questions.join('\n'),
                  language: lang,
                  primary: true,
                ),
                const SizedBox(height: 14),
                const Text(
                  'You are in control. It is okay to say "I need time to think" and ask '
                  'a trusted person before you decide.',
                  style: TextStyle(fontSize: 15, color: AppColors.subtle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
