import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Entertainment Hub — Box Office, Awards, Reality Shows, Music Charts
class EntertainmentHubScreen extends StatefulWidget {
  const EntertainmentHubScreen({super.key});

  @override
  State<EntertainmentHubScreen> createState() => _EntertainmentHubScreenState();
}

class _EntertainmentHubScreenState extends State<EntertainmentHubScreen>
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
            backgroundColor: const Color(0xFFEC4899),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 56),
              title: const Text('Entertainment', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
              )),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFBE185D), Color(0xFFEC4899), Color(0xFFF9A8D4)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Row(children: [
                    _Chip('BOX OFFICE', 'This Weekend'),
                    const SizedBox(width: 12),
                    _Chip('73rd', 'National Awards'),
                    const SizedBox(width: 12),
                    _Chip('🎬', 'Cinema'),
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
                Tab(text: 'Box Office'),
                Tab(text: 'Awards'),
                Tab(text: 'Music Charts'),
                Tab(text: 'Reality Shows'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _BoxOfficeTab(),
            _AwardsTab(),
            _MusicChartsTab(),
            _RealityShowsTab(),
          ],
        ),
      ),
    );
  }
}

class _BoxOfficeTab extends StatelessWidget {
  final _movies = const [
    _Movie('Kalki 2898 AD', 'Pan-India Release', '₹1,200 Cr', '18 Days', true, 1),
    _Movie('Pushpa 3', 'Telugu / Hindi', '₹890 Cr', '7 Days', true, 2),
    _Movie('Singham Again 3', 'Bollywood', '₹340 Cr', '3 Days', false, 3),
    _Movie('Mufasa: The Lion King', 'Hollywood', '₹120 Cr', '10 Days', false, 4),
    _Movie('Amaran', 'Tamil / Hindi', '₹280 Cr', '15 Days', false, 5),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFBE185D), Color(0xFFEC4899)]),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WEEKEND BOX OFFICE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
              SizedBox(height: 4),
              Text('Global Collection — Weekend of Jun 6–8, 2026', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._movies.map((m) => _MovieCard(movie: m)),
      ],
    );
  }
}

class _Movie {
  final String title, type, collection, period;
  final bool isNew;
  final int rank;
  const _Movie(this.title, this.type, this.collection, this.period, this.isNew, this.rank);
}

class _MovieCard extends StatelessWidget {
  final _Movie movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: movie.rank == 1
            ? const Color(0xFFEC4899).withValues(alpha: 0.4)
            : context.colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: movie.rank == 1
                  ? const Color(0xFFEC4899)
                  : const Color(0xFFEC4899).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Center(child: Text('#${movie.rank}', style: TextStyle(
              color: movie.rank == 1 ? Colors.white : const Color(0xFFEC4899),
              fontWeight: FontWeight.w900, fontSize: 16,
            ))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(movie.title, style: TextStyle(
                    color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 14,
                  )),
                  if (movie.isNew) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text('NEW', style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ]),
                Text('${movie.type} • ${movie.period}', style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(movie.collection, style: const TextStyle(
            color: Color(0xFFEC4899), fontWeight: FontWeight.w900, fontSize: 15,
          )),
        ],
      ),
    );
  }
}

class _AwardsTab extends StatelessWidget {
  final _awards = const [
    _Award('Best Film', 'Kalki 2898 AD', 'National Film Awards 2026'),
    _Award('Best Director', 'S.S. Rajamouli', 'National Film Awards 2026'),
    _Award('Best Actor', 'Prabhas', 'National Film Awards 2026'),
    _Award('Best Actress', 'Deepika Padukone', 'National Film Awards 2026'),
    _Award('Best Supporting Actor', 'Kamal Haasan', 'National Film Awards 2026'),
    _Award('Best Tamil Film', 'Amaran', 'National Film Awards 2026'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFBBF24).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Text('🏆', style: TextStyle(fontSize: 28)),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('73rd National Film Awards', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  Text('Ceremony: June 3, 2026 • New Delhi', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._awards.map((a) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              const Text('🥇', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.category, style: TextStyle(color: context.colors.inkMuted, fontSize: 11, fontWeight: FontWeight.w700)),
                    Text(a.winner, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _Award {
  final String category, winner, ceremony;
  const _Award(this.category, this.winner, this.ceremony);
}

class _MusicChartsTab extends StatelessWidget {
  final _songs = const [
    _Song(1, 'Jai Hanuman', 'Hanuman (2025)', 'Prashanth Varma', '🎵'),
    _Song(2, 'Kesariya Remix', 'Brahmāstra', 'Pritam', '🎵'),
    _Song(3, 'Ponni Nadhi', 'Ponniyin Selvan', 'A.R. Rahman', '🎵'),
    _Song(4, 'Naatu Naatu', 'RRR (International)', 'M.M. Keeravani', '🎵'),
    _Song(5, 'What Jhumka', 'Rocky Aur Rani', 'Pritam', '🎵'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _songs.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: context.colors.border),
      itemBuilder: (context, i) {
        final s = _songs[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox(width: 28, child: Text('#${s.rank}', style: TextStyle(
                color: s.rank <= 3 ? const Color(0xFFEC4899) : context.colors.inkFaint,
                fontWeight: FontWeight.w900, fontSize: 14,
              ))),
              Text(s.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.title, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800)),
                    Text('${s.movie} • ${s.artist}', style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.play_circle_outline_rounded, color: const Color(0xFFEC4899), size: 28),
            ],
          ),
        );
      },
    );
  }
}

class _Song {
  final int rank;
  final String title, movie, artist, emoji;
  const _Song(this.rank, this.title, this.movie, this.artist, this.emoji);
}

class _RealityShowsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final shows = [
      ['Bigg Boss 18 (Tamil)', 'Running • Week 14', 'Eviction: Sneha Eliminated'],
      ['Indian Idol Season 16', 'Running • Top 6', 'Performance: Sunday 9 PM'],
      ['Shark Tank India S4', 'Finale Next Week', 'Winner Announcement Pending'],
      ['Koffee With Karan 9', 'Episode 12 Released', 'Guest: Ranveer & Alia'],
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: shows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final s = shows[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: const Icon(Icons.tv_rounded, color: Color(0xFFEC4899), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s[0], style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900)),
                    Text(s[1], style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                    Text(s[2], style: TextStyle(color: const Color(0xFFEC4899), fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
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
