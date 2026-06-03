import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool _newResults = true;
  bool _admitCards = true;
  bool _appUpdates = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _newResults = prefs.getBool('notif_new_results') ?? true;
      _admitCards = prefs.getBool('notif_admit_cards') ?? true;
      _appUpdates = prefs.getBool('notif_app_updates') ?? false;
    });
  }

  Future<void> _updatePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('NOTIFICATIONS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildToggleTile('New Results Published', 'Get notified the second a result drops', _newResults, (v) {
            setState(() => _newResults = v);
            _updatePref('notif_new_results', v);
          }),
          const SizedBox(height: 16),
          _buildToggleTile('Admit Cards Released', 'Alerts for upcoming exam hall tickets', _admitCards, (v) {
            setState(() => _admitCards = v);
            _updatePref('notif_admit_cards', v);
          }),
          const SizedBox(height: 16),
          _buildToggleTile('App Updates', 'News about ResultHub features', _appUpdates, (v) {
            setState(() => _appUpdates = v);
            _updatePref('notif_app_updates', v);
          }),
        ],
      ),
    );
  }

  Widget _buildToggleTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFFF5722),
          )
        ],
      ),
    );
  }
}
