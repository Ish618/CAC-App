import 'package:flutter/material.dart';

import '../languages.dart';
import '../services/history.dart';
import '../widgets/common.dart';

/// "Settings" tab.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _clearHistory(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all history?'),
        content: const Text('This removes all past documents from this phone.',
            style: TextStyle(fontSize: 19)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      await HistoryService.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('History deleted.', style: TextStyle(fontSize: 17)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PhoneWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 14),
              child: Text('Settings',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.text)),
            ),
            ValueListenableBuilder<AppLanguage>(
              valueListenable: AppState.language,
              builder: (context, lang, _) => MenuTile(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: 'Explanations and translations',
                value: lang.nativeName,
                onTap: () => showLanguagePicker(context),
              ),
            ),
            MenuTile(
              icon: Icons.delete_outline_rounded,
              title: 'Clear History',
              subtitle: 'Remove saved explanations',
              onTap: () => _clearHistory(context),
            ),
            const SizedBox(height: 8),
            const SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 26),
                      SizedBox(width: 10),
                      Text('Your privacy',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
                    ],
                  ),
                  SizedBox(height: 8),
                  CheckList(
                    icon: Icons.check_circle,
                    color: AppColors.green,
                    items: [
                      'Photos are never saved by the app or our server.',
                      'Explanations are saved only on this phone.',
                      'No account or sign-in needed.',
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Photos are sent to Google Gemini AI to be read. Avoid scanning '
                    'passwords or full card numbers.',
                    style: TextStyle(fontSize: 15, height: 1.4, color: AppColors.subtle),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About Veracity',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
                  SizedBox(height: 6),
                  Text(
                    'Veracity helps people understand important documents in their own language '
                    'before they sign or pay: what it means, what they are agreeing to, and what '
                    'to ask first.\n\n'
                    'Guidance only, not legal advice. AI can make mistakes.',
                    style: TextStyle(fontSize: 17, height: 1.4, color: AppColors.text),
                  ),
                  SizedBox(height: 10),
                  Text('Version 1.0.0', style: TextStyle(fontSize: 14, color: AppColors.subtle)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
