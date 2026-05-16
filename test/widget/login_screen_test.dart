import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:issue_tracker/domain/entities/user.dart';
import 'package:issue_tracker/domain/repositories/auth_repository.dart';
import 'package:issue_tracker/presentation/providers/providers.dart';
import 'package:issue_tracker/presentation/screens/auth/login_screen.dart';
import 'package:issue_tracker/core/theme/app_theme.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

final _testRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(
        path: '/dashboard',
        builder: (_, __) => const Scaffold(body: Text('Dashboard'))),
  ],
);

Widget _buildTestApp(AuthRepository mockRepo) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockRepo),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light(),
      routerConfig: _testRouter,
    ),
  );
}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  testWidgets('shows validation errors on empty submit', (tester) async {
    await tester.pumpWidget(_buildTestApp(mockRepo));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('shows email format error for invalid email', (tester) async {
    await tester.pumpWidget(_buildTestApp(mockRepo));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('email_field')), 'notanemail');
    await tester.enterText(
        find.byKey(const Key('password_field')), 'password123');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('shows password length error for short password', (tester) async {
    await tester.pumpWidget(_buildTestApp(mockRepo));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(const Key('email_field')), 'user@test.com');
    await tester.enterText(find.byKey(const Key('password_field')), '123');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('calls login and navigates on valid credentials', (tester) async {
    when(() => mockRepo.login(any(), any())).thenAnswer((_) async =>
        const User(email: 'user@test.com', token: 'mock-token'));
    when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => null);

    await tester.pumpWidget(_buildTestApp(mockRepo));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key('email_field')), 'user@test.com');
    await tester.enterText(
        find.byKey(const Key('password_field')), 'password123');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    verify(() => mockRepo.login('user@test.com', 'password123')).called(1);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
