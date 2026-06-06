import 'package:flutter/material.dart';

// ─── Shared Utilities ─────────────────────────────────────────────────────────

String _formatKey(String key) {
  String spaced = key.replaceAll(RegExp(r'(?<=[a-z])[A-Z]'), r' $0').replaceAll('_', ' ');
  if (spaced.isEmpty) return key;
  return spaced.trim().split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

// ─── 1. Academic & Education ────────────────────────────────────────────────
class AcademicResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const AcademicResultCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Basic heuristic: keys with "name", "id", "roll" go to header.
    // "total", "grade", "pass", "status" go to summary.
    // Everything else goes to the grid.
    final headerData = <String, String>{};
    final subjects = <String, String>{};
    String? status;

    for (var entry in data.entries) {
      final k = entry.key.toLowerCase();
      if (k.contains('name') || k.contains('roll') || k.contains('id') || k.contains('school')) {
        headerData[_formatKey(entry.key)] = entry.value.toString();
      } else if (k.contains('status') || k.contains('grade') || k.contains('result')) {
        status = entry.value.toString();
      } else {
        subjects[_formatKey(entry.key)] = entry.value.toString();
      }
    }

    final isPass = status?.toLowerCase().contains('pass') ?? true;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 2)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                Icon(Icons.school, size: 40, color: Colors.blue.shade800),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: headerData.entries.map((e) => Text(
                      '${e.key}: ${e.value}',
                      style: TextStyle(
                        fontSize: e.key.toLowerCase().contains('name') ? 16 : 12,
                        fontWeight: e.key.toLowerCase().contains('name') ? FontWeight.bold : FontWeight.normal,
                        color: Colors.blue.shade900,
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Subjects Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade200),
              columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: const [
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: EdgeInsets.all(8.0), child: Text('Marks', style: TextStyle(fontWeight: FontWeight.bold))),
                  ]
                ),
                ...subjects.entries.map((e) => TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8.0), child: Text(e.key, style: const TextStyle(fontSize: 13))),
                    Padding(padding: const EdgeInsets.all(8.0), child: Text(e.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                  ]
                )),
              ],
            ),
          ),

          // Status Stamp
          if (status != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: isPass ? Colors.green : Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: isPass ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── 2. Politics & Elections ────────────────────────────────────────────────
class ElectionResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const ElectionResultCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade100),
        boxShadow: [BoxShadow(color: Colors.indigo.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.how_to_vote, color: Colors.indigo.shade600),
              const SizedBox(width: 8),
              Text('ELECTION DATA', style: TextStyle(color: Colors.indigo.shade600, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            ],
          ),
          const SizedBox(height: 16),
          ...data.entries.map((e) {
            // Check if value is a percentage to render a progress bar
            bool isPercentage = e.value.toString().contains('%');
            double? parsedVal;
            if (isPercentage) {
              parsedVal = double.tryParse(e.value.toString().replaceAll('%', ''));
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatKey(e.key), style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
                      Text(e.value.toString(), style: const TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                  if (parsedVal != null) ...[
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: parsedVal / 100,
                      backgroundColor: Colors.indigo.shade50,
                      color: Colors.indigo.shade500,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─── 3. Sports & Gaming (Default) ─────────────────────────────────────────────
class SportsResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const SportsResultCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827), // Dark aesthetic
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports_esports, color: Colors.greenAccent),
              const SizedBox(width: 8),
              const Text('MATCH STATS', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 16,
            children: data.entries.map((e) {
              return Container(
                width: (MediaQuery.of(context).size.width - 90) / 2, // 2 columns
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_formatKey(e.key).toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(e.value.toString(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── 4. Finance & Markets ───────────────────────────────────────────────────
class FinanceResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const FinanceResultCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: const [
                Icon(Icons.trending_up, color: Colors.tealAccent),
                SizedBox(width: 8),
                Text('FINANCIAL REPORT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: data.entries.map((e) {
                final isNegative = e.value.toString().startsWith('-');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatKey(e.key), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          if (e.value.toString().contains('%') || e.value.toString().startsWith('\$'))
                            Icon(isNegative ? Icons.arrow_downward : Icons.arrow_upward, 
                                 color: isNegative ? Colors.red : Colors.green, size: 14),
                          const SizedBox(width: 4),
                          Text(e.value.toString(), style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: (e.value.toString().contains('%') || e.value.toString().startsWith('\$')) 
                                ? (isNegative ? Colors.red : Colors.green) 
                                : Colors.black87,
                          )),
                        ],
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 5. Entertainment & Media ───────────────────────────────────────────────
class EntertainmentResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const EntertainmentResultCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.purple.shade900, Colors.black]),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 40),
          const SizedBox(height: 8),
          const Text('AWARDS & CHARTS', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 20),
          ...data.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatKey(e.key), style: const TextStyle(color: Colors.white70)),
                Text(e.value.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ─── 6. Tech & Innovation ───────────────────────────────────────────────────
class TechResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const TechResultCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('> SYS_BENCHMARK_RESULTS', style: TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...data.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Text('${_formatKey(e.key)}: ', style: const TextStyle(color: Colors.white54, fontFamily: 'monospace')),
                Expanded(child: Text(e.value.toString(), style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontWeight: FontWeight.bold))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ─── 7. Law & Judiciary ─────────────────────────────────────────────────────
class LawResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const LawResultCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7), // Parchment color
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.brown.shade800, width: 2),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.balance, color: Colors.brown.shade800, size: 40),
          const SizedBox(height: 12),
          Text('OFFICIAL DECREE', style: TextStyle(color: Colors.brown.shade800, fontWeight: FontWeight.w900, fontFamily: 'serif', letterSpacing: 2, fontSize: 18)),
          const Divider(color: Colors.brown, thickness: 2, height: 32),
          ...data.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_formatKey(e.key).toUpperCase(), style: TextStyle(color: Colors.brown.shade600, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(e.value.toString(), style: const TextStyle(color: Colors.black87, fontFamily: 'serif', fontSize: 15, height: 1.5)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
