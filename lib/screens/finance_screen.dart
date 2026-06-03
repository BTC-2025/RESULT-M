import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../models/domain_model.dart';

class FinanceScreen extends StatefulWidget {
  final ResultDomain domain;
  final Subcategory subcategory;

  const FinanceScreen({super.key, required this.domain, required this.subcategory});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  Timer? _timer;
  final Random _random = Random();
  
  int _nifty = 24512;
  int _sensex = 80234;
  double _usdInr = 83.42;

  @override
  void initState() {
    super.initState();
    // Simulate real-time WebSocket connection
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _nifty += _random.nextInt(11) - 5;
          _sensex += _random.nextInt(31) - 15;
          _usdInr += (_random.nextDouble() - 0.5) * 0.04;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatNumber(int num) {
    String s = num.toString();
    if (s.length > 3) {
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.subcategory.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
              child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF059669),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(child: _buildIndexCard('NIFTY 50', _formatNumber(_nifty), '+287', '+1.18%', true)),
              const SizedBox(width: 12),
              Expanded(child: _buildIndexCard('SENSEX', _formatNumber(_sensex), '+714', '+0.90%', true)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildIndexCard('USD/INR', _usdInr.toStringAsFixed(2), '-0.12', '-0.14%', false)),
              const SizedBox(width: 12),
              Expanded(child: _buildIndexCard('GOLD', '₹71,200', '+320', '+0.45%', true)),
            ],
          ),
          const SizedBox(height: 24),
          const Text('TOP MOVERS TODAY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildStockRow('RELIANCE', '₹2,920', '+3.4%', true),
          _buildStockRow('TCS', '₹3,840', '+1.8%', true),
          _buildStockRow('HDFC BANK', '₹1,640', '-0.9%', false),
          _buildStockRow('INFOSYS', '₹1,780', '+2.2%', true),
          _buildStockRow('BAJAJ FINANCE', '₹6,910', '-1.4%', false),
          const SizedBox(height: 24),
          const Text('CRYPTO SPOT PRICES', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          _buildCryptoRow('Bitcoin (BTC)', '\$69,240', '+2.1%', true),
          _buildCryptoRow('Ethereum (ETH)', '\$3,452', '+1.4%', true),
          _buildCryptoRow('Solana (SOL)', '\$182', '-0.8%', false),
          _buildCryptoRow('BNB', '\$608', '+0.3%', true),
        ],
      ),
    );
  }

  Widget _buildIndexCard(String name, String value, String change, String pct, bool isUp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: isUp ? Colors.green : Colors.red, size: 18),
              Text('$change  $pct', style: TextStyle(color: isUp ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          _buildMiniChart(isUp),
        ],
      ),
    );
  }

  Widget _buildMiniChart(bool isUp) {
    final color = isUp ? Colors.green : Colors.red;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(12, (index) {
        // Randomize bar heights dynamically
        final height = _random.nextDouble() * 20.0 + (isUp ? index : (12 - index)) * 1.0 + 5.0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 4,
          height: height > 30 ? 30 : height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildStockRow(String symbol, String price, String change, bool isUp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bar_chart, color: Color(0xFF059669), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(symbol, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF0F172A)))),
          Text(price, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF0F172A))),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isUp ? Colors.green : Colors.red).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(change, style: TextStyle(color: isUp ? Colors.green : Colors.red, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptoRow(String name, String price, String change, bool isUp) {
    return _buildStockRow(name, price, change, isUp);
  }
}
