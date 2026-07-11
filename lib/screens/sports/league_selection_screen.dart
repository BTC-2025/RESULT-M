import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'match_selection_screen.dart';

class LeagueSelectionScreen extends StatefulWidget {
  final String? sportName;
  const LeagueSelectionScreen({super.key, this.sportName});

  @override
  State<LeagueSelectionScreen> createState() => _LeagueSelectionScreenState();
}

class _LeagueSelectionScreenState extends State<LeagueSelectionScreen> {
  final _searchCtrl = TextEditingController();

  final List<Map<String, String>> _allLeagues = [
    {'name': 'Indian Premier League (IPL)', 'sport': 'Cricket', 'id': 'ipl'},
    {'name': 'Indian Super League (ISL)', 'sport': 'Football', 'id': 'isl'},
    {'name': 'Pro Kabaddi League', 'sport': 'Kabaddi', 'id': 'pkl'},
    {'name': 'English Premier League', 'sport': 'Football', 'id': 'epl'},
    {'name': 'BWF World Tour', 'sport': 'Badminton', 'id': 'bwf'},
    {'name': 'ATP Tour', 'sport': 'Tennis', 'id': 'atp'},
    {'name': 'WTA Tour', 'sport': 'Tennis', 'id': 'wta'},
  ];

  List<Map<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _allLeagues;
    if (widget.sportName != null) {
      _filtered = _filtered.where((l) => l['sport']!.toLowerCase() == widget.sportName!.toLowerCase()).toList();
    }
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _allLeagues;
        if (widget.sportName != null) {
          _filtered = _filtered.where((l) => l['sport']!.toLowerCase() == widget.sportName!.toLowerCase()).toList();
        }
      } else {
        _filtered = _allLeagues
            .where((l) => l['name']!.toLowerCase().contains(query.toLowerCase()) || 
                          l['sport']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
        if (widget.sportName != null) {
          _filtered = _filtered.where((l) => l['sport']!.toLowerCase() == widget.sportName!.toLowerCase()).toList();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: context.colors.ink),
        title: Text(
          widget.sportName != null ? '${widget.sportName} Leagues' : 'Select League',
          style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.colors.border, height: 1),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearch,
              style: TextStyle(color: context.colors.ink),
              decoration: InputDecoration(
                hintText: 'Search leagues...',
                hintStyle: TextStyle(color: context.colors.inkMuted),
                filled: true,
                fillColor: context.colors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.colors.ink, width: 1.5),
                ),
                prefixIcon: Icon(Icons.search, color: context.colors.inkMuted),
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      'No leagues found.',
                      style: TextStyle(color: context.colors.inkMuted, fontSize: 14),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final league = _filtered[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          title: Text(
                            league['name']!,
                            style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          subtitle: Text(
                            league['sport']!,
                            style: TextStyle(color: context.colors.inkMuted, fontSize: 13),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios_rounded, color: context.colors.inkMuted, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MatchSelectionScreen(
                                  leagueId: league['id']!,
                                  leagueName: league['name']!,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
