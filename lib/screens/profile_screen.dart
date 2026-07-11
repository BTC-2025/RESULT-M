import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:convert';
import '../services/auth_service.dart';
import '../core/theme/app_theme.dart';
import '../providers/theme_provider.dart';
import 'package:go_router/go_router.dart';
import 'login_screen.dart';
import 'bookmarks_screen.dart';
import 'profile_pages/recently_viewed_screen.dart';
import 'profile_pages/notifications_settings_screen.dart';
import 'profile_pages/language_screen.dart';
import 'profile_pages/help_center_screen.dart';
import 'profile_pages/legal_screen.dart';
import 'profile_pages/personal_details_screen.dart';
import 'profile_pages/security_settings_screen.dart';
import 'profile_pages/my_workspaces_screen.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  User? _firebaseUser;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Re-check auth status when profile screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuthStatus();
    });

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _firebaseUser = user;
        });
      }
    });
  }


  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  bool _isLoggedIn(AuthState authState) => authState.isLoggedIn || _firebaseUser != null;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = _isLoggedIn(authState);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        title: Text('PROFILE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, color: context.colors.ink)),
        centerTitle: false,
        backgroundColor: context.colors.bg,
        foregroundColor: context.colors.ink,
        elevation: 0,
      ),
      body: SingleChildScrollView(
            child: Column(
              children: [
                // Header (Conditional based on Auth state)
                isLoggedIn ? _buildUserHeader(context, authState) : _buildGuestHeader(context),
                
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ACCOUNT', style: TextStyle(color: context.colors.inkFaint, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      _buildMenuGroup(context, [
                        if (isLoggedIn)
                          _buildRouteItem(context, Icons.chat_bubble_outline, 'Messages Inbox', '/inbox'),
                        if (isLoggedIn)
                          _buildMenuItem(context, Icons.person_outline, 'Personal Details', const PersonalDetailsScreen()),
                        if (isLoggedIn)
                          _buildMenuItem(context, Icons.security_outlined, 'Security Settings', const SecuritySettingsScreen()),
                        if (isLoggedIn)
                          _buildMenuItem(context, Icons.workspaces, 'My Workspaces', const MyWorkspacesScreen()),
                        _buildMenuItem(context, Icons.bookmark_border, 'Saved Results', const BookmarksScreen()),
                        _buildMenuItem(context, Icons.history, 'Recently Viewed', const RecentlyViewedScreen()),
                      ]),
                      
                      const SizedBox(height: 32),
                      Text('PREFERENCES', style: TextStyle(color: context.colors.inkFaint, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      _buildMenuGroup(context, [
                        _buildThemeToggle(context, ref),
                        _buildMenuItem(context, Icons.notifications_none, 'Push Notifications', const NotificationsSettingsScreen()),
                        _buildMenuItem(context, Icons.language, 'Language (English)', const LanguageScreen()),
                      ]),

                      const SizedBox(height: 32),
                      Text('SUPPORT & LEGAL', style: TextStyle(color: context.colors.inkFaint, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const SizedBox(height: 12),
                      _buildMenuGroup(context, [
                        _buildMenuItem(context, Icons.help_outline, 'Help Center', const HelpCenterScreen()),
                        _buildMenuItem(context, Icons.privacy_tip_outlined, 'Privacy Policy', const LegalScreen()),
                        _buildActionItem(context, Icons.info_outline, 'About ResultHub', () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'ResultHub',
                            applicationVersion: '1.0.0',
                            applicationIcon: Icon(Icons.emoji_events, size: 64, color: context.colors.orange),
                            children: [Text('The ultimate platform for exam and academic results.', style: TextStyle(color: context.colors.ink))]
                          );
                        }),
                      ]),
                      
                      if (isLoggedIn) ...[
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () async {
                              // Logout from both Backend and Firebase
                              await AuthService().logout();
                              await FirebaseAuth.instance.signOut();
                              ref.read(authProvider.notifier).logout();
                              if (context.mounted) {
                                // Full state reset via routing to Splash
                                context.go('/splash');
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: context.colors.liveRed, width: 2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('LOGOUT', style: TextStyle(color: context.colors.liveRed, fontWeight: FontWeight.w900, letterSpacing: 1)),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                      Center(
                        child: Text('Version 1.0.0', style: TextStyle(color: context.colors.inkFaint, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                )
              ],
            ),
            ),
          );
  }

  Widget _buildThemeToggle(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.dark_mode_outlined, color: context.colors.ink, size: 22),
          const SizedBox(width: 16),
          Expanded(child: Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.colors.ink))),
          DropdownButton<ThemeMode>(
            value: themeMode,
            underline: const SizedBox(),
            icon: Icon(Icons.keyboard_arrow_down, color: context.colors.inkMuted),
            dropdownColor: context.colors.surfaceAlt,
            style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700, fontSize: 13),
            items: const [
              DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
              DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
            ],
            onChanged: (mode) {
              if (mode != null) ref.read(themeProvider.notifier).setTheme(mode);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuestHeader(BuildContext context) {
    return Container(
      color: context.colors.bg,
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.colors.orange, context.colors.orangeGlow],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: context.colors.orange.withValues(alpha: 0.2), blurRadius: 20, offset: Offset(0, 10))],
        ),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('Unlock Full Access', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              'Save your results, get notified instantly, and sync across devices.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: context.colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('LOGIN OR REGISTER', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            )
          ],
        ),
      ),
    );
  }
  Widget _buildUserHeader(BuildContext context, AuthState authState) {
    String displayName = authState.name ?? 'Member';
    String displayEmail = authState.email ?? 'Authenticated Account';
    String? photoUrl;

    if (_firebaseUser != null) {
      displayName = _firebaseUser!.displayName ?? displayName;
      displayEmail = _firebaseUser!.email ?? _firebaseUser!.phoneNumber ?? displayEmail;
      photoUrl = _firebaseUser!.photoURL;
    }

    String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'M';
    
    ImageProvider? imageProvider;
    if (authState.profilePictureBase64 != null && authState.profilePictureBase64!.startsWith('data:image')) {
      try {
        final base64Str = authState.profilePictureBase64!.split(',').last;
        imageProvider = MemoryImage(base64Decode(base64Str));
      } catch (e) {
        // Fallback
      }
    } else if (photoUrl != null && photoUrl.isNotEmpty) {
      imageProvider = NetworkImage(photoUrl);
    }

    return Container(
      color: context.colors.bg,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: imageProvider == null ? LinearGradient(
                colors: [context.colors.orange, context.colors.orangeGlow],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) : null,
              image: imageProvider != null ? DecorationImage(image: imageProvider, fit: BoxFit.cover) : null,
              boxShadow: [
                BoxShadow(color: context.colors.orange.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
              ],
            ),
            alignment: Alignment.center,
            child: imageProvider == null 
                ? Text(initial, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white))
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName, 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: context.colors.ink, letterSpacing: -0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  displayEmail, 
                  style: TextStyle(color: context.colors.inkMuted, fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMenuGroup(BuildContext context, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget item = entry.value;
          return Column(
            children: [
              item,
              if (idx < items.length - 1)
                Divider(height: 1, indent: 56, color: context.colors.border),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Widget destination) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: context.colors.ink, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.colors.ink))),
            Icon(Icons.arrow_forward_ios, size: 14, color: context.colors.inkMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteItem(BuildContext context, IconData icon, String title, String route) {
    return InkWell(
      onTap: () {
        context.push(route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: context.colors.ink, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.colors.ink))),
            Icon(Icons.arrow_forward_ios, size: 14, color: context.colors.inkMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: context.colors.ink, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: context.colors.ink))),
            Icon(Icons.arrow_forward_ios, size: 14, color: context.colors.inkMuted),
          ],
        ),
      ),
    );
  }
}
