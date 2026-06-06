import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../screens/splash_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/signup_screen.dart';
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
import '../../screens/post_detail_screen.dart';
import '../../screens/public_dataset_screen.dart';
// ─── Category Hub Screens ─────────────────────────────────────────────────
import '../../screens/category_hubs/academic_hub_screen.dart';
import '../../screens/category_hubs/sports_hub_screen.dart';
import '../../screens/category_hubs/finance_hub_screen.dart';
import '../../screens/category_hubs/politics_hub_screen.dart';
import '../../screens/category_hubs/government_hub_screen.dart';
import '../../screens/category_hubs/law_hub_screen.dart';
import '../../screens/category_hubs/entertainment_hub_screen.dart';
import '../../screens/category_hubs/tech_hub_screen.dart';
import '../../screens/category_hubs/healthcare_hub_screen.dart';
import '../../screens/category_hubs/business_hub_screen.dart';
import '../../screens/category_hubs/hyperlocal_hub_screen.dart';
// ─── Result Detail Screens ────────────────────────────────────────────────
import '../../screens/results/academic_result_screen.dart';
import '../../screens/results/cricket_score_screen.dart';
import '../../screens/results/election_result_screen.dart';
import '../../screens/results/finance_result_screen.dart';
import '../../screens/results/football_score_screen.dart';
import '../../screens/results/law_result_screen.dart';
import '../../screens/results/entertainment_result_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // ─── Full-screen routes (outside shell) ─────────────────────────────────
    GoRoute(path: '/splash',     builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SignupScreen(),
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
    GoRoute(
      path: '/admin/dashboard',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AdminScaffold(),
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
      builder: (context, state) => const AcademicHubScreen(),
    ),
    GoRoute(
      path: '/results/academic/school',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AcademicHubScreen(),
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
      builder: (context, state) => const SportsHubScreen(),
    ),
    GoRoute(
      path: '/results/sports/cricket/live/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        return CricketScoreScreen(
          data: const {'match': 'IPL 2026', 'team_a': 'CSK', 'team_b': 'MI'},
          title: 'Live Cricket',
        );
      },
    ),
    GoRoute(
      path: '/results/sports/football',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SportsHubScreen(),
    ),
    GoRoute(
      path: '/results/sports/football/live/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        return FootballScoreScreen(
          data: const {'team_a': 'Mumbai City', 'team_b': 'Kerala Blasters'},
          title: 'ISL 2026',
        );
      },
    ),
    GoRoute(
      path: '/results/sports/f1',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SportsHubScreen(),
    ),
    GoRoute(
      path: '/results/sports/f1/live/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SportsHubScreen(),
    ),
    GoRoute(
      path: '/results/sports/:sport',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SportsHubScreen(),
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
      path: '/results/government/recruitment/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const GovernmentHubScreen(),
    ),
    GoRoute(
      path: '/results/government/exam/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const GovernmentHubScreen(),
    ),
    GoRoute(
      path: '/results/law',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LawHubScreen(),
    ),
    GoRoute(
      path: '/results/law/verdict/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => LawResultScreen(
        data: const {'verdict': 'Petition Dismissed', 'court': 'Madras HC'},
        title: 'Verdict Details',
      ),
    ),
    GoRoute(
      path: '/results/entertainment',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EntertainmentHubScreen(),
    ),
    GoRoute(
      path: '/results/entertainment/:section',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EntertainmentHubScreen(),
    ),
    GoRoute(
      path: '/results/tech',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TechHubScreen(),
    ),
    GoRoute(
      path: '/results/tech/:section',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TechHubScreen(),
    ),
    GoRoute(
      path: '/results/healthcare',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const HealthcareHubScreen(),
    ),
    GoRoute(
      path: '/results/healthcare/exam/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const HealthcareHubScreen(),
    ),
    GoRoute(
      path: '/results/business',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BusinessHubScreen(),
    ),
    GoRoute(
      path: '/results/hyperlocal',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const HyperLocalHubScreen(),
    ),
    GoRoute(
      path: '/results/hyperlocal/sports/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const HyperLocalHubScreen(),
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
      path: '/post/details/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PostDetailScreen(postId: id);
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

    // ─── Bottom Navigation Shell ─────────────────────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShellScreen(navigationShell: navigationShell),
      branches: [
        // Tab 0 — Home (social feed)
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
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
