import 'package:flutter/material.dart';
import '../../models/domain_model.dart';

class LawScreen extends StatelessWidget {
  final ResultDomain domain;
  final Subcategory subcategory;

  const LawScreen({super.key, required this.domain, required this.subcategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(subcategory.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        backgroundColor: const Color(0xFF92400E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('LANDMARK VERDICTS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildVerdictCard(
            'Electoral Bonds Scheme — Struck Down',
            'Supreme Court of India — 5 Judge Bench',
            'Unanimous judgment declared electoral bonds unconstitutional. SBI ordered to submit donor data within 3 weeks.',
            'June 1, 2026',
            Icons.gavel,
            const Color(0xFF92400E),
          ),
          _buildVerdictCard(
            'Right to Privacy — Data Protection',
            'Madras High Court — Single Bench',
            'Directed state government to implement personal data protection guidelines per IT Act amendment.',
            'May 30, 2026',
            Icons.security,
            const Color(0xFF3B82F6),
          ),
          _buildVerdictCard(
            'Urban Land Ceiling Act — Repeal Case',
            'Bombay High Court — Division Bench',
            'Dismissed petition challenging the repeal of ULCA. Full judgment attached.',
            'May 28, 2026',
            Icons.location_city,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 24),
          const Text('ACTIVE GOVERNMENT TENDERS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildTenderCard('IT Infrastructure — MoE', '₹840 Cr', 'Ministry of Education', 'Bid Close: June 20, 2026', true),
          _buildTenderCard('Smart City Roads — CPWD', '₹1,240 Cr', 'Central Public Works Dept.', 'Bid Close: June 30, 2026', true),
          _buildTenderCard('Defence Electronics — DRDO', '₹3,400 Cr', 'Ministry of Defence', 'Evaluation in Progress', false),
          const SizedBox(height: 24),
          const Text('CIVIL SERVICES MERIT LISTS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildMeritCard('TN Group 2A — Final Select List', '1,200 Posts', 'Declared May 30, 2026'),
          _buildMeritCard('Kerala PSC — LDC Rank List 2026', '4,500 Posts', 'Rank List Published June 1'),
          _buildMeritCard('TNPSC Group 4 Waitlist', '800 Posts', 'Activation Expected July 2026'),
        ],
      ),
    );
  }

  Widget _buildVerdictCard(String title, String court, String summary, String date, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(court, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Text(summary, style: const TextStyle(color: Colors.grey, fontSize: 12, height: 1.5)),
          const SizedBox(height: 12),
          const Divider(),
          InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf, color: color, size: 16),
                  const SizedBox(width: 8),
                  Text('View Full Judgment', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTenderCard(String title, String value, String dept, String deadline, bool isOpen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isOpen ? Colors.green : Colors.orange).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(isOpen ? 'OPEN' : 'EVAL', style: TextStyle(color: isOpen ? Colors.green : Colors.orange, fontWeight: FontWeight.w900, fontSize: 10)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                Text(dept, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                Text(deadline, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF92400E))),
        ],
      ),
    );
  }

  Widget _buildMeritCard(String title, String posts, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.list_alt, color: Color(0xFF92400E), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                Text(posts, style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                Text(status, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
