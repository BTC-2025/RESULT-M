import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Tech Hub — AI Benchmarks, App Store Charts, Hardware Reviews, Developer Metrics
class TechHubScreen extends StatefulWidget {
  const TechHubScreen({super.key});

  @override
  State<TechHubScreen> createState() => _TechHubScreenState();
}

class _TechHubScreenState extends State<TechHubScreen>
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
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF06B6D4),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 64),
              title: const Text('Tech Hub', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
              )),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0891B2), Color(0xFF06B6D4), Color(0xFF22D3EE)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 50),
                  child: Row(children: [
                    _Chip('AI', 'Leaderboards'),
                    const SizedBox(width: 12),
                    _Chip('GPU', 'Benchmarks'),
                    const SizedBox(width: 12),
                    _Chip('Top 100', 'Apps'),
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
                Tab(text: 'AI Models'),
                Tab(text: 'App Charts'),
                Tab(text: 'Hardware'),
                Tab(text: 'Web Traffic'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _AIModelsTab(),
            _AppChartsTab(),
            _HardwareTab(),
            _WebTrafficTab(),
          ],
        ),
      ),
    );
  }
}

// ─── AI Models Leaderboard ────────────────────────────────────────────────
class _AIModelsTab extends StatelessWidget {
  final _models = const [
    _AIModel('GPT-4o', 'OpenAI', '88.7', '91.2', '76.3', 1),
    _AIModel('Gemini 1.5 Pro', 'Google', '87.3', '89.8', '74.1', 2),
    _AIModel('Claude 3.5 Sonnet', 'Anthropic', '86.8', '88.4', '73.9', 3),
    _AIModel('Llama 3.1 405B', 'Meta', '85.1', '87.0', '71.2', 4),
    _AIModel('Mistral Large 2', 'Mistral AI', '82.4', '84.3', '68.5', 5),
    _AIModel('Gemma 2 27B', 'Google', '79.8', '81.1', '65.9', 6),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF0F172A)]),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🤖 AI MODEL LEADERBOARD', style: TextStyle(
                color: Color(0xFF22D3EE), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2,
              )),
              SizedBox(height: 4),
              Text('Based on MMLU, HumanEval & HellaSwag benchmarks', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 28),
              Expanded(child: Text('Model', style: TextStyle(color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w800))),
              SizedBox(width: 52, child: Text('MMLU', textAlign: TextAlign.center, style: TextStyle(color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w800))),
              SizedBox(width: 52, child: Text('HumanEval', textAlign: TextAlign.center, style: TextStyle(color: context.colors.inkFaint, fontSize: 9, fontWeight: FontWeight.w800))),
            ],
          ),
        ),
        ..._models.map((m) => _AIModelCard(model: m)),
      ],
    );
  }
}

class _AIModel {
  final String name, org, mmlu, humanEval, hellaSwag;
  final int rank;
  const _AIModel(this.name, this.org, this.mmlu, this.humanEval, this.hellaSwag, this.rank);
}

class _AIModelCard extends StatelessWidget {
  final _AIModel model;
  const _AIModelCard({required this.model});

  static const _rankColors = [Color(0xFFFBBF24), Color(0xFF9CA3AF), Color(0xFFB45309)];

  @override
  Widget build(BuildContext context) {
    final rankColor = model.rank <= 3 ? _rankColors[model.rank - 1] : const Color(0xFF06B6D4);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: model.rank == 1 ? rankColor.withValues(alpha: 0.4) : context.colors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('#${model.rank}', style: TextStyle(
              color: rankColor, fontWeight: FontWeight.w900, fontSize: 13,
            )),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model.name, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 14)),
                Text(model.org, style: TextStyle(color: context.colors.inkMuted, fontSize: 11)),
              ],
            ),
          ),
          SizedBox(
            width: 52,
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(model.mmlu, style: const TextStyle(
                color: Color(0xFF06B6D4), fontWeight: FontWeight.w900, fontSize: 12,
              )),
            )),
          ),
          SizedBox(
            width: 52,
            child: Center(child: Text(model.humanEval, style: TextStyle(
              color: context.colors.ink, fontWeight: FontWeight.w700, fontSize: 12,
            ))),
          ),
        ],
      ),
    );
  }
}

// ─── App Charts Tab ───────────────────────────────────────────────────────
class _AppChartsTab extends StatelessWidget {
  final _apps = const [
    _AppChart(1, 'WhatsApp', 'Meta Platforms', Icons.chat_rounded, Color(0xFF25D366), 'Free'),
    _AppChart(2, 'Instagram', 'Meta Platforms', Icons.camera_alt_rounded, Color(0xFFEC4899), 'Free'),
    _AppChart(3, 'YouTube', 'Google LLC', Icons.play_circle_rounded, Color(0xFFEF4444), 'Free'),
    _AppChart(4, 'PhonePe', 'PhonePe Pvt Ltd', Icons.payment_rounded, Color(0xFF5B21B6), 'Free'),
    _AppChart(5, 'Meesho', 'Meesho Inc.', Icons.shopping_bag_rounded, Color(0xFFF97316), 'Free'),
    _AppChart(6, 'Google Pay', 'Google LLC', Icons.g_mobiledata_rounded, Color(0xFF3B82F6), 'Free'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              Expanded(child: _PlatformTab(label: 'Android', isSelected: true)),
              Expanded(child: _PlatformTab(label: 'iOS', isSelected: false)),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _apps.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: context.colors.border),
            itemBuilder: (context, i) {
              final app = _apps[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    SizedBox(width: 28, child: Text('#${app.rank}', style: TextStyle(
                      color: app.rank <= 3 ? const Color(0xFF06B6D4) : context.colors.inkFaint,
                      fontWeight: FontWeight.w900, fontSize: 13,
                    ))),
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: app.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(app.icon, color: app.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(app.name, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800)),
                          Text(app.developer, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(app.price, style: const TextStyle(
                        color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w800,
                      )),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PlatformTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _PlatformTab({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF06B6D4) : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
      child: Center(child: Text(label, style: TextStyle(
        color: isSelected ? Colors.white : context.colors.inkMuted,
        fontWeight: FontWeight.w800, fontSize: 13,
      ))),
    );
  }
}

class _AppChart {
  final int rank;
  final String name, developer, price;
  final IconData icon;
  final Color color;
  const _AppChart(this.rank, this.name, this.developer, this.icon, this.color, this.price);
}

// ─── Hardware Tab ─────────────────────────────────────────────────────────
class _HardwareTab extends StatelessWidget {
  final _gpus = const [
    _Hardware('NVIDIA RTX 5090', '3DMark Score: 24,891', 'GPU', '+12% vs 4090'),
    _Hardware('AMD RX 9700 XT', '3DMark Score: 21,345', 'GPU', '+8% vs 7900'),
    _Hardware('Apple M4 Max', 'Geekbench ML: 19,882', 'SoC', 'Best-in-class efficiency'),
    _Hardware('Intel Core Ultra 9', 'Cinebench R24: 45,012', 'CPU', 'Top desktop score'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('HARDWARE BENCHMARKS', style: TextStyle(
          color: context.colors.inkFaint, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5,
        )),
        const SizedBox(height: 12),
        ..._gpus.map((h) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(h.type, style: const TextStyle(color: Color(0xFF06B6D4), fontSize: 10, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.name, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900)),
                    Text(h.score, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                    Text(h.delta, style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: context.colors.inkFaint, size: 14),
            ],
          ),
        )),
      ],
    );
  }
}

class _Hardware {
  final String name, score, type, delta;
  const _Hardware(this.name, this.score, this.type, this.delta);
}

// ─── Web Traffic Tab ──────────────────────────────────────────────────────
class _WebTrafficTab extends StatelessWidget {
  final _sites = const [
    _WebSite(1, 'google.com', '8.5B visits/mo', 'Search Engine'),
    _WebSite(2, 'youtube.com', '3.4B visits/mo', 'Video Platform'),
    _WebSite(3, 'facebook.com', '2.8B visits/mo', 'Social Media'),
    _WebSite(4, 'wikipedia.org', '2.4B visits/mo', 'Encyclopedia'),
    _WebSite(5, 'x.com', '1.7B visits/mo', 'Social Media'),
    _WebSite(6, 'instagram.com', '1.5B visits/mo', 'Social Media'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _sites.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: context.colors.border),
      itemBuilder: (context, i) {
        final s = _sites[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox(width: 32, child: Text('#${s.rank}', style: TextStyle(
                color: context.colors.inkFaint, fontWeight: FontWeight.w900, fontSize: 14,
              ))),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.language_rounded, color: Color(0xFF06B6D4), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.domain, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800)),
                    Text(s.category, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                  ],
                ),
              ),
              Text(s.visits, style: const TextStyle(color: Color(0xFF06B6D4), fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}

class _WebSite {
  final int rank;
  final String domain, visits, category;
  const _WebSite(this.rank, this.domain, this.visits, this.category);
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
