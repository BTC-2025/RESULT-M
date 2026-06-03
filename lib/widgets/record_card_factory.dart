import 'package:flutter/material.dart';
import '../models/domain_model.dart';

class RecordCardFactory extends StatelessWidget {
  final DomainType domainType;
  final Map<String, dynamic> record;

  const RecordCardFactory({
    super.key,
    required this.domainType,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    try {
      switch (domainType) {
        case DomainType.sport:
          return _buildSportCard();
        case DomainType.finance:
          return _buildFinanceCard();
        case DomainType.politics:
          return _buildPoliticsCard();
        case DomainType.law:
          return _buildLawCard();
        case DomainType.entertainment:
          return _buildEntertainmentCard();
        case DomainType.tech:
          return _buildTechCard();
        default:
          return _buildGenericCard();
      }
    } catch (e) {
      // Graceful fallback if anything goes wrong during specialized rendering
      return _buildGenericCard();
    }
  }

  // ── SPORT ──
  Widget _buildSportCard() {
    // Check if required keys exist
    if (!record.containsKey('team1') && !record.containsKey('team')) {
      return _buildGenericCard();
    }

    final team1 = record['team1']?.toString() ?? record['team']?.toString() ?? 'Team A';
    final team2 = record['team2']?.toString() ?? 'Team B';
    final score1 = record['score1']?.toString() ?? record['score']?.toString() ?? '0';
    final score2 = record['score2']?.toString() ?? '0';
    final status = record['status']?.toString() ?? 'Live';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(team1, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A))),
              Text(score1, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFFFF5722))),
            ],
          ),
          if (record.containsKey('team2')) ...[
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(team2, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A))),
                Text(score2, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.grey)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(4)),
            child: Text(
              status.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1),
            ),
          )
        ],
      ),
    );
  }

  // ── FINANCE ──
  Widget _buildFinanceCard() {
    if (!record.containsKey('symbol') && !record.containsKey('company')) {
      return _buildGenericCard();
    }

    final symbol = record['symbol']?.toString() ?? record['company']?.toString() ?? 'SYM';
    final name = record['name']?.toString() ?? 'Company';
    final price = record['price']?.toString() ?? '0.00';
    final change = record['change']?.toString() ?? '0%';

    final isPositive = change.startsWith('+') || (!change.startsWith('-') && change != '0%');
    final changeColor = isPositive ? const Color(0xFF10B981) : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(symbol, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
              const SizedBox(height: 4),
              Text(name, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: changeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(change, style: TextStyle(color: changeColor, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── POLITICS ──
  Widget _buildPoliticsCard() {
    if (!record.containsKey('candidate') && !record.containsKey('party')) {
      return _buildGenericCard();
    }

    final candidate = record['candidate']?.toString() ?? 'Candidate';
    final party = record['party']?.toString() ?? 'Party';
    final votes = record['votes']?.toString() ?? '0';
    final percentage = record['percentage']?.toString() ?? '0';

    double percentValue = double.tryParse(percentage.replaceAll('%', '')) ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(candidate, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Text(party, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(votes, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF8B5CF6))),
                  const Text('Votes', style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentValue / 100.0,
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF8B5CF6),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text('$percentage%', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ── LAW ──
  Widget _buildLawCard() {
    if (!record.containsKey('caseTitle') && !record.containsKey('court')) {
      return _buildGenericCard();
    }

    final caseTitle = record['caseTitle']?.toString() ?? 'Unknown Case';
    final court = record['court']?.toString() ?? 'Court';
    final verdict = record['verdict']?.toString() ?? 'Pending';
    final date = record['date']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(caseTitle, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.account_balance, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(court, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              if (date.isNotEmpty) ...[
                const SizedBox(width: 12),
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF92400E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              verdict.toUpperCase(),
              style: const TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
            ),
          )
        ],
      ),
    );
  }

  // ── ENTERTAINMENT ──
  Widget _buildEntertainmentCard() {
    if (!record.containsKey('title')) return _buildGenericCard();

    final title = record['title']?.toString() ?? 'Title';
    final rank = record['rank']?.toString() ?? '';
    final metric = record['metric']?.toString() ?? record['boxOffice']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (rank.isNotEmpty)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: const Color(0xFFEC4899).withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Center(child: Text(rank, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFEC4899)))),
            ),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
          ),
          if (metric.isNotEmpty)
            Text(metric, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  // ── TECH ──
  Widget _buildTechCard() {
    if (!record.containsKey('productName') && !record.containsKey('device')) {
      return _buildGenericCard();
    }

    final product = record['productName']?.toString() ?? record['device']?.toString() ?? 'Device';
    final score = record['score']?.toString() ?? record['benchmark']?.toString() ?? '';
    final rank = record['rank']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                if (rank.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text('Rank: $rank', style: const TextStyle(color: Color(0xFF0EA5E9), fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
                ]
              ],
            ),
          ),
          if (score.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(score, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
                const Text('Score', style: TextStyle(color: Colors.grey, fontSize: 10)),
              ],
            ),
        ],
      ),
    );
  }

  // ── GENERIC FALLBACK ──
  Widget _buildGenericCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: record.entries.map((e) {
          final keyStr = e.key.replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ').replaceAll('_', ' ');
          final formattedKey = keyStr.toUpperCase();
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$formattedKey: ', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                Expanded(child: Text('${e.value}', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
