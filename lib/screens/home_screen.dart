import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:marquee/marquee.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/domain_model.dart';
import '../services/api_service.dart';
import 'subcategory_screen.dart';
import 'profile_screen.dart';
import 'search_results_screen.dart';
import 'notifications_screen.dart';
import 'credential_screen.dart';
import 'create_workspace_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final bool _isSearchVisible = false;

  void _navigateToDomain(BuildContext context, ResultDomain domain) {
    if (domain.subcategories.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SubcategoryScreen(domain: domain)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active events right now.')),
      );
    }
  }

  void _showJoinWorkspaceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Join Workspace', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the secure link or ID provided by the workspace admin.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'e.g. rhub.io/xyz-123',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.link),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Joined Workspace Successfully!'), backgroundColor: Colors.green));
            },
            child: const Text('Join', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showWorkspaceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0F172A).withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.add, color: Color(0xFF0F172A))),
                title: const Text('Create New Workspace', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                subtitle: const Text('Host results for your organization'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateWorkspaceScreen()));
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.login, color: Color(0xFF10B981))),
                title: const Text('Join Workspace', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                subtitle: const Text('Enter a link or code to join'),
                onTap: () {
                  Navigator.pop(context);
                  _showJoinWorkspaceDialog(context);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: CustomScrollView(
        slivers: [
          // 1. Complete Custom Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5722).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.emoji_events, color: Color(0xFFFF5722), size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'ResultHub',
                            style: TextStyle(color: Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search, color: Color(0xFF0F172A)),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchResultsScreen()));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_none, color: Color(0xFF0F172A)),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade200, width: 2),
                              ),
                              child: const CircleAvatar(
                                radius: 18,
                                backgroundColor: Color(0xFFF8F9FA),
                                child: Icon(Icons.person, color: Color(0xFF0F172A), size: 20),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Find Your Results',
                    style: TextStyle(color: Color(0xFF0F172A), fontSize: 32, fontWeight: FontWeight.w900, height: 1.1),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Access live scores, academic marks, and government exam updates instantly.',
                    style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    child: _isSearchVisible 
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              const Text(
                                'TRENDING SEARCHES',
                                style: TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildTrendingChip('UPSC CSE 2026'),
                                  _buildTrendingChip('NSE Nifty 50'),
                                  _buildTrendingChip('IPL Final'),
                                  _buildTrendingChip('SC Verdict'),
                                  _buildTrendingChip('Oscars 2026'),
                                  _buildTrendingChip('ChatGPT vs Gemini'),
                                ],
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Professional Edge-to-Edge Sharp Live Ticker
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.symmetric(horizontal: BorderSide(color: Colors.grey.shade300, width: 1)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: const Color(0xFF0F172A), // Premium Dark
                        child: Row(
                          children: const [
                            Icon(Icons.circle, size: 10, color: Color(0xFFFF5722)), // Sporty Orange
                            SizedBox(width: 8),
                            Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: [Colors.white.withValues(alpha: 0.0), Colors.white, Colors.white, Colors.white.withValues(alpha: 0.0)],
                              stops: const [0.0, 0.05, 0.95, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Marquee(
                            text: '🚨 CBSE Class 12 Results Declared! Check now...    📈 Nifty crosses 24,500 mark...    ⚖️ SC Strikes Down Electoral Bonds...    🏏 IPL 2026 Points Table updated...    🗳️ Election counting live updates...',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 14),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            blankSpace: 50.0,
                            velocity: 35.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Dynamic Categories
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'EXPLORE CATEGORIES',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 1.5),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: availableDomains.length,
                    itemBuilder: (context, index) {
                      final domain = availableDomains[index];
                      return DynamicCategoryCard(
                        domain: domain,
                        onTap: () => _navigateToDomain(context, domain),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // 3. Trending Carousel (Fetching from Spring Boot API)
                FutureBuilder<List<dynamic>>(
                  future: ref.read(apiServiceProvider).fetchPublicWorkspaces(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 160.0,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    
                    List<dynamic> apiWorkspaces = snapshot.data ?? [];
                    List<Widget> carouselItems = [];

                    if (apiWorkspaces.isNotEmpty) {
                      // We have data from Spring Boot API
                      for (var w in apiWorkspaces) {
                        carouselItems.add(_buildCarouselCard(
                          w['name'] ?? 'Workspace', 
                          w['description'] ?? 'Updates', 
                          w['domainType'] ?? 'General', 
                          const Color(0xFF0F172A), 
                          const Color(0xFFFF5722)
                        ));
                      }
                    } else {
                      // Fallback UI if backend is offline or empty
                      carouselItems = [
                        _buildCarouselCard('INDIA vs AUS', 'Final Score 284/6', 'Live Now', const Color(0xFF0F172A), const Color(0xFFFF5722)),
                        _buildCarouselCard('Lok Sabha By-Polls', 'Live Seat Count', 'Elections', const Color(0xFF8B5CF6), const Color(0xFF0F172A)),
                        _buildCarouselCard('UPSC CSE 2026', 'Final Results Declared', 'Trending', const Color(0xFF4F46E5), const Color(0xFF10B981)),
                        _buildCarouselCard('Market Highs', 'NIFTY touches 24,500', 'Finance', const Color(0xFF059669), const Color(0xFF0F172A)),
                        _buildCarouselCard('Academy Awards', 'Best Picture Winner', 'Entertainment', const Color(0xFFEC4899), const Color(0xFF0F172A)),
                      ];
                    }

                    return CarouselSlider(
                      options: CarouselOptions(
                        height: 160.0,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 0.9,
                        autoPlayInterval: const Duration(seconds: 5),
                      ),
                      items: carouselItems,
                    );
                  },
                ),
                
                // 4. Latest Updates Feed
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Text(
                    'LATEST UPDATES',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 1.5),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: _getLatestUpdates(context),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showWorkspaceOptions(context),
        backgroundColor: const Color(0xFF0F172A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Workspace', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildCarouselCard(String title, String subtitle, String tag, Color bgColor, Color tagColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(4)),
            child: Text(tag.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTrendingChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }

  List<Widget> _getLatestUpdates(BuildContext context) {
    // Gather all "Live" and "Upcoming" events to populate a massive dummy list
    List<Widget> cards = [];
    for (var domain in availableDomains) {
      final activeEvents = domain.subcategories.where((s) => s.status != EventStatus.past).take(3);
      for (var sub in activeEvents) {
        cards.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CredentialScreen(domain: domain, subcategory: sub)));
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5722).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFF5722).withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            domain.name.toUpperCase(),
                            style: const TextStyle(color: Color(0xFFFF5722), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                        ),
                        const Icon(Icons.bookmark_border, color: Colors.grey, size: 20),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(sub.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A), height: 1.3)),
                    const SizedBox(height: 8),
                    Text('Scraped automatically from: ${sub.agencyName ?? "Official Board"}', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(sub.dateStr ?? '6/1/2026', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Row(
                          children: const [
                            Text('View Details', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w900, fontSize: 14)),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 16, color: Color(0xFF3B82F6)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }
    return cards;
  }
}

class DynamicCategoryCard extends StatefulWidget {
  final ResultDomain domain;
  final VoidCallback onTap;

  const DynamicCategoryCard({super.key, required this.domain, required this.onTap});

  @override
  State<DynamicCategoryCard> createState() => _DynamicCategoryCardState();
}

class _DynamicCategoryCardState extends State<DynamicCategoryCard> {
  bool _isPressed = false;

  Color _getPrimaryColor(DomainType type) {
    // Colors are now managed by ResultDomain.displayColor
    return widget.domain.displayColor;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getPrimaryColor(widget.domain.type);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.diagonal3Values(_isPressed ? 0.95 : 1.0, _isPressed ? 0.95 : 1.0, 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPressed
              ? []
              : [BoxShadow(color: bgColor.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Animated Watermark Texture
              AnimatedPositioned(
                duration: const Duration(milliseconds: 150),
                right: _isPressed ? -15 : -25,
                bottom: _isPressed ? -15 : -25,
                child: Icon(
                  widget.domain.icon,
                  size: 110,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(widget.domain.icon, color: Colors.white, size: 24),
                    ),
                    const Spacer(),
                    Text(
                      widget.domain.name.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.domain.subcategories.length} Updates',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w600, fontSize: 10),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
