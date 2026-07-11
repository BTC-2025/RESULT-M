import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

// ─────────────────────────────────────────────
// Data model for slide pages
// ─────────────────────────────────────────────
class _SlideData {
  final String tag;
  final String headline;
  final String body;
  final Color accent;
  final Color bgTop;
  final Color bgBot;
  final List<_MiniCard> cards;

  const _SlideData({
    required this.tag,
    required this.headline,
    required this.body,
    required this.accent,
    required this.bgTop,
    required this.bgBot,
    required this.cards,
  });
}

class _MiniCard {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _MiniCard(this.icon, this.label, this.value, this.color);
}

const List<_SlideData> _slides = [
  // ─── Slide 1: Live Results ───
  _SlideData(
    tag: 'LIVE RESULTS',
    headline: 'Everything,\nLive.',
    body:
        'IPL scores ticking by the ball. Election counts rolling in state-by-state. Exam results the moment they drop. ResultHub brings it all to your feed — in real time.',
    accent: Color(0xFFFF5A1F),
    bgTop: Color(0xFF0F172A),
    bgBot: Color(0xFF1E293B),
    cards: [
      _MiniCard(Icons.sports_cricket, 'MI vs CSK', '247 / 4 (18.2)', Color(0xFF22C55E)),
      _MiniCard(Icons.how_to_vote, 'Tamil Nadu', '214 / 234 counted', Color(0xFF3B82F6)),
      _MiniCard(Icons.school, 'Anna Univ.', 'Results LIVE', Color(0xFFFF5A1F)),
    ],
  ),
  // ─── Slide 2: Social Feed ───
  _SlideData(
    tag: 'SOCIAL FEED',
    headline: 'Your Feed,\nYour Rules.',
    body:
        'A home feed like X and Instagram — live score bubbles at the top, poll posts, complaints, results cards scrolling below. Follow what matters to you.',
    accent: Color(0xFF6366F1),
    bgTop: Color(0xFF0C0E1A),
    bgBot: Color(0xFF1A1C31),
    cards: [
      _MiniCard(Icons.bar_chart, 'Sports Feed', 'IPL • F1 • FIFA', Color(0xFF22C55E)),
      _MiniCard(Icons.campaign, 'Complaints', '1.2k posts today', Color(0xFFEF4444)),
      _MiniCard(Icons.poll, 'Polls', '48 active now', Color(0xFF8B5CF6)),
    ],
  ),
  // ─── Slide 3: Complaint Box ───
  _SlideData(
    tag: 'COMPLAINT BOX',
    headline: 'Speak Up.\nBe Heard.',
    body:
        'Post complaints with photos and location. Vote up issues that matter. Watch admins respond and close them. A Reddit-style board for real-world problems.',
    accent: Color(0xFFEF4444),
    bgTop: Color(0xFF1A0A0A),
    bgBot: Color(0xFF2D1212),
    cards: [
      _MiniCard(Icons.thumb_up, 'Upvotes', '3.4k this week', Color(0xFF22C55E)),
      _MiniCard(Icons.check_circle, 'Resolved', '89% rate', Color(0xFF3B82F6)),
      _MiniCard(Icons.location_on, 'Geo-tagged', 'Pin your block', Color(0xFFEF4444)),
    ],
  ),
  // ─── Slide 4: Voting Hub ───
  _SlideData(
    tag: 'VOTING HUB',
    headline: 'Poll the\nWorld.',
    body:
        'Create polls visible to the public, password-locked, or private. Vote anonymously or as yourself. Watch real-time percentage bars fill up live.',
    accent: Color(0xFF8B5CF6),
    bgTop: Color(0xFF0E0A1A),
    bgBot: Color(0xFF1A1030),
    cards: [
      _MiniCard(Icons.public, 'Public Polls', 'No login needed', Color(0xFF8B5CF6)),
      _MiniCard(Icons.lock, 'Private', 'Password gate', Color(0xFF6366F1)),
      _MiniCard(Icons.trending_up, 'Live Bars', 'Instant results', Color(0xFF22C55E)),
    ],
  ),
];

// ─────────────────────────────────────────────
// Interest categories for the final step
// ─────────────────────────────────────────────
class _InterestCategory {
  final IconData icon;
  final String label;
  final Color color;
  const _InterestCategory(this.icon, this.label, this.color);
}

const List<_InterestCategory> _categories = [
  _InterestCategory(Icons.sports_cricket, 'Sports', Color(0xFF22C55E)),
  _InterestCategory(Icons.school, 'Exams', Color(0xFF3B82F6)),
  _InterestCategory(Icons.how_to_vote, 'Elections', Color(0xFFEF4444)),
  _InterestCategory(Icons.account_balance, 'Government', Color(0xFFF59E0B)),
  _InterestCategory(Icons.trending_up, 'Finance', Color(0xFF8B5CF6)),
  _InterestCategory(Icons.gavel, 'Law', Color(0xFF6366F1)),
  _InterestCategory(Icons.movie, 'Entertainment', Color(0xFFF43F5E)),
  _InterestCategory(Icons.computer, 'Tech', Color(0xFF14B8A6)),
  _InterestCategory(Icons.campaign, 'Complaints', Color(0xFFFF5A1F)),
  _InterestCategory(Icons.location_city, 'Local', Color(0xFF0EA5E9)),
];

// ─────────────────────────────────────────────
// Main Widget
// ─────────────────────────────────────────────
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Set<String> _selected = {};

  // total pages = slides + 1 interest page
  int get _totalPages => _slides.length + 1;
  bool get _isLastPage => _currentPage == _totalPages - 1;

  late AnimationController _dotController;
  late AnimationController _cardController;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardFade = CurvedAnimation(parent: _cardController, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));
    _cardController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dotController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_isLastPage) {
      _finish();
    } else {
      _cardController.reset();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
    _cardController.reset();
    _cardController.forward();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    // Save selected interests
    await prefs.setStringList('user_interests', _selected.toList());
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // ─── Page content ───
          PageView.builder(
            controller: _pageController,
            itemCount: _totalPages,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              if (index < _slides.length) {
                return _SlidePage(
                  data: _slides[index],
                  cardFade: _cardFade,
                  cardSlide: _cardSlide,
                );
              }
              return _InterestPage(
                categories: _categories,
                selected: _selected,
                onToggle: (label) => setState(() {
                  if (_selected.contains(label)) {
                    _selected.remove(label);
                  } else {
                    _selected.add(label);
                  }
                }),
              );
            },
          ),

          // ─── Bottom bar (dots + buttons) ───
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBar(
              currentPage: _currentPage,
              totalPages: _totalPages,
              isLastPage: _isLastPage,
              onNext: _goNext,
              onSkip: _finish,
              selectedCount: _selected.length,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Slide Page (slides 0-3)
// ─────────────────────────────────────────────
class _SlidePage extends StatelessWidget {
  final _SlideData data;
  final Animation<double> cardFade;
  final Animation<Offset> cardSlide;

  const _SlidePage({
    required this.data,
    required this.cardFade,
    required this.cardSlide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [data.bgTop, data.bgBot],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),

            // ─── Tag pill ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: data.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: data.accent.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: data.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      data.tag,
                      style: TextStyle(
                        color: data.accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ─── Headline ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                data.headline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  letterSpacing: -1,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── Body text ───
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                data.body,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 15,
                  height: 1.65,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Spacer(),

            // ─── Animated mini cards ───
            FadeTransition(
              opacity: cardFade,
              child: SlideTransition(
                position: cardSlide,
                child: SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: data.cards.length,
                    separatorBuilder: (context, idx) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => _MiniCardWidget(card: data.cards[i]),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 120), // space for bottom bar
          ],
        ),
      ),
    );
  }
}

class _MiniCardWidget extends StatelessWidget {
  final _MiniCard card;
  const _MiniCardWidget({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: card.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(card.icon, color: card.color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                card.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Interest selection page (last page)
// ─────────────────────────────────────────────
class _InterestPage extends StatelessWidget {
  final List<_InterestCategory> categories;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _InterestPage({
    required this.categories,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF111827)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: context.colors.orange.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: context.colors.orange.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.interests, color: context.colors.orange, size: 12),
                        SizedBox(width: 6),
                        Text(
                          'PERSONALISE',
                          style: TextStyle(
                            color: context.colors.orange,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'What do you\nfollow?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Pick at least one. We\'ll tailor your feed with live scores, results, and polls that match.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── Category grid ───
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 120),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.8,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = selected.contains(cat.label);
                    return _CategoryChip(
                      category: cat,
                      isSelected: isSelected,
                      onTap: () => onToggle(cat.label),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final _InterestCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? category.color.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? category.color.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? category.color.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                category.icon,
                color: isSelected ? category.color : Colors.white.withValues(alpha: 0.5),
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                category.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: category.color, size: 16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Bottom navigation bar (persistent overlay)
// ─────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool isLastPage;
  final VoidCallback onNext;
  final Future<void> Function() onSkip;
  final int selectedCount;

  const _BottomBar({
    required this.currentPage,
    required this.totalPages,
    required this.isLastPage,
    required this.onNext,
    required this.onSkip,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.85)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // ─── Dot indicators ───
          Row(
            children: List.generate(totalPages, (i) {
              final isActive = i == currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                margin: const EdgeInsets.only(right: 6),
                width: isActive ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive
                      ? context.colors.orange
                      : Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const Spacer(),

          // ─── Skip button ───
          if (!isLastPage)
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),

          const SizedBox(width: 8),

          // ─── Next / Get Started button ───
          GestureDetector(
            onTap: isLastPage && selectedCount == 0 ? null : onNext,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
              decoration: BoxDecoration(
                gradient: isLastPage && selectedCount == 0
                    ? const LinearGradient(colors: [Color(0xFF4B5563), Color(0xFF374151)])
                    : const LinearGradient(
                        colors: [Color(0xFFFF5A1F), Color(0xFFE84A10)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: isLastPage && selectedCount == 0
                    ? []
                    : [
                        BoxShadow(
                          color: context.colors.orange.withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLastPage
                        ? selectedCount == 0
                            ? 'Pick at least 1'
                            : 'Let\'s Go!'
                        : 'Next',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (!(isLastPage && selectedCount == 0)) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

