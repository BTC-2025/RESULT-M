import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../core/storage/secure_storage.dart';
import '../../screens/splash_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/signup_screen.dart';
import '../../screens/organization_signup_screen.dart';
import '../../screens/forgot_password_screen.dart';
import '../../screens/otp_verification_screen.dart';

import '../../screens/local_workspace_screen.dart';
import '../../screens/workspace_resolver_screen.dart';
import '../../screens/main_shell.dart';
import '../../screens/home_screen.dart';
import '../../screens/results_hub_screen.dart';
import '../../screens/explore_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/notifications_screen.dart';
import '../../screens/complaints/complaint_detail_screen.dart';
import '../../screens/complaints/complaint_feed_screen.dart';
import '../../screens/complaints/create_complaint_screen.dart';
import '../../screens/voting/vote_box_detail_screen.dart';
import '../../screens/voting/voting_hub_screen.dart';
import '../../screens/voting/create_vote_box_screen.dart';
import '../../screens/dataset_search_screen.dart';
import '../../screens/admin/create_organization_screen.dart';
import '../../screens/admin/admin_scaffold.dart';

import '../../models/complaint_model.dart';
import '../../screens/public_profile_screen.dart';
import '../../screens/profile_pages/follow_network_screen.dart';
import '../../screens/messages/inbox_screen.dart';
import '../../screens/messages/chat_screen.dart';
import '../../screens/post_detail_screen.dart';
import '../../screens/public_dataset_screen.dart';
import '../../screens/results/domain_explorer_screen.dart';
// ─── Category Hub Screens ─────────────────────────────────────────────────
import '../../screens/category_hubs/academic_hub_screen.dart';
import '../../screens/academic/school_hub_screen.dart';
import '../../screens/academic/university_hub_screen.dart';

import '../../screens/category_hubs/government_hub_screen.dart';
import '../../screens/government/department_selection_screen.dart';

import '../../screens/category_hubs/law_hub_screen.dart';
import '../../screens/law/court_selection_screen.dart';

import '../../screens/category_hubs/healthcare_hub_screen.dart';
import '../../screens/healthcare/hospital_selection_screen.dart';

import '../../screens/category_hubs/sports_hub_screen.dart';
import '../../screens/sports/cricket_hub_screen.dart';
import '../../screens/sports/football_hub_screen.dart';
import '../../screens/sports/league_selection_screen.dart';
import '../../screens/results/football_score_screen.dart';
import '../../services/sports_api_service.dart';

import '../../screens/category_hubs/entertainment_hub_screen.dart';
import '../../screens/entertainment/award_show_selection_screen.dart';

import '../../screens/category_hubs/tech_hub_screen.dart';
import '../../screens/tech/benchmark_category_screen.dart';

import '../../screens/category_hubs/politics_hub_screen.dart';
import '../../screens/politics/election_state_screen.dart';

import '../../screens/category_hubs/finance_hub_screen.dart';
import '../../screens/category_hubs/business_hub_screen.dart';
import '../../screens/category_hubs/hyperlocal_hub_screen.dart';

// ─── Admin Screens ────────────────────────────────────────────────────────
import '../../screens/admin/workspace_creation_screen.dart';
import '../../screens/admin/dataset_creation_screen.dart';
import '../../screens/admin/csv_upload_screen.dart';
import '../../screens/admin/search_keys_mapping_screen.dart';

// ─── Result Detail Screens ────────────────────────────────────────────────
import '../../screens/results/cricket_score_screen.dart';
import '../../screens/results/election_result_screen.dart';
import '../../screens/results/finance_result_screen.dart';
import '../../screens/results/business_result_screen.dart';
import '../../screens/results/hyperlocal_result_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  redirect: (context, state) async {
    final storage = SecureStorage();
    final token = await storage.getToken();
    final role = await storage.getRole();
    final location = state.uri.path;

    final isLoggingIn = location == '/login' || location == '/signup' || location == '/signup/organization' || location == '/forgot-password' || location == '/otp-verify' || location == '/splash' || location == '/onboarding';

    // Protected routes that guests CANNOT access
    final protectedRoutes = [
      '/profile',
      '/notifications',
      '/inbox',
      '/chat',
      '/admin',
      '/create-organization',
      '/complaints/new',
      '/votes/new'
    ];

    final isProtectedRoute = protectedRoutes.any((route) => location.startsWith(route));

    if (token == null || token.isEmpty) {
      // If they are trying to access a protected route, send to login
      if (isProtectedRoute) return '/login';
      // Otherwise allow them to browse as guest (return null)
      return null;
    }

    // Block logged in users from accessing auth pages
    if (isLoggingIn && location != '/splash') {
      if (role == 'ORGANIZATION') {
        return '/admin/dashboard';
      } else {
        return '/';
      }
    }

    // Role-based route segregation guards
    if (role == 'ORGANIZATION') {
      final allowedRoutes = ['/admin', '/create-organization', '/login', '/signup', '/splash', '/onboarding', '/profile/network', '/profile/public'];
      bool isAllowed = false;
      for (final route in allowedRoutes) {
        if (location.startsWith(route)) {
          isAllowed = true;
          break;
        }
      }
      if (!isAllowed) {
        return '/admin/dashboard';
      }
    } else { // Standard USER or ADMIN role
      if (location.startsWith('/admin') || location == '/create-organization') {
        return '/';
      }
    }

    return null;
  },
  routes: [
    // ─── Full-screen routes (outside shell) ─────────────────────────────────
    GoRoute(path: '/splash',     builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(CurveTween(curve: Curves.easeOutCubic).animate(animation)),
              child: child,
            ),
          );
        },
      ),
    ),
    GoRoute(
      path: '/signup',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/signup/organization',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OrganizationSignupScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/otp-verify',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final email = extra['email'] as String? ?? '';
        final flow = extra['flow'] as OtpFlow? ?? OtpFlow.forgotPassword;
        return OtpVerificationScreen(email: email, flow: flow);
      },
    ),
    GoRoute(
      path: '/notifications',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/create-organization',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateOrganizationScreen(),
    ),


    // ─── Dynamic Domain Explorer ─────────────────────────────────────────────
    GoRoute(
      path: '/domain/:type',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final type = state.pathParameters['type']!;
        return DomainExplorerScreen(domainType: type);
      },
    ),
    GoRoute(
      path: '/domain/:type/category/:parentId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final type = state.pathParameters['type']!;
        final parentId = state.pathParameters['parentId']!;
        final title = state.uri.queryParameters['title'];
        return DomainExplorerScreen(
          domainType: type,
          parentId: parentId,
          title: title,
        );
      },
    ),

    // ─── Category Hub Routes ─────────────────────────────────────────────────
    GoRoute(
      path: '/results/academic',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AcademicHubScreen(),
    ),
    GoRoute(
      path: '/results/academic/university',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const UniversityHubScreen(),
    ),
    GoRoute(
      path: '/results/academic/school',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SchoolHubScreen(),
    ),
    GoRoute(
      path: '/results/academic/entrance',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AcademicHubScreen(),
    ),
    GoRoute(
      path: '/results/academic/institution/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AcademicHubScreen(),
    ),
    GoRoute(
      path: '/results/sports',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SportsHubScreen(),
    ),
    GoRoute(
      path: '/results/sports/cricket',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CricketHubScreen(),
    ),
    GoRoute(
      path: '/results/sports/cricket/live/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final match = state.extra as CricketMatch;
        return CricketScoreScreen(match: match);
      },
    ),
    GoRoute(
      path: '/results/sports/football',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FootballHubScreen(),
    ),
    GoRoute(
      path: '/results/sports/football/live/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final match = state.extra as FootballMatch?;
        return FootballScoreScreen(match: match);
      },
    ),
    GoRoute(
      path: '/results/sports/:sport',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final sport = state.pathParameters['sport'];
        final sportName = sport != null && sport.isNotEmpty
            ? '${sport[0].toUpperCase()}${sport.substring(1)}'
            : 'Sport';
        return LeagueSelectionScreen(sportName: sportName);
      },
    ),
    GoRoute(
      path: '/results/finance',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FinanceHubScreen(),
    ),
    GoRoute(
      path: '/results/finance/:section',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const FinanceHubScreen(),
    ),
    GoRoute(
      path: '/results/finance/markets/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => FinanceResultScreen(
        data: const {'index': 'Nifty 50', 'value': '24852.30'},
        title: 'Market Overview',
      ),
    ),
    GoRoute(
      path: '/results/politics',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PoliticsHubScreen(),
    ),
    GoRoute(
      path: '/results/politics/election/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ElectionResultScreen(
        data: const {'title': 'Election Results', 'constituencies': []},
        title: 'Election Results',
      ),
    ),
    GoRoute(
      path: '/results/politics/:section',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const PoliticsHubScreen(),
    ),
    GoRoute(
      path: '/results/government',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const GovernmentHubScreen(),
    ),
    GoRoute(
      path: '/results/government/departments',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DepartmentSelectionScreen(),
    ),
    GoRoute(
      path: '/results/law',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LawHubScreen(),
    ),
    GoRoute(
      path: '/results/law/courts',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CourtSelectionScreen(),
    ),
    GoRoute(
      path: '/results/healthcare',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const HealthcareHubScreen(),
    ),
    GoRoute(
      path: '/results/healthcare/hospitals',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const HospitalSelectionScreen(),
    ),
    GoRoute(
      path: '/results/sports/leagues',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LeagueSelectionScreen(),
    ),
    GoRoute(
      path: '/results/entertainment/shows',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AwardShowSelectionScreen(),
    ),
    GoRoute(
      path: '/results/tech/benchmarks',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BenchmarkCategoryScreen(),
    ),
    GoRoute(
      path: '/results/politics/states',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ElectionStateScreen(),
    ),
    GoRoute(
      path: '/results/entertainment',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EntertainmentHubScreen(),
    ),
    GoRoute(
      path: '/results/tech',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TechHubScreen(),
    ),
    GoRoute(
      path: '/results/business',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BusinessHubScreen(),
    ),
    GoRoute(
      path: '/results/business/earnings/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BusinessResultScreen(
        title: 'Q2 Earnings',
        data: const {'company': 'Reliance Ind.', 'quarter': 'Q2 2026', 'revenue': '₹2.4L Cr', 'net_profit': '₹19,300 Cr', 'yoy_growth': '+12%'},
      ),
    ),
    GoRoute(
      path: '/results/hyperlocal',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const HyperLocalHubScreen(),
    ),
    GoRoute(
      path: '/results/hyperlocal/sports/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => HyperLocalResultScreen(
        title: 'Local Event',
        data: const {'event_name': 'District Cricket Final', 'location': 'Marina Ground, Ward 114', 'date': 'June 5, 2026', 'winner': 'Star CC', 'runner_up': 'Blue Boys CC'},
      ),
    ),
    GoRoute(
      path: '/complaints',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ComplaintFeedScreen(),
    ),
    GoRoute(
      path: '/votes',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const VotingHubScreen(),
    ),
    GoRoute(
      path: '/profile/public/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final name = state.uri.queryParameters['name'] ?? 'Member';
        return PublicProfileScreen(userId: id, userName: name);
      },
    ),
    GoRoute(
      path: '/profile/network/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final initialTab = state.uri.queryParameters['initialTab'] ?? 'followers';
        return FollowNetworkScreen(userId: id, initialTab: initialTab);
      },
    ),
    GoRoute(
      path: '/post/details/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PostDetailScreen(postId: id);
      },
    ),
    GoRoute(
      path: '/inbox',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const InboxScreen(),
    ),
    GoRoute(
      path: '/chat/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final name = state.uri.queryParameters['name'] ?? 'User';
        return ChatScreen(otherUserId: id, otherUserName: name);
      },
    ),

    // ─── Workspace deep links ────────────────────────────────────────────────
    GoRoute(
      path: '/w/:slug',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        final code = state.uri.queryParameters['code'];
        return WorkspaceResolverScreen(slug: slug, initialCode: code);
      },
    ),
    GoRoute(
      path: '/workspace/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id   = state.pathParameters['id']!;
        final name = state.uri.queryParameters['name'] ?? 'Workspace';
        return LocalWorkspaceScreen(workspaceId: id, workspaceName: name);
      },
    ),

    // ─── Dataset search deep links ───────────────────────────────────────────
    GoRoute(
      path: '/dataset/public/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final name = state.uri.queryParameters['name'] ?? 'Dataset';
        final domainType = state.uri.queryParameters['domainType'] ?? 'Dataset';
        return PublicDatasetScreen(
          datasetId: id,
          datasetName: name,
          domainType: domainType,
        );
      },
    ),
    GoRoute(
      path: '/dataset/:id/search',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final name = state.uri.queryParameters['name'] ?? 'Dataset';
        final domainType = state.uri.queryParameters['domainType'] ?? 'Dataset';
        return DatasetSearchScreen(
          datasetId: id,
          datasetName: name,
          domainType: domainType,
        );
      },
    ),

    // ─── Complaint deep links ────────────────────────────────────────────────
    GoRoute(
      path: '/complaints/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateComplaintScreen(),
    ),
    GoRoute(
      path: '/complaints/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ComplaintDetailScreen(
          complaint: ComplaintModel(
            id:           id,
            category:     'Other',
            title:        'Loading...',
            description:  '',
            mediaUrls:    const [],
            status:       'OPEN',
            isAnonymous:  false,
            flagCount:    0,
            upvotes:      0,
            downvotes:    0,
            netScore:     0,
            commentCount: 0,
            createdAt:    DateTime.now(),
            updatedAt:    DateTime.now(),
          ),
        );
      },
    ),

    // ─── Voting deep links ───────────────────────────────────────────────────
    GoRoute(
      path: '/votes/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CreateVoteBoxScreen(),
    ),
    GoRoute(
      path: '/votes/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return VoteBoxDetailScreen(voteBoxId: id);
      },
    ),

    // ─── Admin Routes ───────────────────────────────────────────────────────
    GoRoute(
      path: '/admin/create',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WorkspaceCreationScreen(),
    ),
    GoRoute(
      path: '/admin/dashboard',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AdminScaffold(),
    ),
    GoRoute(
      path: '/admin/dataset/create',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const DatasetCreationScreen(),
    ),
    GoRoute(
      path: '/admin/dataset/csv-upload',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final datasetName = state.extra as String? ?? 'New Dataset';
        return CsvUploadScreen(datasetName: datasetName);
      },
    ),
    GoRoute(
      path: '/admin/dataset/mapping',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final headers = state.extra as List<String>? ?? [];
        return SearchKeysMappingScreen(headers: headers);
      },
    ),

    // ─── Bottom Navigation Shell ─────────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShellScreen(navigationShell: navigationShell),
      branches: [
        // Tab 0 — Home (social feed)
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => HomeScreen(
              initialExpandedPostId: state.uri.queryParameters['expand'],
            ),
          ),
        ]),
        // Tab 1 — Results hub
        StatefulShellBranch(routes: [
          GoRoute(path: '/results', builder: (context, state) => const ResultsHubScreen()),
        ]),
        // Tab 2 — Explore / Discovery
        StatefulShellBranch(routes: [
          GoRoute(path: '/explore', builder: (context, state) => const ExploreScreen()),
        ]),
        // Tab 3 — Profile
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ]),
      ],
    ),
  ],
);
