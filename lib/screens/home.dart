import 'package:flutter/material.dart';

import '../languages.dart';
import '../models/analysis.dart';
import '../services/history.dart';
import '../widgets/common.dart';
import 'camera.dart';
import 'overview.dart';
import 'scam_check.dart';
import 'tips.dart';

class HomeScreen extends StatefulWidget {
  /// Switches the bottom tab to History (provided by the shell).
  final VoidCallback onOpenHistory;
  const HomeScreen({super.key, required this.onOpenHistory});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Analysis> _recent = [];

  @override
  void initState() {
    super.initState();
    HistoryService.load().then((items) {
      if (mounted) setState(() => _recent = items);
    });
  }

  void _analyze() => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CameraScreen()),
      );

  /// Quick Analysis chips: open the latest result, or ask the user to scan first.
  void _openLatest({required bool scamCheck}) {
    if (_recent.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Scan a document first to see this.', style: TextStyle(fontSize: 17)),
      ));
      return;
    }
    final latest = _recent.first;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => scamCheck
          ? ScamCheckScreen(analysis: latest)
          : OverviewScreen(analysis: latest),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: PhoneWidth(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
              decoration: const BoxDecoration(
                gradient: AppColors.gradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Image.asset(
                      'asset/images/cover_photo.jpg',
                      fit: BoxFit.cover,
                      semanticLabel: 'Veracity logo',
                      errorBuilder: (context, error, stack) =>
                          const Icon(Icons.shield_outlined, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('VERACITY',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5)),
                      Text('Contract Intelligence',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 15,
                              letterSpacing: 0.3)),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SoftCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                  color: AppColors.blueBg,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.upload_file_outlined,
                                  color: AppColors.primary, size: 26),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Upload Agreement',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text)),
                                SizedBox(height: 2),
                                Text('Photo or image of your document',
                                    style: TextStyle(fontSize: 14, color: AppColors.subtle)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        PrimaryButton(
                          label: 'Analyze Agreement',
                          icon: Icons.gavel_rounded,
                          onPressed: _analyze,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TrustBadge(icon: Icons.lock_outline_rounded, label: 'Secure\nProcessing'),
                      TrustBadge(icon: Icons.smart_toy_outlined, label: 'AI-Powered\nReview'),
                      TrustBadge(icon: Icons.translate_rounded, label: 'Plain-English\nExplanations'),
                    ],
                  ),
                  const SizedBox(height: 26),

                  const _SectionTitle('Quick Analysis'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _Chip(
                        icon: Icons.summarize_outlined,
                        label: 'Summary',
                        onTap: () => _openLatest(scamCheck: false),
                      ),
                      _Chip(
                        icon: Icons.assignment_turned_in_outlined,
                        label: 'Obligations',
                        onTap: () => _openLatest(scamCheck: false),
                      ),
                      _Chip(
                        icon: Icons.event_outlined,
                        label: 'Key Dates',
                        onTap: () => _openLatest(scamCheck: false),
                      ),
                      _Chip(
                        icon: Icons.flag_outlined,
                        label: 'Red Flags',
                        onTap: () => _openLatest(scamCheck: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),

                  ValueListenableBuilder<AppLanguage>(
                    valueListenable: AppState.language,
                    builder: (context, lang, _) => MenuTile(
                      icon: Icons.language_rounded,
                      title: 'Explanation Language',
                      value: lang.nativeName,
                      onTap: () => showLanguagePicker(context),
                    ),
                  ),
                  MenuTile(
                    icon: Icons.menu_book_outlined,
                    title: 'Tips & Resources',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TipsScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _SectionTitle('Recent Documents'),
                      if (_recent.isNotEmpty)
                        TextButton(
                          onPressed: widget.onOpenHistory,
                          child: const Text('View all'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (_recent.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('No documents yet. Analyze an agreement to get started.',
                          style: TextStyle(fontSize: 15, color: AppColors.subtle)),
                    )
                  else
                    for (final a in _recent.take(3)) _RecentRow(analysis: a),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text));
}

/// Quick Analysis chip: tappable, opens the latest analysis.
class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Chip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 7),
                Text(label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text)),
              ],
            ),
          ),
        ),
      );
}

/// One recent document row with a risk badge; opens its saved analysis.
class _RecentRow extends StatelessWidget {
  final Analysis analysis;
  const _RecentRow({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final risk = RiskStyle.of(analysis.riskLevel);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => OverviewScreen(analysis: analysis)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: AppColors.primary, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    analysis.documentType.isNotEmpty ? analysis.documentType : 'Document',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                      color: risk.background, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(risk.icon, size: 15, color: risk.color),
                      const SizedBox(width: 4),
                      Text(risk.title,
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700, color: risk.color)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
