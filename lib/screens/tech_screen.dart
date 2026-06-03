import 'package:flutter/material.dart';
import '../../models/domain_model.dart';

class TechScreen extends StatelessWidget {
  final ResultDomain domain;
  final Subcategory subcategory;

  const TechScreen({super.key, required this.domain, required this.subcategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(subcategory.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        backgroundColor: const Color(0xFF0EA5E9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('AI / LLM LEADERBOARD', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildBenchmarkRow(1, 'GPT-5 (OpenAI)', 'MMLU Score', '92.4%', const Color(0xFF10B981)),
          _buildBenchmarkRow(2, 'Gemini Ultra 2 (Google)', 'MMLU Score', '91.8%', const Color(0xFF3B82F6)),
          _buildBenchmarkRow(3, 'Claude 4 Opus (Anthropic)', 'MMLU Score', '90.9%', const Color(0xFF8B5CF6)),
          _buildBenchmarkRow(4, 'Llama 4 (Meta)', 'MMLU Score', '88.2%', const Color(0xFFFF5722)),
          _buildBenchmarkRow(5, 'Mistral Large 3', 'MMLU Score', '85.7%', const Color(0xFF059669)),
          const SizedBox(height: 24),
          const Text('GPU BENCHMARK LEADERBOARD', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildGpuCard(1, 'Nvidia RTX 5090', '102,400 CUDA Cores', '28,400 points', const Color(0xFF10B981)),
          _buildGpuCard(2, 'AMD RX 9800 XT', '64 CUs @ 3.2GHz', '24,800 points', const Color(0xFFFF5722)),
          _buildGpuCard(3, 'Nvidia RTX 4090', '16,384 CUDA Cores', '19,200 points', Colors.grey),
          const SizedBox(height: 24),
          const Text('TOP FREE APPS — INDIA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildAppRow(1, 'WhatsApp', 'Messaging', Icons.chat),
          _buildAppRow(2, 'PhonePe', 'Payments', Icons.payment),
          _buildAppRow(3, 'Instagram', 'Social Media', Icons.camera_alt),
          _buildAppRow(4, 'Meesho', 'Shopping', Icons.shopping_bag),
          _buildAppRow(5, 'Hotstar', 'Streaming', Icons.play_circle),
        ],
      ),
    );
  }

  Widget _buildBenchmarkRow(int rank, String model, String metric, String score, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Center(child: Text('$rank', style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 14))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                Text(metric, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Text(score, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color)),
        ],
      ),
    );
  }

  Widget _buildGpuCard(int rank, String gpu, String spec, String score, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text('#$rank', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: color))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(gpu, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                Text(spec, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Text(score, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: color)),
        ],
      ),
    );
  }

  Widget _buildAppRow(int rank, String app, String category, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Text('$rank', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.grey.shade400)),
          const SizedBox(width: 16),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFF0EA5E9).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF0EA5E9), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(app, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A))),
                Text(category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_drop_up, color: Colors.green),
        ],
      ),
    );
  }
}
