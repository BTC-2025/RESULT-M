import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class FinanceHubScreen extends StatefulWidget {
  const FinanceHubScreen({super.key});

  @override
  State<FinanceHubScreen> createState() => _FinanceHubScreenState();
}

class _FinanceHubScreenState extends State<FinanceHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFFF59E0B),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 56),
              title: const Text('Finance Hub', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
              )),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD97706), Color(0xFFF59E0B), Color(0xFFFBBF24)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Row(children: [
                    _Chip('NSE', 'Market Open'),
                    const SizedBox(width: 12),
                    _Chip('₹24,852', 'Nifty 50'),
                    const SizedBox(width: 12),
                    _Chip('+1.2%', 'Today'),
                  ]),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              isScrollable: true,
              tabs: const [
                Tab(text: 'Markets'),
                Tab(text: 'Stocks'),
                Tab(text: 'Crypto'),
                Tab(text: 'Economy'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _MarketsTab(),
            _StocksTab(),
            _CryptoTab(),
            _EconomyTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Markets Tab ──────────────────────────────────────────────────────────
class _MarketsTab extends StatelessWidget {
  final _indices = const [
    _Index('Nifty 50',    '24,852.30', '+1.2%',  true,  'NSE India'),
    _Index('Sensex',      '81,634.80', '+1.1%',  true,  'BSE India'),
    _Index('Nifty Bank',  '53,247.90', '-0.3%',  false, 'NSE India'),
    _Index('S&P 500',     '5,432.10',  '+0.8%',  true,  'NYSE'),
    _Index('Nasdaq',      '17,831.40', '+1.4%',  true,  'NASDAQ'),
    _Index('Dow Jones',   '39,127.20', '+0.6%',  true,  'NYSE'),
    _Index('Gold (MCX)',  '₹72,450',   '-0.2%',  false, 'MCX India'),
    _Index('Crude Oil',   '\$81.20',   '+1.8%',  true,  'NYMEX'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Market status banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF059669), Color(0xFF10B981)],
            ),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              const Text('Markets OPEN  •  NSE / BSE', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13,
              )),
              const Spacer(),
              const Text('Closes: 3:30 PM', style: TextStyle(
                color: Colors.white70, fontSize: 12,
              )),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('MARKET INDICES', style: TextStyle(
          color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
        )),
        const SizedBox(height: 12),
        ..._indices.map((idx) => _IndexTile(index: idx)),
      ],
    );
  }
}

class _Index {
  final String name, value, change, exchange;
  final bool isUp;
  const _Index(this.name, this.value, this.change, this.isUp, this.exchange);
}

class _IndexTile extends StatelessWidget {
  final _Index index;
  const _IndexTile({required this.index});

  @override
  Widget build(BuildContext context) {
    final color = index.isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(index.name, style: TextStyle(
                  color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 14,
                )),
                Text(index.exchange, style: TextStyle(color: context.colors.inkFaint, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(index.value, style: TextStyle(
                color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 16,
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(index.change, style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, fontSize: 12,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stocks Tab ───────────────────────────────────────────────────────────
class _StocksTab extends StatelessWidget {
  final _stocks = const [
    _Stock('RELIANCE', 'Reliance Industries', '₹2,934.50', '+2.1%', true),
    _Stock('TCS',      'Tata Consultancy',    '₹4,012.80', '+1.4%', true),
    _Stock('INFY',     'Infosys Ltd',         '₹1,678.30', '-0.8%', false),
    _Stock('HDFC',     'HDFC Bank',           '₹1,823.00', '+0.9%', true),
    _Stock('ITC',      'ITC Ltd',             '₹487.60',   '-0.3%', false),
    _Stock('WIPRO',    'Wipro Ltd',           '₹567.90',   '+2.8%', true),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: context.colors.border),
          ),
          child: TextField(
            style: TextStyle(color: context.colors.ink),
            decoration: InputDecoration(
              hintText: 'Search stocks...',
              hintStyle: TextStyle(color: context.colors.inkFaint),
              prefixIcon: Icon(Icons.search_rounded, color: context.colors.inkMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('TOP MOVERS', style: TextStyle(
          color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
        )),
        const SizedBox(height: 12),
        ..._stocks.map((s) => _StockTile(stock: s)),
      ],
    );
  }
}

class _Stock {
  final String ticker, name, price, change;
  final bool isUp;
  const _Stock(this.ticker, this.name, this.price, this.change, this.isUp);
}

class _StockTile extends StatelessWidget {
  final _Stock stock;
  const _StockTile({required this.stock});

  @override
  Widget build(BuildContext context) {
    final color = stock.isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Center(child: Text(stock.ticker[0], style: TextStyle(
              color: color, fontWeight: FontWeight.w900, fontSize: 18,
            ))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stock.ticker, style: TextStyle(
                  color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 14,
                )),
                Text(stock.name, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(stock.price, style: TextStyle(
                color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 15,
              )),
              Row(
                children: [
                  Icon(stock.isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: color, size: 16),
                  Text(stock.change, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Crypto Tab ───────────────────────────────────────────────────────────
class _CryptoTab extends StatelessWidget {
  final _cryptos = const [
    _Crypto('BTC', 'Bitcoin',   '\$67,432.00', '+3.2%', true,  '₿'),
    _Crypto('ETH', 'Ethereum',  '\$3,521.80',  '+2.1%', true,  'Ξ'),
    _Crypto('SOL', 'Solana',    '\$185.40',    '-1.4%', false, '◎'),
    _Crypto('BNB', 'BNB',       '\$412.30',    '+0.8%', true,  'B'),
    _Crypto('ADA', 'Cardano',   '\$0.638',     '-2.3%', false, 'A'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)]),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Market Cap', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('\$2.45 Trillion', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              const Text('+4.2% in 24h', style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._cryptos.map((c) => _CryptoTile(crypto: c)),
      ],
    );
  }
}

class _Crypto {
  final String symbol, name, price, change, icon;
  final bool isUp;
  const _Crypto(this.symbol, this.name, this.price, this.change, this.isUp, this.icon);
}

class _CryptoTile extends StatelessWidget {
  final _Crypto crypto;
  const _CryptoTile({required this.crypto});

  @override
  Widget build(BuildContext context) {
    final color = crypto.isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
            child: Text(crypto.icon, style: const TextStyle(
              color: Color(0xFFF59E0B), fontWeight: FontWeight.w900, fontSize: 18,
            )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(crypto.symbol, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900)),
                Text(crypto.name, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(crypto.price, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900)),
              Row(children: [
                Icon(crypto.isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: color, size: 16),
                Text(crypto.change, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Economy Tab ─────────────────────────────────────────────────────────
class _EconomyTab extends StatelessWidget {
  final _indicators = const [
    _Indicator('GDP Growth Rate', '7.8%', '+0.3%', 'India • FY 2026', true),
    _Indicator('Inflation (CPI)', '4.2%', '-0.1%', 'May 2026', false),
    _Indicator('Repo Rate', '6.50%', '—', 'RBI • Unchanged', false),
    _Indicator('Unemployment', '7.1%', '-0.4%', 'India • April 2026', false),
    _Indicator('Forex Reserves', '\$648B', '+\$2.1B', 'RBI • Weekly Update', true),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('MACRO INDICATORS', style: TextStyle(
          color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
        )),
        const SizedBox(height: 12),
        ..._indicators.map((ind) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ind.name, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800)),
                    Text(ind.subtitle, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(ind.value, style: TextStyle(
                    color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 18,
                  )),
                  if (ind.change != '—')
                    Text(ind.change, style: TextStyle(
                      color: ind.isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      fontWeight: FontWeight.w800, fontSize: 12,
                    )),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _Indicator {
  final String name, value, change, subtitle;
  final bool isPositive;
  const _Indicator(this.name, this.value, this.change, this.subtitle, this.isPositive);
}

class _Chip extends StatelessWidget {
  final String value, label;
  const _Chip(this.value, this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    ]),
  );
}
