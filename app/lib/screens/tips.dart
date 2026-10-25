import 'package:flutter/material.dart';

import '../widgets/common.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScreenHeader(title: 'Tips & Resources', icon: Icons.shield_outlined),
      body: SafeArea(
        child: PhoneWidth(
          child: _TipsBody(),
        ),
      ),
    );
  }
}

class _TipsBody extends StatelessWidget {
  const _TipsBody();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
        children: const [
          _TipCard(
            icon: Icons.gpp_bad,
            color: AppColors.red,
            background: AppColors.redBg,
            title: 'Warning signs of a scam',
            items: [
              'Asks you to pay with gift cards, wire transfer, or crypto',
              'Says you must act today or be arrested',
              'Asks for your password, PIN, or a code sent to your phone',
              'Tells you to keep it secret from family',
              'Offers far less money than your land or property is worth',
            ],
          ),
          SizedBox(height: 14),
          _TipCard(
            icon: Icons.check_circle,
            color: AppColors.green,
            background: AppColors.greenBg,
            title: 'Safe habits',
            items: [
              'Never sign a paper you do not understand',
              'Call the company using the number on its official website, not the paper',
              'Ask a trusted family member before paying or signing',
              'Keep copies of every document you sign',
            ],
          ),
          SizedBox(height: 14),
          _TipCard(
            icon: Icons.support_agent_rounded,
            color: AppColors.primary,
            background: AppColors.blueBg,
            title: 'Where to get free help',
            items: [
              'Call 211 (USA) for free local help in many languages',
              'Free legal aid offices help with leases, debts, and benefits',
              'Report scams at ReportFraud.ftc.gov (USA)',
              'Local community and senior centers',
            ],
          ),
          SizedBox(height: 14),
          Text('General guidance, not legal advice.',
              style: TextStyle(fontSize: 15, color: AppColors.subtle)),
        ],
      );
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final List<String> items;
  const _TipCard({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) => SoftCard(
        color: background,
        borderColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CheckList(items: items, icon: Icons.arrow_right_rounded, color: color),
          ],
        ),
      );
}
