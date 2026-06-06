import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Law / Verdict Result Detail Screen
class LawResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  const LawResultScreen({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    final verdict = data['verdict'] ?? 'Order Passed';
    final court   = data['court']   ?? 'Madras High Court';

    final isPositive = ['allowed', 'acquitted', 'bail granted'].any(
        (k) => verdict.toLowerCase().contains(k));
    final statusColor = isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF0D9488),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title, style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16,
              )),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Text('⚖️', style: TextStyle(fontSize: 60)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verdict card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(isPositive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: statusColor, size: 48),
                        const SizedBox(height: 10),
                        Text(verdict, style: TextStyle(
                          color: statusColor, fontWeight: FontWeight.w900, fontSize: 22,
                          letterSpacing: 0.5,
                        ), textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        Text(court, style: TextStyle(color: context.colors.inkMuted, fontSize: 14)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Case details
                  Text('CASE DETAILS', style: TextStyle(
                    color: context.colors.inkFaint, fontSize: 11,
                    fontWeight: FontWeight.w900, letterSpacing: 1.5,
                  )),
                  const SizedBox(height: 12),

                  _DetailRow(icon: Icons.gavel_rounded, label: 'Court', value: court),
                  _DetailRow(icon: Icons.calendar_today_rounded, label: 'Date', value: 'June 5, 2026'),
                  _DetailRow(icon: Icons.folder_rounded, label: 'Case Number', value: 'W.P.(C) 4421/2026'),
                  _DetailRow(icon: Icons.person_rounded, label: 'Petitioner', value: 'Suo Motu vs State of TN'),
                  _DetailRow(icon: Icons.account_balance_rounded, label: 'Bench', value: 'Division Bench (2 Judges)'),

                  const SizedBox(height: 20),

                  // Order summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(color: context.colors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ORDER SUMMARY', style: TextStyle(
                          color: context.colors.inkFaint, fontSize: 10,
                          fontWeight: FontWeight.w900, letterSpacing: 1.5,
                        )),
                        const SizedBox(height: 12),
                        Text(
                          'The Hon\'ble High Court, after considering the arguments of both parties, has passed an order directing the State Government to comply with the mandate within 30 days. Failure to comply will attract contempt proceedings. The court also noted that the fundamental rights of citizens must be upheld.',
                          style: TextStyle(color: context.colors.ink, height: 1.7, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Download button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Download Full Judgment'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF14B8A6),
                        side: const BorderSide(color: Color(0xFF14B8A6)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF14B8A6), size: 18),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: context.colors.inkMuted, fontSize: 13, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text(value, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 13)),
        ],
      ),
    );
  }
}
