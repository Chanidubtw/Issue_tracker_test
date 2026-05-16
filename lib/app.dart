import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'domain/entities/issue.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/issues/issue_detail_screen.dart';
import 'presentation/screens/issues/issue_form_screen.dart';
import 'presentation/screens/issues/issue_list_screen.dart';
import 'presentation/screens/splash/splash_screen.dart';

final _router = GoRouter(
  initialLocation: RouteNames.splash,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: RouteNames.dashboard,
      builder: (_, __) => const DashboardScreen(),
      redirect: (context, state) {
        // issues loaded lazily when entering dashboard
        return null;
      },
    ),
    GoRoute(
      path: RouteNames.issueList,
      builder: (_, __) => const IssueListScreen(),
    ),
    GoRoute(
      path: RouteNames.issueCreate,
      builder: (_, __) => const IssueFormScreen(),
    ),
    GoRoute(
      path: '/issues/:id',
      builder: (_, state) =>
          IssueDetailScreen(issueId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/issues/:id/edit',
      builder: (_, state) {
        final issue = state.extra as Issue?;
        return IssueFormScreen(existing: issue);
      },
    ),
  ],
);

class IssueTrackerApp extends ConsumerWidget {
  const IssueTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
