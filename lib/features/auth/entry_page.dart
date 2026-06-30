import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ganesha_2026/core/constants.dart';
import 'package:ganesha_2026/core/design/app_colors.dart';
import 'package:ganesha_2026/core/design/app_spacing.dart';
import 'package:ganesha_2026/core/design/app_radius.dart';
import 'package:ganesha_2026/core/design/app_shadows.dart';
import 'package:ganesha_2026/core/providers/auth_provider.dart';
import 'package:ganesha_2026/shared/widgets/app_snackbar.dart';

class EntryPage extends ConsumerStatefulWidget {
  const EntryPage({super.key});

  @override
  ConsumerState<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends ConsumerState<EntryPage> {
  final _nameController = TextEditingController();
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _validateName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return 'Please enter your name';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.warmGray50,
              AppColors.primaryBg.withAlpha(120),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 24 * (1.0 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: AppRadius.largeBorder,
                      border: Border.all(color: AppColors.outline),
                      boxShadow: AppShadows.elevated,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxxl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.auto_awesome_mosaic_rounded,
                              size: 44,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          Text(
                            'Welcome',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.charcoal,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            AppConstants.appName,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.warmGray500,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                          TextField(
                            controller: _nameController,
                            autofocus: !isDesktop,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: 'Your Name',
                              hintText: 'e.g. Santhosh',
                              prefixIcon: const Icon(Icons.person_outline_rounded),
                              errorText: _nameError,
                              filled: true,
                              fillColor: AppColors.warmGray50,
                            ),
                            onChanged: (_) {
                              if (_nameError != null) {
                                setState(() => _nameError = null);
                              }
                            },
                            onSubmitted: (_) => _continueAsVolunteer(),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton.icon(
                              onPressed: _continueAsVolunteer,
                              icon: const Icon(Icons.person_outline_rounded, size: 20),
                              label: const Text(
                                'Continue as Volunteer',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.mediumBorder,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xxl,
                                  vertical: AppSpacing.lg,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _showAdminLogin,
                              icon: const Icon(Icons.shield_outlined, size: 20),
                              label: const Text(
                                'Login as Admin',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(
                                  color: AppColors.primary.withAlpha(60),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.mediumBorder,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xxl,
                                  vertical: AppSpacing.lg,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continueAsVolunteer() async {
    debugPrint('[VOLUNTEER] Button pressed');
    final error = _validateName();
    if (error != null) {
      setState(() => _nameError = error);
      return;
    }
    final name = _nameController.text.trim();

    debugPrint('[VOLUNTEER] Opening password dialog');
    final password = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Volunteer Access'),
          content: TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter volunteer password',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
            onSubmitted: (v) {
              Navigator.pop(ctx, v);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    debugPrint('[VOLUNTEER] Dialog returned: ${password != null ? "non-null" : "null"}');
    if (password == null || password.isEmpty) {
      debugPrint('[VOLUNTEER] Password empty or cancelled — access denied');
      return;
    }

    final notifier = ref.read(roleProvider.notifier);
    debugPrint('[VOLUNTEER] Calling loginAsVolunteer()');
    final success = await notifier.loginAsVolunteer(password, userName: name);
    debugPrint('[VOLUNTEER] Validation result: $success');

    if (!context.mounted) return;

    if (success) {
      debugPrint('[VOLUNTEER] Role set to volunteer — navigating to dashboard');
      context.go('/');
    } else {
      debugPrint('[VOLUNTEER] Wrong password — showing error');
      context.showError('Incorrect volunteer password');
    }
  }

  Future<void> _showAdminLogin() async {
    final error = _validateName();
    if (error != null) {
      setState(() => _nameError = error);
      return;
    }
    final name = _nameController.text.trim();

    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Admin Login'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter admin password',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, passwordController.text),
            child: const Text('Login'),
          ),
        ],
      ),
    );

    if (password == null || password.isEmpty) return;

    final notifier = ref.read(roleProvider.notifier);
    final success = await notifier.loginAsAdmin(password, userName: name);

    if (!context.mounted) return;

    if (success) {
      context.go('/');
    } else {
      context.showError('Incorrect admin password');
    }
  }
}
