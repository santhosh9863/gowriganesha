import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ganesha_2026/core/theme.dart';
import 'package:ganesha_2026/core/models/user_role.dart';
import 'package:ganesha_2026/core/providers/auth_provider.dart';
import 'package:ganesha_2026/core/providers/notification_provider.dart';
import 'package:ganesha_2026/core/providers/user_provider.dart';
import 'package:ganesha_2026/core/services/notification_navigator.dart';
import 'package:ganesha_2026/shared/widgets/app_scaffold.dart';
import 'package:ganesha_2026/shared/widgets/page_transitions.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/features/auth/entry_page.dart';
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
import 'package:ganesha_2026/features/notifications/notification_center_page.dart';
import 'package:ganesha_2026/features/settings/settings_page.dart';
import 'package:ganesha_2026/features/volunteer_management/volunteer_management_page.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  void signal() => notifyListeners();
}

final _routerRefreshProvider = Provider<ChangeNotifier>((ref) {
  final notifier = _RouterRefreshNotifier();
  ref.listen(roleProvider, (_, _) => notifier.signal());
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(_routerRefreshProvider);

  return GoRouter(
    initialLocation: '/entry',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final role = ref.read(roleProvider);
      final location = state.uri.toString();

      if (role == UserRole.none) {
        if (location != '/entry') return '/entry';
        return null;
      }

      if (role == UserRole.volunteer) {
        final blocked = <RegExp>[
          RegExp(r'^/expenses/add$'),
          RegExp(r'^/expenses/[^/]+/edit$'),
          RegExp(r'^/collections/[^/]+/edit$'),
          RegExp(r'^/daily-collections/add$'),
          RegExp(r'^/daily-collections/[^/]+/edit$'),
          RegExp(r'^/followups/[^/]+/edit$'),
          RegExp(r'^/settings/volunteer-management$'),
        ];
        if (blocked.any((r) => r.hasMatch(location))) return '/';
      }

      if (location == '/entry') return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/entry',
        pageBuilder: (context, state) => PageTransition.fadeSlide(const EntryPage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              _buildRoute('/', const DashboardPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
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
            ],
          ),
          StatefulShellBranch(
            routes: [
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
          StatefulShellBranch(
            routes: [
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
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/followups',
                pageBuilder: (context, state) =>
                    PageTransition.fadeSlide(const FollowUpListPage()),
                routes: [
                  _buildRoute('add', const FollowUpFormPage()),
                  GoRoute(
                    path: ':followUpId/edit',
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['followUpId']!;
                      return PageTransition.fadeSlide(
                        FollowUpFormPage(followUpId: id),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      _buildRoute('/settings', const SettingsPage()),
      _buildRoute('/settings/volunteer-management', const VolunteerManagementPage()),
      _buildRoute('/notifications', const NotificationCenterPage()),
    ],
  );
});

GoRoute _buildRoute(String path, Widget page) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => PageTransition.fadeSlide(page),
  );
}

class GaneshaApp extends ConsumerStatefulWidget {
  const GaneshaApp({super.key});

  @override
  ConsumerState<GaneshaApp> createState() => _GaneshaAppState();
}

String _detectPlatform() {
  if (kIsWeb) return 'web';
  try {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
  } catch (_) {}
  return 'unknown';
}

class _GaneshaAppState extends ConsumerState<GaneshaApp>
    with WidgetsBindingObserver {
  bool _landingDone = false;
  bool _disposed = false;

  void _onLandingComplete() {
    setState(() => _landingDone = true);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _backfillUser());
  }

  Future<void> _backfillUser() async {
    final role = ref.read(roleProvider);
    if (role == UserRole.none) return;

    final userId = ref.read(userIdProvider);
    final userName = ref.read(userNameProvider);
    if (userId.isEmpty || userName.isEmpty) return;

    final firebaseUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (firebaseUid.isEmpty) return;

    final userService = ref.read(userServiceProvider);
    await userService.ensureUserExists(
      userId: userId,
      name: userName,
      role: role,
      firebaseUid: firebaseUid,
      device: _detectPlatform(),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final role = ref.read(roleProvider);
    if (role == UserRole.none) return;

    final userId = ref.read(userIdProvider);
    if (userId.isEmpty) return;

    final userService = ref.read(userServiceProvider);

    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(seconds: 2), () {
        if (_disposed) return;
        userService.updateActivity(userId);
      });
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      userService.setOffline(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    ref.watch(pushNotificationInitProvider);

    ref.listen(userIdProvider, (prev, next) {
      if (next.isNotEmpty && next != prev) {
        ref.read(pushNotificationServiceProvider).updateUserId(next);
      }
    });

    ref.listen(pendingNotificationTapProvider, (prev, next) {
      if (next == null) return;
      final navigator = NotificationNavigator();
      final route = navigator.resolveRouteFor(
        entityType: next.entityType,
        entityId: next.entityId,
      );
      ref.read(pendingNotificationTapProvider.notifier).state = null;
      if (route != null && context.mounted) {
        context.push(route);
      }
    });

    ref.listen(roleProvider, (prev, next) {
      if (next == UserRole.none && prev != UserRole.none) {
        ref.read(pushNotificationServiceProvider).removeCurrentToken();
      }
    });

    return MaterialApp.router(
      title: 'Sankalpa',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (_landingDone) return child!;
        return _LaunchAnimation(
          onComplete: _onLandingComplete,
          child: child!,
        );
      },
    );
  }
}

class _LaunchAnimation extends StatefulWidget {
  final VoidCallback onComplete;
  final Widget child;

  const _LaunchAnimation({
    required this.onComplete,
    required this.child,
  });

  @override
  State<_LaunchAnimation> createState() => _LaunchAnimationState();
}

class _LaunchAnimationState extends State<_LaunchAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _haloOpacity;
  late final Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _logoFade = _buildFade(0, 0.182, Curves.easeOut);
    _logoScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.182, curve: Curves.easeOutCubic),
      ),
    );
    _haloOpacity = _buildFade(0.136, 0.318, Curves.easeOut);
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.636, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    _controller.forward();
  }

  Animation<double> _buildFade(double start, double end, Curve curve) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: curve),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        FadeTransition(
          opacity: _exitFade,
          child: Container(
            color: AppColors.surface,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FadeTransition(
                    opacity: _haloOpacity,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: 0.10),
                            AppColors.accent.withValues(alpha: 0.03),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  ScaleTransition(
                    scale: _logoScale,
                    child: FadeTransition(
                      opacity: _logoFade,
                      child: Image.asset(
                        'assets/branding/sankalpa_logo.png',
                        width: 110,
                        height: 110,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
