import 'package:flutter/material.dart';

import '../languages.dart';
import '../models/analysis.dart';
import '../services/history.dart';
import '../services/speech.dart';

class AppColors {
  static const purple = Color(0xFF7C3AED);
  static const blue = Color(0xFF3B82F6);
  static const primary = Color(0xFF7C3AED);
  static const background = Color(0xFFF8FAFC);
  static const text = Color(0xFF0F172A);
  static const subtle = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const green = Color(0xFF10B981);
  static const greenBg = Color(0xFFD1FAE5);
  static const orange = Color(0xFFC8841C);
  static const orangeBg = Color(0xFFFBF1DE);
  static const red = Color(0xFFC23B38);
  static const redBg = Color(0xFFF9E8E7);
  static const purpleBg = Color(0xFFECEDF5);
  static const blueBg = Color(0xFFEDE9FE);
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, blue],
  );
}

class AppState {
  AppState._();
  static final language = ValueNotifier<AppLanguage>(languageByApiName('Spanish')); // default: Spanish

  static Future<void> load() async {
    final saved = await HistoryService.savedLanguage();
    if (saved != null) language.value = languageByApiName(saved);
  }

  static void setLanguage(AppLanguage l) {
    language.value = l;
    HistoryService.saveLanguage(l.apiName);
  }
}

Future<void> showLanguagePicker(BuildContext context) async {
  final picked = await showModalBottomSheet<AppLanguage>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text('Choose your language',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            ),
            for (final l in kLanguages)
              ListTile(
                minVerticalPadding: 14,
                title: Text(l.nativeName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                subtitle: l.nativeName != l.apiName ? Text(l.apiName) : null,
                trailing: l.apiName == AppState.language.value.apiName
                    ? const Icon(Icons.check_circle, color: AppColors.green, size: 28)
                    : null,
                onTap: () => Navigator.pop(ctx, l),
              ),
          ],
        ),
      ),
    ),
  );
  if (picked != null) AppState.setLanguage(picked);
}

class RiskStyle {
  final Color color;
  final Color background;
  final IconData icon;
  final String title;
  const RiskStyle(this.color, this.background, this.icon, this.title);

  static RiskStyle of(RiskLevel level) => switch (level) {
        RiskLevel.low =>
          const RiskStyle(AppColors.green, AppColors.greenBg, Icons.verified_rounded, 'Low Risk'),
        RiskLevel.medium => const RiskStyle(
            AppColors.orange, AppColors.orangeBg, Icons.warning_amber_rounded, 'Medium Risk'),
        RiskLevel.high =>
          const RiskStyle(AppColors.red, AppColors.redBg, Icons.gpp_maybe_rounded, 'High Risk'),
      };

  // Rough 0-100 figure picked from the risk level; higher means safer.
  static int score(RiskLevel level) => switch (level) {
        RiskLevel.low => 88,
        RiskLevel.medium => 62,
        RiskLevel.high => 31,
      };
}

class TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const TrustBadge({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(color: AppColors.blueBg, shape: BoxShape.circle),
            child: Icon(icon, size: 24, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 92,
            child: Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, height: 1.2, color: AppColors.subtle)),
          ),
        ],
      );
}

class SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color = Colors.white,
    this.borderColor = AppColors.border,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: const [
            BoxShadow(color: Color(0x0A1E3A8A), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: child,
      );
}

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final VoidCallback onTap;
  const MenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.w600, color: AppColors.text)),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(subtitle!,
                                style: const TextStyle(fontSize: 15, color: AppColors.subtle)),
                          ),
                      ],
                    ),
                  ),
                  if (value != null)
                    Text(value!,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.text)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, color: AppColors.subtle, size: 28),
                ],
              ),
            ),
          ),
        ),
      );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  const PrimaryButton(
      {super.key, required this.label, this.icon, this.trailingIcon, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 62,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: BorderRadius.circular(31),
            boxShadow: [
              BoxShadow(
                color: AppColors.purple.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(31)),
              textStyle: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, size: 28), const SizedBox(width: 12)],
                Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                if (trailingIcon != null) ...[const SizedBox(width: 12), Icon(trailingIcon, size: 26)],
              ],
            ),
          ),
        ),
      );
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  const SecondaryButton({super.key, required this.label, this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 60,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.text,
            side: const BorderSide(color: AppColors.border, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 26, color: AppColors.primary), const SizedBox(width: 12)],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      );
}

class ListenButton extends StatefulWidget {
  final String label;
  final String text;
  final AppLanguage language;
  final bool primary;
  const ListenButton({
    super.key,
    required this.label,
    required this.text,
    required this.language,
    this.primary = false,
  });

  @override
  State<ListenButton> createState() => _ListenButtonState();
}

class _ListenButtonState extends State<ListenButton> {
  final _speech = SpeechService.instance;

  @override
  void dispose() {
    if (_speech.owner.value == this) _speech.stop();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_speech.owner.value == this) {
      await _speech.stop();
      return;
    }
    final ok = await _speech.speak(widget.text, widget.language, owner: this);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'This device has no ${widget.language.apiName} voice. '
          'Please read the text, or ask someone to read it for you.',
          style: const TextStyle(fontSize: 17),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Object?>(
        valueListenable: _speech.owner,
        builder: (context, owner, _) {
          final speaking = owner == this;
          final label = speaking ? 'Stop' : widget.label;
          final icon = speaking ? Icons.stop_rounded : Icons.volume_up_rounded;
          return widget.primary
              ? PrimaryButton(label: label, icon: icon, onPressed: _toggle)
              : SecondaryButton(label: label, icon: icon, onPressed: _toggle);
        },
      );
}

class ScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? icon;
  final Color iconColor;
  final List<Widget> actions;
  const ScreenHeader({
    super.key,
    required this.title,
    this.icon,
    this.iconColor = AppColors.primary,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) => AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
        toolbarHeight: 64,
        centerTitle: false,
        titleSpacing: 0,
        title: Row(
          children: [
            if (icon != null) ...[Icon(icon, color: iconColor, size: 28), const SizedBox(width: 10)],
            Flexible(
              child: Text(title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 23, fontWeight: FontWeight.w700, color: AppColors.text)),
            ),
          ],
        ),
        actions: actions,
      );
}

/// Centers content and limits width so it looks like a phone on big screens.
class PhoneWidth extends StatelessWidget {
  final Widget child;
  const PhoneWidth({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: child),
      );
}

/// Shows a quote from the document ("From your document: …") that opens the
/// original text with that part highlighted when tapped.
class SourceLink extends StatelessWidget {
  final String source;
  final String originalText;
  final bool rtl;
  const SourceLink({super.key, required this.source, required this.originalText, this.rtl = false});

  @override
  Widget build(BuildContext context) {
    if (source.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OriginalTextScreen(originalText: originalText, highlight: source, rtl: rtl),
        )),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.blueBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.description_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: AppColors.subtle, height: 1.3),
                    children: [
                      const TextSpan(
                          text: 'From your document: ',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                      TextSpan(text: '"${source.trim()}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full original document text with one phrase highlighted in yellow.
class OriginalTextScreen extends StatelessWidget {
  final String originalText;
  final String highlight;
  final bool rtl;
  const OriginalTextScreen({
    super.key,
    required this.originalText,
    this.highlight = '',
    this.rtl = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = originalText.isNotEmpty ? originalText : 'Original text is not available.';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenHeader(title: 'Original Document', icon: Icons.description_outlined),
      body: SafeArea(
        child: PhoneWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
            children: [
              if (highlight.trim().isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('The highlighted part is where this explanation comes from.',
                      style: TextStyle(fontSize: 15, color: AppColors.subtle)),
                ),
              SoftCard(
                child: Directionality(
                  textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                  child: _HighlightedText(text: text, highlight: highlight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  const _HighlightedText({required this.text, required this.highlight});

  @override
  Widget build(BuildContext context) {
    const base = TextStyle(fontSize: 18, height: 1.5, color: AppColors.text);
    final needle = highlight.trim();
    if (needle.isEmpty) return SelectableText(text, style: base);

    final lower = text.toLowerCase();
    final at = lower.indexOf(needle.toLowerCase());
    if (at < 0) {
      // Quote not found verbatim (translation/OCR differences); just show the text.
      return SelectableText(text, style: base);
    }
    return SelectableText.rich(
      TextSpan(style: base, children: [
        TextSpan(text: text.substring(0, at)),
        TextSpan(
          text: text.substring(at, at + needle.length),
          style: const TextStyle(backgroundColor: Color(0xFFFFE9A8), fontWeight: FontWeight.w700),
        ),
        TextSpan(text: text.substring(at + needle.length)),
      ]),
    );
  }
}

class CheckList extends StatelessWidget {
  final List<String> items;
  final IconData icon;
  final Color color;
  const CheckList({super.key, required this.items, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (final s in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(icon, size: 22, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(s,
                        style: const TextStyle(fontSize: 18, height: 1.35, color: AppColors.text)),
                  ),
                ],
              ),
            ),
        ],
      );
}
