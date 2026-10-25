import 'package:flutter/material.dart';

import '../languages.dart';
import '../models/analysis.dart';
import '../widgets/common.dart';
import 'scam_check.dart' show shareAnalysis;

class MoreOptionsScreen extends StatelessWidget {
  final Analysis analysis;
  const MoreOptionsScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final a = analysis;
    final lang = languageByApiName(a.language);

    void openList(String title, IconData icon, List<String> items, String empty) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => _ListScreen(
          title: title,
          icon: icon,
          items: items.isNotEmpty ? items : [empty],
          rtl: lang.rtl,
        ),
      ));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenHeader(title: 'More Options'),
      body: SafeArea(
        child: PhoneWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
            children: [
              MenuTile(
                icon: Icons.share_rounded,
                title: 'Share with Family',
                subtitle: 'Send to a trusted person',
                onTap: () => shareAnalysis(a),
              ),
              MenuTile(
                icon: Icons.download_rounded,
                title: 'Save Document',
                subtitle: 'Keep it for later',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    'Saved on this phone. Find it any time under History. '
                    '(Only the explanation is saved, never the photo.)',
                    style: TextStyle(fontSize: 17),
                  ),
                )),
              ),
              MenuTile(
                icon: Icons.help_outline_rounded,
                title: 'Your Rights',
                subtitle: 'Learn about your protections',
                onTap: () => openList('Your Rights', Icons.help_outline_rounded, a.yourRights,
                    'No specific rights were found for this document. Ask a free legal aid office if unsure.'),
              ),
              MenuTile(
                icon: Icons.menu_book_rounded,
                title: 'Related Resources',
                subtitle: 'Find help in your area',
                onTap: () => openList(
                  'Related Resources',
                  Icons.menu_book_rounded,
                  [...a.whereToGetHelp, ...a.questionsToAsk.map((q) => 'Ask: $q')],
                  'Ask a trusted family member, or call 211 (USA) for free local help.',
                ),
              ),
              const SizedBox(height: 8),
              const SoftCard(
                color: AppColors.blueBg,
                borderColor: Colors.transparent,
                padding: EdgeInsets.all(22),
                child: Row(
                  children: [
                    Icon(Icons.favorite_rounded, color: Color(0xFFE5533D), size: 40),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text("You're not alone.\nWe're here to help.",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.text)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final bool rtl;
  const _ListScreen({required this.title, required this.icon, required this.items, required this.rtl});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: ScreenHeader(title: title, icon: icon),
          body: SafeArea(
            child: PhoneWidth(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                children: [
                  SoftCard(
                    child: CheckList(items: items, icon: Icons.arrow_right_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(height: 14),
                  const Text('General guidance, not legal advice.',
                      style: TextStyle(fontSize: 15, color: AppColors.subtle)),
                ],
              ),
            ),
          ),
        ),
      );
}
