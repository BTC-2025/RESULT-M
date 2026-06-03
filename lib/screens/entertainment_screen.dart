import 'package:flutter/material.dart';
import '../../models/domain_model.dart';

class EntertainmentScreen extends StatelessWidget {
  final ResultDomain domain;
  final Subcategory subcategory;

  const EntertainmentScreen({super.key, required this.domain, required this.subcategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(subcategory.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        backgroundColor: const Color(0xFFEC4899),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('WEEKEND BOX OFFICE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildBoxOfficeCard(1, 'Kalki 2898 AD', 'Sci-Fi Epic', '₹82 Cr', '₹1,240 Cr Total', const Color(0xFFEC4899)),
          _buildBoxOfficeCard(2, 'Stree 3', 'Horror Comedy', '₹54 Cr', '₹380 Cr Total', const Color(0xFF8B5CF6)),
          _buildBoxOfficeCard(3, 'RRR 2', 'Action Drama', '₹41 Cr', '₹220 Cr Total', const Color(0xFFFF5722)),
          _buildBoxOfficeCard(4, 'Pushpa 3', 'Action Thriller', '₹29 Cr', '₹180 Cr Total', const Color(0xFF059669)),
          const SizedBox(height: 24),
          const Text('STREAMING TOP 10 (INDIA)', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildStreamingCard(1, 'Heeramandi', 'Netflix', '24.5M Views'),
          _buildStreamingCard(2, 'Panchayat Season 3', 'Prime Video', '18.2M Views'),
          _buildStreamingCard(3, 'The Boys Season 4', 'Prime Video', '15.1M Views'),
          const SizedBox(height: 24),
          const Text('MUSIC CHARTS — TOP TRACKS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildMusicRow(1, 'Kesariya 2.0', 'Arijit Singh', '142M streams'),
          _buildMusicRow(2, 'Pasoori Nu', 'Shae Gill × Coke Studio', '118M streams'),
          _buildMusicRow(3, 'Tere Vaaste', 'Varun Jain & Sachin-Jigar', '94M streams'),
          _buildMusicRow(4, 'Kahani', 'Bombay Jayashri', '87M streams'),
          const SizedBox(height: 24),
          const Text('AWARDS SPOTLIGHT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildAwardCard('Best Picture — Oscars 2026', 'The Horizon', 'Directed by Denis Villeneuve'),
          _buildAwardCard('Best Actor — Filmfare 2026', 'Ranveer Singh', 'For "The Phoenix Chronicles"'),
          _buildAwardCard('Grammy — Album of Year', 'SZA — "LANA"', '3.2B streams globally'),
        ],
      ),
    );
  }

  Widget _buildBoxOfficeCard(int rank, String title, String genre, String weekend, String total, Color color) {
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
            width: 40, height: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            child: Center(child: Text('#$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                Text(genre, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(weekend, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: color)),
              Text(total, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMusicRow(int rank, String title, String artist, String streams) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('$rank', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.grey.shade400))),
          const SizedBox(width: 14),
          const Icon(Icons.music_note, color: Color(0xFFEC4899), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                Text(artist, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(streams, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAwardCard(String category, String winner, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEC4899).withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: const Color(0xFFEC4899).withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Color(0xFFEC4899), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(winner, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreamingCard(int rank, String title, String platform, String views) {
    Color platformColor = platform == 'Netflix' ? const Color(0xFFE50914) : const Color(0xFF00A8E1);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('$rank', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.grey.shade400))),
          const SizedBox(width: 14),
          Icon(Icons.play_circle_fill, color: platformColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                Text(platform, style: TextStyle(color: platformColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Text(views, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
