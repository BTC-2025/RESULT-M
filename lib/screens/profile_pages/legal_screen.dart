import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('PRIVACY & LEGAL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ResultHub Privacy Policy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.2)),
            const SizedBox(height: 8),
            const Text('Last Updated: June 2026', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 32),
            
            _buildSection('1. Data Collection', 'We collect minimal data necessary to provide you with instant result updates. This includes your saved preferences, bookmarked roll numbers, and device ID for push notifications. We never sell this data.'),
            const SizedBox(height: 24),
            _buildSection('2. Result Accuracy', 'While we strive to scrape and deliver data instantly, ResultHub is an aggregator. Always verify your official scores directly with the issuing government body or university portal.'),
            const SizedBox(height: 24),
            _buildSection('3. Organization Portals', 'Organizations using our Partner Portal to publish results are responsible for the accuracy of their uploaded CSVs and data sets.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500, height: 1.6),
        ),
      ],
    );
  }
}
