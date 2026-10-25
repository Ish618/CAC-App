import 'package:flutter/material.dart';

import '../models/analysis.dart';
import '../services/history.dart';
import '../widgets/common.dart';
import 'overview.dart';

/// "History" tab: past results saved on this phone (text only, never photos).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Analysis>? _items;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await HistoryService.load();
    if (mounted) setState(() => _items = items);
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all?'),
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
      await _load();
    }
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final l = d.toLocal();
    return '${months[l.month - 1]} ${l.day}, ${l.year}';
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return SafeArea(
      child: PhoneWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 8, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Recent Documents',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.text)),
                  ),
                  if (items != null && items.isNotEmpty)
                    IconButton(
                      tooltip: 'Delete all',
                      iconSize: 28,
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.subtle),
                      onPressed: _confirmClear,
                    ),
                ],
              ),
            ),
            Expanded(
              child: items == null
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.history_rounded, size: 72, color: AppColors.border),
                                SizedBox(height: 14),
                                Text('No documents yet.\nScan one to see it here.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20, color: AppColors.subtle)),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                          itemCount: items.length,
                          itemBuilder: (ctx, i) {
                            final a = items[i];
                            final risk = RiskStyle.of(a.riskLevel);
                            return Dismissible(
                              key: ValueKey('${a.createdAt.toIso8601String()}_$i'),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                    color: AppColors.red, borderRadius: BorderRadius.circular(16)),
                                child: const Icon(Icons.delete, color: Colors.white, size: 30),
                              ),
                              onDismissed: (_) async {
                                setState(() => items.removeAt(i));
                                await HistoryService.removeAt(i);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (_) => OverviewScreen(analysis: a)),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: risk.background,
                                            child: Icon(risk.icon, color: risk.color, size: 26),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(a.documentType.isNotEmpty ? a.documentType : 'Document',
                                                    style: const TextStyle(
                                                        fontSize: 19,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.text)),
                                                const SizedBox(height: 2),
                                                Text('${_formatDate(a.createdAt)} · ${a.language}',
                                                    style: const TextStyle(
                                                        fontSize: 15, color: AppColors.subtle)),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right, color: AppColors.subtle, size: 28),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
