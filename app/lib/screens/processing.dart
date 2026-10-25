import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../languages.dart';
import '../models/analysis.dart';
import '../services/api.dart';
import '../services/history.dart';
import '../widgets/common.dart';
import 'camera.dart';
import 'overview.dart';

class ProcessingScreen extends StatefulWidget {
  final List<Uint8List> pages;
  const ProcessingScreen({super.key, required this.pages});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  late final AppLanguage _lang = AppState.language.value;
  int _step = 0; // which step is "active" (0..3), purely visual
  Timer? _timer;
  String? _error;
  Analysis? _unreadable;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _step = 0;
      _error = null;
      _unreadable = null;
    });
    // Advance the visual steps while waiting; stop at the last one until the AI answers.
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (mounted && _step < 3) setState(() => _step++);
    });
    _run();
  }

  Future<void> _run() async {
    try {
      final result = await ApiService.analyze(
        pages: widget.pages,
        language: _lang.apiName,
      );
      _timer?.cancel();
      if (!mounted) return;
      if (!result.readable) {
        setState(() => _unreadable = result);
        return;
      }
      await HistoryService.add(result);
      if (!mounted) return;
      setState(() => _step = 4);
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => OverviewScreen(analysis: result)),
      );
    } on ApiException catch (e) {
      _timer?.cancel();
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      _timer?.cancel();
      if (mounted) setState(() => _error = 'Something went wrong. Please try again.');
    }
  }

  void _retake() => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CameraScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final Widget body;
    if (_unreadable != null) {
      body = _Problem(
        icon: Icons.blur_on_rounded,
        color: AppColors.orange,
        title: _unreadable!.simpleSummary.isNotEmpty
            ? _unreadable!.simpleSummary
            : 'Please take a clearer photo.',
        message: 'Use good light, hold the phone steady, and fit the whole page in the photo.',
        primaryLabel: 'Take Another Photo',
        onPrimary: _retake,
      );
    } else if (_error != null) {
      body = _Problem(
        icon: Icons.wifi_off_rounded,
        color: AppColors.red,
        title: 'Sorry, that did not work',
        message: _error!,
        primaryLabel: 'Try Again',
        onPrimary: _start,
        secondaryLabel: 'Take Another Photo',
        onSecondary: _retake,
      );
    } else {
      body = _progress();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: PhoneWidth(child: body)),
    );
  }

  Widget _progress() {
    final steps = [
      (Icons.description_outlined, AppColors.primary, AppColors.blueBg, 'Reading text\nfrom document…'),
      (Icons.memory_rounded, AppColors.green, AppColors.greenBg, 'Analyzing\nwith AI…'),
      (Icons.language_rounded, AppColors.purple, AppColors.purpleBg, 'Translating\nto ${_lang.apiName}…'),
      (Icons.shield_outlined, AppColors.orange, AppColors.orangeBg, 'Checking\nfor scams…'),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 28),
      children: [
        const Text('Processing…',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 36),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: i <= _step ? 1 : 0.4,
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(color: steps[i].$3, shape: BoxShape.circle),
                    child: i < _step
                        ? Icon(Icons.check_rounded, size: 36, color: steps[i].$2)
                        : Icon(steps[i].$1, size: 34, color: steps[i].$2),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(steps[i].$4,
                        style: const TextStyle(fontSize: 20, height: 1.3, color: AppColors.text)),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: (_step + 1) / 5),
            duration: const Duration(milliseconds: 600),
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 10,
              backgroundColor: const Color(0xFFDDE5F3),
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text('This will only take a few seconds.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, color: AppColors.subtle)),
      ],
    );
  }
}

class _Problem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  const _Problem({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(28, 72, 28, 28),
        children: [
          Icon(icon, size: 88, color: color),
          const SizedBox(height: 20),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, height: 1.4, color: AppColors.subtle)),
          const SizedBox(height: 32),
          PrimaryButton(label: primaryLabel, onPressed: onPrimary),
          if (secondaryLabel != null) ...[
            const SizedBox(height: 12),
            SecondaryButton(label: secondaryLabel!, onPressed: onSecondary),
          ],
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Home', style: TextStyle(fontSize: 18)),
          ),
        ],
      );
}
