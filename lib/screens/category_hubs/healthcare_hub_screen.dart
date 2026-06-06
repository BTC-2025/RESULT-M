import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

/// Healthcare Hub — Hospital Reports, Medical Board Results, Health Stats
class HealthcareHubScreen extends StatefulWidget {
  const HealthcareHubScreen({super.key});

  @override
  State<HealthcareHubScreen> createState() => _HealthcareHubScreenState();
}

class _HealthcareHubScreenState extends State<HealthcareHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            backgroundColor: const Color(0xFFEF4444),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 56),
              title: const Text('Healthcare Hub', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18,
              )),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFFEF4444), Color(0xFFFCA5A5)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Row(children: [
                    _Chip('3,500+', 'Hospitals'),
                    const SizedBox(width: 12),
                    _Chip('Medical', 'Board Results'),
                    const SizedBox(width: 12),
                    _Chip('Public', 'Health Data'),
                  ]),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              tabs: const [
                Tab(text: 'Medical Exams'),
                Tab(text: 'Public Health'),
                Tab(text: 'Hospitals'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _MedicalExamsTab(),
            _PublicHealthTab(),
            _HospitalsTab(),
          ],
        ),
      ),
    );
  }
}

class _MedicalExamsTab extends StatelessWidget {
  final _exams = const [
    _MedicalExam('NEET UG 2026 Result', 'Undergraduate Medical Entrance', '22.7 Lakh Appeared', 'Result Declared', Color(0xFF10B981)),
    _MedicalExam('NEET PG 2026 Rank List', 'Postgraduate Medical', '2.0 Lakh Appeared', 'Rank List Out', Color(0xFF3B82F6)),
    _MedicalExam('FMGE June 2026', 'Foreign Medical Graduate Exam', '18,432 Candidates', 'Exam Completed', Color(0xFFF59E0B)),
    _MedicalExam('INI CET 2026', 'AIIMS / PGIMER / JIPMER', '45,231 Appeared', 'Result Awaited', Color(0xFFEF4444)),
    _MedicalExam('MDS Entrance 2026', 'Dental Postgraduate', '5,340 Candidates', 'Rank List Out', Color(0xFF8B5CF6)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _exams.map((exam) => GestureDetector(
        onTap: () => context.push('/results/healthcare/exam/${exam.title.hashCode}'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: exam.color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 4, height: 60,
                decoration: BoxDecoration(color: exam.color, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exam.title, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 14)),
                    Text(exam.subtitle, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.people_outline_rounded, size: 12, color: context.colors.inkFaint),
                      const SizedBox(width: 4),
                      Text(exam.candidates, style: TextStyle(color: context.colors.inkFaint, fontSize: 11)),
                    ]),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: exam.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Text(exam.status, style: TextStyle(color: exam.color, fontSize: 9, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _MedicalExam {
  final String title, subtitle, candidates, status;
  final Color color;
  const _MedicalExam(this.title, this.subtitle, this.candidates, this.status, this.color);
}

class _PublicHealthTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stats = [
      ['Life Expectancy', '70.8 years', 'India 2026', Color(0xFF10B981), Icons.favorite_rounded],
      ['Infant Mortality Rate', '27.4/1000', 'Per Live Births', Color(0xFFEF4444), Icons.child_care_rounded],
      ['Vaccination Coverage', '91.2%', 'DPT3 Coverage India', Color(0xFF3B82F6), Icons.vaccines_rounded],
      ['Malnutrition Rate', '19.3%', 'Children Under 5', Color(0xFFF59E0B), Icons.monitor_heart_rounded],
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...stats.map((s) => Container(
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
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: (s[3] as Color).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(s[4] as IconData, color: s[3] as Color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s[0] as String, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800)),
                    Text(s[2] as String, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                  ],
                ),
              ),
              Text(s[1] as String, style: TextStyle(
                color: s[3] as Color, fontWeight: FontWeight.w900, fontSize: 18,
              )),
            ],
          ),
        )),
      ],
    );
  }
}

class _HospitalsTab extends StatelessWidget {
  final _hospitals = const [
    _Hospital('AIIMS New Delhi', 'Government • Apex Institute', '2,000+ Beds', Color(0xFFEF4444)),
    _Hospital('Christian Medical College', 'Private • Vellore, TN', '3,000+ Beds', Color(0xFF3B82F6)),
    _Hospital('JIPMER Puducherry', 'Government • Central', '1,800+ Beds', Color(0xFF10B981)),
    _Hospital('Apollo Hospitals Chennai', 'Private • Multi-Specialty', '700+ Beds', Color(0xFF8B5CF6)),
    _Hospital('Stanley Medical Hospital', 'Government • Chennai', '1,200+ Beds', Color(0xFFF59E0B)),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _hospitals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final h = _hospitals[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: h.color.withValues(alpha: 0.12),
                child: Icon(Icons.local_hospital_rounded, color: h.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.name, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 14)),
                    Text(h.type, style: TextStyle(color: context.colors.inkMuted, fontSize: 12)),
                    Text(h.beds, style: TextStyle(color: h.color, fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.colors.inkFaint),
            ],
          ),
        );
      },
    );
  }
}

class _Hospital {
  final String name, type, beds;
  final Color color;
  const _Hospital(this.name, this.type, this.beds, this.color);
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
