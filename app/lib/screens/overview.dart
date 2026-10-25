import 'package:flutter/material.dart';

import '../languages.dart';
import '../models/analysis.dart';
import '../widgets/common.dart';
import 'explain.dart';
import 'more_options.dart';
import 'questions.dart';
import 'scam_check.dart';
import 'translation.dart';

class OverviewScreen extends StatelessWidget {
  final Analysis analysis;
  const OverviewScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final a = analysis;
    final lang = languageByApiName(a.language);
    final risk = RiskStyle.of(a.riskLevel);
    final action = a.mainAction;

    void open(Widget screen) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

    // Split key facts into money, dates, and everything else.
    bool isMoney(KeyFact f) {
      final s = '${f.label} ${f.value}'.toLowerCase();
      return s.contains(r'$') || s.contains('amount') || s.contains('rent') ||
          s.contains('deposit') || s.contains('fee') || s.contains('pay') || s.contains('cost');
    }

    bool isDate(KeyFact f) {
      final s = '${f.label} ${f.value}'.toLowerCase();
      return s.contains('date') || s.contains('due') || s.contains('deadline') ||
          s.contains('by ') || s.contains('term') || s.contains('length') || s.contains('period');
    }

    final payments = a.keyFacts.where(isMoney).toList();
    final deadlines = a.keyFacts.where((f) => !isMoney(f) && isDate(f)).toList();
    final other = a.keyFacts.where((f) => !isMoney(f) && !isDate(f)).toList();

    return Directionality(
      textDirection: lang.rtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const ScreenHeader(title: 'Document Overview'),
        body: SafeArea(
          child: PhoneWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
              children: [
                // Document title
                Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 30, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(a.documentType.isNotEmpty ? a.documentType : 'Document',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Risk score dashboard
                _RiskScoreCard(analysis: a),
                const SizedBox(height: 14),

                if (a.simpleSummary.isNotEmpty) ...[
                  SoftCard(
                    child: Text(a.simpleSummary,
                        style: const TextStyle(fontSize: 18, height: 1.4, color: AppColors.text)),
                  ),
                  const SizedBox(height: 14),
                ],

                // Grouped key info
                _FactGroup(title: 'Payments', icon: Icons.payments_outlined, facts: payments, analysis: a),
                _FactGroup(title: 'Deadlines', icon: Icons.event_outlined, facts: deadlines, analysis: a),
                _FactGroup(title: 'Key information', icon: Icons.key_outlined, facts: other, analysis: a),

                // Action Needed
                if (action != null) ...[
                  _ActionNeeded(action: action, analysis: a),
                  const SizedBox(height: 14),
                ],

                // Responsibilities
                if (a.responsibilities.isNotEmpty) ...[
                  _SourcedCard(
                    title: 'Your responsibilities',
                    icon: Icons.assignment_turned_in_outlined,
                    items: a.responsibilities,
                    analysis: a,
                  ),
                  const SizedBox(height: 14),
                ],

                // Important clauses
                if (a.importantClauses.isNotEmpty) ...[
                  _SourcedCard(
                    title: 'Important clauses',
                    icon: Icons.gavel_rounded,
                    iconColor: AppColors.orange,
                    background: AppColors.orangeBg,
                    items: a.importantClauses,
                    analysis: a,
                  ),
                  const SizedBox(height: 14),
                ],

                // Guided questions
                if (a.questionsToAsk.isNotEmpty) ...[
                  _QuestionsPreview(
                    questions: a.questionsToAsk,
                    onOpen: () => open(QuestionsScreen(analysis: a)),
                  ),
                  const SizedBox(height: 14),
                ],

                PrimaryButton(
                  label: 'View Translation',
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: () => open(TranslationScreen(analysis: a)),
                ),
                const SizedBox(height: 12),
                ListenButton(
                  label: 'Listen to Explanation',
                  text: a.explanationForSpeech,
                  language: lang,
                ),
                const SizedBox(height: 22),

                MenuTile(
                  icon: Icons.face_rounded,
                  title: "Explain Like I'm 70",
                  subtitle: 'Simple answers to common questions',
                  onTap: () => open(ExplainScreen(analysis: a)),
                ),
                MenuTile(
                  icon: Icons.description_outlined,
                  title: 'Original Document',
                  subtitle: 'See the full text you scanned',
                  onTap: () => open(OriginalTextScreen(originalText: a.originalText, rtl: lang.rtl)),
                ),
                MenuTile(
                  icon: risk.icon,
                  title: 'Scam Check',
                  subtitle: risk.title,
                  onTap: () => open(ScamCheckScreen(analysis: a)),
                ),
                MenuTile(
                  icon: Icons.more_horiz_rounded,
                  title: 'More Options',
                  subtitle: 'Share, rights, and help',
                  onTap: () => open(MoreOptionsScreen(analysis: a)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Guidance only, not legal advice. AI can make mistakes. '
                  'For important decisions, ask a trusted person.',
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

/// A card listing key facts of one group (Payments / Deadlines / Key info).
class _FactGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<KeyFact> facts;
  final Analysis analysis;
  const _FactGroup(
      {required this.title, required this.icon, required this.facts, required this.analysis});

  @override
  Widget build(BuildContext context) {
    if (facts.isEmpty) return const SizedBox.shrink();
    final lang = languageByApiName(analysis.language);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.text)),
              ],
            ),
            const SizedBox(height: 6),
            for (final f in facts)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(f.label,
                              style: const TextStyle(fontSize: 17, color: AppColors.subtle)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 6,
                          child: Text(f.value,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
                        ),
                      ],
                    ),
                    SourceLink(source: f.source, originalText: analysis.originalText, rtl: lang.rtl),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Orange "Action Needed" box with a source link.
class _ActionNeeded extends StatelessWidget {
  final ActionStep action;
  final Analysis analysis;
  const _ActionNeeded({required this.action, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final high = analysis.riskLevel == RiskLevel.high;
    final lang = languageByApiName(analysis.language);
    return SoftCard(
      color: high ? AppColors.redBg : AppColors.orangeBg,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: high ? AppColors.red : AppColors.orange,
                child: const Icon(Icons.priority_high_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Action Needed',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: high ? AppColors.red : const Color(0xFFC86A0A))),
                    const SizedBox(height: 4),
                    Text(action.step,
                        style: const TextStyle(fontSize: 18, height: 1.35, color: AppColors.text)),
                    if (action.deadline != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('By ${action.deadline}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SourceLink(source: action.source, originalText: analysis.originalText, rtl: lang.rtl),
        ],
      ),
    );
  }
}

/// A card of {text + source} items (responsibilities / important clauses).
class _SourcedCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color background;
  final List<Sourced> items;
  final Analysis analysis;
  const _SourcedCard({
    required this.title,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.background = Colors.white,
    required this.items,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    final lang = languageByApiName(analysis.language);
    return SoftCard(
      color: background,
      borderColor: background == Colors.white ? AppColors.border : Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.text)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final s in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.chevron_right_rounded, size: 22, color: iconColor),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(s.text,
                            style: const TextStyle(fontSize: 18, height: 1.35, color: AppColors.text)),
                      ),
                    ],
                  ),
                  SourceLink(source: s.source, originalText: analysis.originalText, rtl: lang.rtl),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Preview of guided questions with a "See all" button.
class _QuestionsPreview extends StatelessWidget {
  final List<String> questions;
  final VoidCallback onOpen;
  const _QuestionsPreview({required this.questions, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.blueBg,
      borderColor: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.help_outline_rounded, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text('Ask before you sign',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.text)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final q in questions.take(2))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(fontSize: 18, color: AppColors.primary)),
                  Expanded(
                    child: Text(q,
                        style: const TextStyle(fontSize: 17, height: 1.35, color: AppColors.text)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'See all questions',
            icon: Icons.checklist_rounded,
            onPressed: onOpen,
          ),
        ],
      ),
    );
  }
}

/// Professional "Risk Score" dashboard card (AI estimate).
class _RiskScoreCard extends StatelessWidget {
  final Analysis analysis;
  const _RiskScoreCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    final risk = RiskStyle.of(analysis.riskLevel);
    final score = RiskStyle.score(analysis.riskLevel);

    // Up to 3 "key findings": safe signs (✓) then risk reasons (⚠).
    final findings = <(bool, String)>[
      for (final s in analysis.safeSigns.take(2)) (true, s),
      for (final r in analysis.riskReasons.take(2)) (false, r),
    ].take(4).toList();

    return SoftCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Risk Assessment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: risk.background, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(risk.icon, size: 17, color: risk.color),
                    const SizedBox(width: 5),
                    Text(risk.title,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: risk.color)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Score dial
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 8,
                        backgroundColor: AppColors.border,
                        color: risk.color,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$score',
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w800, color: risk.color)),
                        const Text('/100', style: TextStyle(fontSize: 12, color: AppColors.subtle)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Key Findings',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(height: 6),
                    if (findings.isEmpty)
                      const Text('No major issues found.',
                          style: TextStyle(fontSize: 15, color: AppColors.subtle))
                    else
                      for (final (ok, text) in findings)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(ok ? Icons.check_circle : Icons.warning_amber_rounded,
                                  size: 17, color: ok ? AppColors.green : AppColors.orange),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(text,
                                    style: const TextStyle(
                                        fontSize: 14, height: 1.3, color: AppColors.text)),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Risk score is an AI estimate, not a precise legal rating.',
              style: TextStyle(fontSize: 12, color: AppColors.subtle)),
        ],
      ),
    );
  }
}
