import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/domain_model.dart';
import 'result_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Map<String, dynamic>> _savedResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksStr = prefs.getString('bookmarks');
    
    if (bookmarksStr != null) {
      final List<dynamic> decoded = json.decode(bookmarksStr);
      setState(() {
        _savedResults = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        _isLoading = false;
      });
    } else {
      // Seed with initial prototype data
      final initialData = [
        {
          'name': 'John Doe',
          'roll': 'UPSC-2026-90182',
          'domain': 'UPSC CSE Prelims',
          'status': 'PASS',
          'colorValue': const Color(0xFF10B981).toARGB32(),
          'date': 'Today',
        },
        {
          'name': 'Jane Smith',
          'roll': 'ANNA-SEM4-819',
          'domain': 'B.E Semester 4',
          'status': 'FAIL',
          'colorValue': Colors.red.toARGB32(),
          'date': 'Yesterday',
        }
      ];
      await prefs.setString('bookmarks', json.encode(initialData));
      setState(() {
        _savedResults = initialData;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookmarks', json.encode(_savedResults));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('SAVED RESULTS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _savedResults.isEmpty 
          ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _savedResults.length,
            itemBuilder: (context, index) {
              final item = _savedResults[index];
              return Dismissible(
                key: Key(item['roll']),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                ),
                onDismissed: (direction) {
                  setState(() {
                    _savedResults.removeAt(index);
                  });
                  _saveBookmarks();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Result removed from saved')));
                },
                child: _buildSavedCard(item),
              );
            },
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.bookmark_border, size: 64, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 24),
          const Text('No Saved Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 8),
          const Text('Save your exam results to track them here.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildSavedCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Color(item['colorValue'] ?? 0xFF10B981).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(item['status'], style: TextStyle(color: Color(item['colorValue'] ?? 0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                ),
                Text(item['date'], style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.person_outline, color: Color(0xFF0F172A)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      Text('Roll No: ${item['roll']}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(item['domain'], style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                InkWell(
                  onTap: () {
                    // Try to find matching domain to route to ResultDetailScreen
                    final targetDomain = availableDomains.firstWhere(
                      (d) => d.subcategories.any((s) => s.name == item['domain']),
                      orElse: () => availableDomains.first, // Fallback
                    );
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ResultDetailScreen(
                        domain: targetDomain, 
                        credentials: {'Roll Number': item['roll']},
                        examName: item['domain'],
                      )
                    ));
                  },
                  child: const Row(
                    children: [
                      Text('View Full', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w900, fontSize: 13)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 14, color: Color(0xFF3B82F6)),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
