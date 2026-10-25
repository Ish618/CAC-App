import 'package:flutter/material.dart';

import '../languages.dart';
import '../models/analysis.dart';
import '../widgets/common.dart';

class TranslationScreen extends StatelessWidget {
  final Analysis analysis;
  const TranslationScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final a = analysis;
    final lang = languageByApiName(a.language);

    // Fall back to the simple summary if an older history item has no full translation.
    final translated = a.fullTranslation.isNotEmpty ? a.fullTranslation : a.simpleSummary;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScreenHeader(
        title: 'Translation (${lang.nativeName})',
        icon: Icons.translate_rounded,
      ),
      body: SafeArea(
        child: PhoneWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
            children: [
              SoftCard(
                color: AppColors.blueBg,
                borderColor: Colors.transparent,
                padding: const EdgeInsets.all(22),
                child: Directionality(
                  textDirection: lang.rtl ? TextDirection.rtl : TextDirection.ltr,
                  child: SelectableText(
                    translated,
                    style: const TextStyle(fontSize: 24, height: 1.5, color: AppColors.text),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListenButton(
                label: 'Listen in ${lang.nativeName}',
                text: translated,
                language: lang,
                primary: true,
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'View Original Text',
                icon: Icons.description_outlined,
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => OriginalTextScreen(originalText: a.originalText),
                )),
              ),
              const SizedBox(height: 16),
              const Text(
                'Translations are made by AI and may contain mistakes. '
                'Check amounts and dates against the original paper.',
                style: TextStyle(fontSize: 15, color: AppColors.subtle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
