import 'package:flutter/material.dart';

class FinanceResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;

  const FinanceResultScreen({super.key, required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    final symbol = data['symbol'] ?? title;
    final companyName = data['company_name'] ?? data['companyName'] ?? '';
    final price = data['current_price'] ?? data['price'] ?? '\$0.00';
    final priceChange = data['price_change'] ?? data['priceChange'] ?? '+0.00';
    final pctChange = data['percentage_change'] ?? data['percentageChange'] ?? '+0.00%';
    
    final isPositive = pctChange.toString().startsWith('+') || !pctChange.toString().startsWith('-');
    final color = isPositive ? const Color(0xFF00FF7F) : const Color(0xFFFF3B30);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                symbol.toString().toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              if (companyName.toString().isNotEmpty)
                Text(
                  companyName.toString(),
                  style: const TextStyle(color: Colors.white54, fontSize: 16),
                ),
                
              const SizedBox(height: 32),
              
              Text(
                price.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w300, letterSpacing: -2),
              ),
              Row(
                children: [
                  Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, color: color, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '$priceChange ($pctChange)',
                    style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Text('Today', style: TextStyle(color: Colors.white38, fontSize: 16)),
                ],
              ),
              
              const SizedBox(height: 64),
              
              // Mocked Sparkline Chart
              SizedBox(
                height: 120,
                width: double.infinity,
                child: CustomPaint(
                  painter: _SparklinePainter(color: color),
                ),
              ),
              
              const SizedBox(height: 64),
              
              // Stats Grid
              const Text('Stats', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _buildStatCard('Market Cap', data['market_cap'] ?? data['marketCap'] ?? '-'),
                  _buildStatCard('Volume', data['volume'] ?? '-'),
                  _buildStatCard('P/E Ratio', data['pe_ratio'] ?? data['peRatio'] ?? '-'),
                  _buildStatCard('52W High', data['high_52w'] ?? data['high52w'] ?? '-'),
                  _buildStatCard('52W Low', data['low_52w'] ?? data['low52w'] ?? '-'),
                  _buildStatCard('Div Yield', data['div_yield'] ?? data['divYield'] ?? '-'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 14)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final Color color;
  _SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.9, size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.1, size.width * 0.8, size.height * 0.4);
    path.lineTo(size.width, size.height * 0.2);

    canvas.drawPath(path, paint);
    
    // Gradient fill
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
      
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
