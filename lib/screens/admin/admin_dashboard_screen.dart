import 'package:flutter/material.dart';
import 'quick_score_entry_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('OVERVIEW', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF10B981),
        onRefresh: () async {
          // Simulate fetching fresh metrics
          await Future.delayed(const Duration(seconds: 2));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Gradient Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.account_balance, color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Anna University', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                            ),
                            child: const Text('Verified Partner', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Metrics Section
              const Text('TODAY\'S METRICS', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStatCard('Total Lookups', '124K', Icons.visibility, const Color(0xFF3B82F6))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard('New Results', '3', Icons.publish, const Color(0xFF10B981))),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatCard('Total Students Reached', '2.4M', Icons.groups, const Color(0xFFFF5722), isFullWidth: true),
              
              const SizedBox(height: 40),

              // System Alerts Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('SYSTEM ALERTS', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  Text('See all', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 16),
              _buildAlertItem('High Traffic Detected', 'B.E Semester 4 results are driving 10k lookups/min. Infrastructure scaled automatically.', Icons.speed, Colors.orange),
              _buildAlertItem('API Sync Successful', 'Student database synced at 12:00 PM without any packet loss.', Icons.check_circle, const Color(0xFF10B981)),
              
              const SizedBox(height: 40),
              
              // Live Datasets Section for Quick Updates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('LIVE DATASETS', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 16),
              _buildLiveDatasetItem(context, 'B.E Semester 4 Results', '12,450 records', "dataset-id-1", "record-id-1"),
              _buildLiveDatasetItem(context, 'Anna University Athletics 2026', 'Scores Updating', "dataset-id-2", "record-id-2"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveDatasetItem(BuildContext context, String title, String subtitle, String datasetId, String recordId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.sensors, color: Color(0xFF10B981), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.flash_on, color: Colors.amberAccent, size: 16),
            label: const Text('Quick Update', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => QuickScoreEntryScreen(
                  workspaceId: "dummy-workspace",
                  datasetId: datasetId,
                  recordId: recordId,
                ),
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {bool isFullWidth = false}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: isFullWidth ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF0F172A), height: 1.1)),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
        ],
      ) : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 24),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Color(0xFF0F172A), height: 1.1)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                        const SizedBox(height: 6),
                        Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500, fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
