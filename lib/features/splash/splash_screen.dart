import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/l10n_ext.dart';
import '../../core/widgets/brand_art.dart';
import '../authentication/presentation/providers/auth_providers.dart';
import '../dashboard/presentation/providers/dashboard_providers.dart';
import '../dashboard/presentation/widgets/exam_category_cards.dart';
import '../onboarding/onboarding_providers.dart';

/// Brand splash: corner waves, cap + book logo, wordmark, tagline, study
/// illustration and exam-category chips (from the catalog). Routes onward
/// after [AppConstants.splashDelay].
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(AppConstants.splashDelay, _next);
  }

  void _next() {
    if (!mounted) return;
    final String target;
    if (!ref.read(onboardingDoneProvider)) {
      target = AppRoutes.onboarding;
    } else if (ref.read(sessionProvider) == null) {
      target = AppRoutes.login;
    } else {
      target = AppRoutes.home;
    }
    context.go(target);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  Animation<double> _interval(double a, double b) =>
      CurvedAnimation(parent: _c, curve: Interval(a, b, curve: Curves.easeOutCubic));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final logoIn = _interval(0.0, 0.5);
    final textIn = _interval(0.2, 0.7);
    final artIn = _interval(0.4, 1.0);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.splashBgTop, AppColors.splashBgBottom],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: BrandCornerWaves()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, box) {
                  // Scale the whole composition to the screen; 390×780 is the design size.
                  final scale = (box.maxWidth / 390).clamp(0.75, 1.25) *
                      (box.maxHeight / 780).clamp(0.7, 1.0);
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScaleTransition(
                              scale: Tween(begin: 0.8, end: 1.0).animate(logoIn),
                              child: FadeTransition(
                                opacity: logoIn,
                                child: CapBookLogo(width: 150 * scale),
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            FadeTransition(
                              opacity: textIn,
                              child: Column(
                                children: [
                                  Semantics(
                                    header: true,
                                    label: l10n.appName,
                                    child: ExcludeSemantics(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text.rich(
                                          TextSpan(children: [
                                            TextSpan(
                                              text: 'ExamGenius ',
                                              style: AppTextStyles.wordmark(
                                                  AppFontSizes.hero * scale, AppColors.brandBlue),
                                            ),
                                            TextSpan(
                                              text: l10n.aiLabel,
                                              style: AppTextStyles.wordmark(
                                                  AppFontSizes.hero * scale, AppColors.accent),
                                            ),
                                          ]),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 6 * scale),
                                  Text(
                                    l10n.appTagline,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.tagline(
                                        AppFontSizes.xl * scale, AppColors.textMuted),
                                  ),
                                  SizedBox(height: 14 * scale),
                                  const _StarDivider(),
                                ],
                              ),
                            ),
                            SizedBox(height: 22 * scale),
                            FadeTransition(
                              opacity: artIn,
                              child: SlideTransition(
                                position: Tween(begin: const Offset(0, 0.08), end: Offset.zero)
                                    .animate(artIn),
                                child: ExcludeSemantics(
                                  child: AspectRatio(
                                    aspectRatio: 340 / 200,
                                    child: const StudyIllustration(),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 28 * scale),
                            FadeTransition(opacity: artIn, child: const _CategoryChips()),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─── ★ ─── under the tagline.
class _StarDivider extends StatelessWidget {
  const _StarDivider();

  @override
  Widget build(BuildContext context) {
    Widget line() => Container(
          width: 84,
          height: 1.5,
          color: AppColors.divider.withValues(alpha: 0.6),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        line(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Icon(Icons.star_rounded, color: AppColors.gold, size: 26),
        ),
        line(),
      ],
    );
  }
}

/// Railway / SSC / Banking pills from the catalog, plus "More".
class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cats = ref.watch(examCatalogProvider).value ?? const [];

    Widget chip(IconData icon, String label, Color color) => Container(
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: AppTextStyles.chip.copyWith(color: Color.lerp(color, Colors.black, 0.25))),
            ],
          ),
        );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Wrap(
        key: ValueKey(cats.length),
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final c in cats)
            () {
              final s = categoryStyle(context, c);
              return chip(s.icon, s.shortLabel, s.color);
            }(),
          if (cats.isNotEmpty) chip(Icons.grid_view_rounded, l10n.more, AppColors.accent),
        ],
      ),
    );
  }
}

