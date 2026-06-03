import 'package:flutter/material.dart';
import '../../models/domain_model.dart';

class PoliticsScreen extends StatelessWidget {
  final ResultDomain domain;
  final Subcategory subcategory;

  const PoliticsScreen({super.key, required this.domain, required this.subcategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(subcategory.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Live Ticker
          _buildLiveHeader(),
          const SizedBox(height: 20),
          const Text('LEADING PARTIES', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildPartyRow('Bharatiya Janata Party (BJP)', 248, 272, const Color(0xFFFF5722)),
          _buildPartyRow('Indian National Congress (INC)', 114, 272, const Color(0xFF3B82F6)),
          _buildPartyRow('Aam Aadmi Party (AAP)', 32, 272, const Color(0xFF10B981)),
          _buildPartyRow('YSRCP', 18, 272, const Color(0xFF8B5CF6)),
          _buildPartyRow('Others & Independents', 28, 272, Colors.grey),
          const SizedBox(height: 28),
          const Text('CONSTITUENCY UPDATES', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildConstituencyCard('Mumbai North', 'BJP — Piyush Goyal', 'Leading by 12,400 votes', true),
          _buildConstituencyCard('Chennai Central', 'DMK — Dayanidhi Maran', 'Won by 34,210 votes', false),
          _buildConstituencyCard('New Delhi', 'AAP — Atishi', 'Counting in progress...', true),
        ],
      ),
    );
  }

  Widget _buildLiveHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, color: Colors.white, size: 10),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Live: 12 of 28 constituencies declared — Results update every 2 minutes',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildPartyRow(String party, int seats, int total, Color color) {
    final pct = seats / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(party, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF0F172A)))),
              Text('$seats seats', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.grey.shade200,
              color: color,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          Text('${(pct * 100).toStringAsFixed(1)}% vote share', style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildConstituencyCard(String name, String candidate, String status, bool isLive) {
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
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color: isLive ? const Color(0xFFFF5722) : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(candidate, style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold, fontSize: 12)),
                Text(status, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
