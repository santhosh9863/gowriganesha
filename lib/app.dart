import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ganesha_2026/core/theme.dart';
import 'package:ganesha_2026/shared/widgets/app_scaffold.dart';
import 'package:ganesha_2026/shared/widgets/page_transitions.dart';
import 'package:ganesha_2026/features/dashboard/dashboard_page.dart';
import 'package:ganesha_2026/features/collections/collection_list_page.dart';
import 'package:ganesha_2026/features/collections/collection_detail_page.dart';
import 'package:ganesha_2026/features/collections/collection_form_page.dart';
import 'package:ganesha_2026/features/expenses/expense_list_page.dart';
import 'package:ganesha_2026/features/expenses/expense_form_page.dart';
import 'package:ganesha_2026/features/daily_collections/daily_collection_list_page.dart';
import 'package:ganesha_2026/features/daily_collections/daily_collection_form_page.dart';
import 'package:ganesha_2026/features/followups/followup_list_page.dart';
import 'package:ganesha_2026/features/followups/followup_form_page.dart';
import 'package:ganesha_2026/features/settings/settings_page.dart';

GoRoute _buildRoute(String path, Widget page) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => PageTransition.fadeSlide(page),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        _buildRoute('/', const DashboardPage()),
        GoRoute(
          path: '/collections',
          pageBuilder: (context, state) =>
              PageTransition.fadeSlide(const CollectionListPage()),
          routes: [
            _buildRoute('add', const CollectionFormPage()),
            GoRoute(
              path: ':targetId',
              pageBuilder: (context, state) {
                final targetId = state.pathParameters['targetId']!;
                return PageTransition.fadeSlide(
                  CollectionDetailPage(targetId: targetId),
                );
              },
            ),
            GoRoute(
              path: ':targetId/edit',
              pageBuilder: (context, state) {
                final targetId = state.pathParameters['targetId']!;
                return PageTransition.fadeSlide(
                  CollectionFormPage(targetId: targetId),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/expenses',
          pageBuilder: (context, state) =>
              PageTransition.fadeSlide(const ExpenseListPage()),
          routes: [
            _buildRoute('add', const ExpenseFormPage()),
            GoRoute(
              path: ':expenseId/edit',
              pageBuilder: (context, state) {
                final expenseId = state.pathParameters['expenseId']!;
                return PageTransition.fadeSlide(
                  ExpenseFormPage(expenseId: expenseId),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/daily-collections',
          pageBuilder: (context, state) =>
              PageTransition.fadeSlide(const DailyCollectionListPage()),
          routes: [
            _buildRoute('add', const DailyCollectionFormPage()),
            GoRoute(
              path: ':dailyCollectionId/edit',
              pageBuilder: (context, state) {
                final id = state.pathParameters['dailyCollectionId']!;
                return PageTransition.fadeSlide(
                  DailyCollectionFormPage(dailyCollectionId: id),
                );
              },
            ),
          ],
        ),
      ],
    ),
    _buildRoute('/settings', const SettingsPage()),
    _buildRoute('/followups', const FollowUpListPage()),
    _buildRoute('/followups/add', const FollowUpFormPage()),
    GoRoute(
      path: '/followups/:followUpId/edit',
      pageBuilder: (context, state) {
        final id = state.pathParameters['followUpId']!;
        return PageTransition.fadeSlide(
          FollowUpFormPage(followUpId: id),
        );
      },
    ),
  ],
);

class GaneshaApp extends StatelessWidget {
  const GaneshaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sri Gowri Ganesha Geleyara Balaga',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
