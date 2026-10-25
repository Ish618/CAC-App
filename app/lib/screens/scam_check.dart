import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../languages.dart';
import '../models/analysis.dart';
import '../widgets/common.dart';

class ScamCheckScreen extends StatelessWidget {
  final Analysis analysis;
  const ScamCheckScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final a = analysis;
    final lang = languageByApiName(a.language);
    final risk = RiskStyle.of(a.riskLevel);

    final description = switch (a.riskLevel) {
      RiskLevel.low => 'This document appears to be legitimate.',
      RiskLevel.medium => 'This looks real, but it has deadlines or important consequences.',
      RiskLevel.high => 'This document shows signs of a scam or is very unfair to you. '
          'Do not pay, sign, or call anyone yet.',
    };

    return Directionality(
      textDirection: lang.rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: ScreenHeader(title: 'Scam Check', icon: Icons.shield_rounded, iconColor: risk.color),
        body: SafeArea(
          child: PhoneWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
              children: [
                SoftCard(
                  color: risk.background,
                  borderColor: Colors.transparent,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: risk.color,
                            child: Icon(
                              a.riskLevel == RiskLevel.low ? Icons.check_rounded : risk.icon,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(risk.title,
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w700, color: risk.color)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(description,
                          style: const TextStyle(fontSize: 19, height: 1.4, color: AppColors.text)),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                if (a.riskReasons.isNotEmpty || a.safeSigns.isNotEmpty) ...[
                  const Text('Why?',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
                  const SizedBox(height: 6),
                  if (a.riskReasons.isNotEmpty)
                    CheckList(
                      items: a.riskReasons,
                      icon: Icons.warning_rounded,
                      color: a.riskLevel == RiskLevel.low ? AppColors.orange : risk.color,
                    ),
                  if (a.safeSigns.isNotEmpty)
                    CheckList(items: a.safeSigns, icon: Icons.check_circle, color: AppColors.green),
                  const SizedBox(height: 18),
                ],

                if (a.beforeYouSign.isNotEmpty) ...[
                  SoftCard(
                    color: AppColors.orangeBg,
                    borderColor: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.front_hand_rounded, color: AppColors.orange, size: 26),
                            SizedBox(width: 10),
                            Text('Before you sign',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (final s in a.beforeYouSign)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Icon(Icons.warning_amber_rounded,
                                          size: 22, color: AppColors.orange),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(s.text,
                                          style: const TextStyle(
                                              fontSize: 18, height: 1.35, color: AppColors.text)),
                                    ),
                                  ],
                                ),
                                SourceLink(
                                    source: s.source, originalText: a.originalText, rtl: lang.rtl),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                ],

                SoftCard(
                  color: AppColors.blueBg,
                  borderColor: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 26),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Still unsure?',
                                    style: TextStyle(
                                        fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.text)),
                                SizedBox(height: 4),
                                Text(
                                  'You can always share this with a family member or trusted friend '
                                  'for a second opinion.',
                                  style: TextStyle(fontSize: 17, height: 1.4, color: AppColors.subtle),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SecondaryButton(
                        label: 'Share with Family',
                        icon: Icons.share_rounded,
                        onPressed: () => shareAnalysis(a),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Scam Check is an AI estimate, not a guarantee. If something feels wrong, '
                  'contact the company using the number on its official website, not the paper.',
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

/// Opens the phone's share sheet (WhatsApp, Messages, email...) with a text summary.
void shareAnalysis(Analysis a) {
  final text = '${a.toPlainText(forSharing: true)}\n\n'
      '(From Veracity. Guidance only, not legal advice.)';
  Share.share(text, subject: a.documentType);
}
