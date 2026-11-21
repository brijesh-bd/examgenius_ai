import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/l10n_ext.dart';
import '../../core/widgets/app_widgets.dart';
import '../../localization/settings_providers.dart';
import 'onboarding_providers.dart';

/// Page 0 = language picker, pages 1..3 = feature highlights.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  static const _pageCount = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(onboardingDoneProvider.notifier).complete();
    if (mounted) context.go(AppRoutes.login);
  }

  void _next() {
    if (_page == _pageCount - 1) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final slides = [
      (_Art.aiPractice, l10n.onboarding1Title, l10n.onboarding1Body),
      (_Art.mockTests, l10n.onboarding2Title, l10n.onboarding2Body),
      (_Art.analytics, l10n.onboarding3Title, l10n.onboarding3Body),
    ];
    final isLast = _page == _pageCount - 1;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: ResponsiveCenter(
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: isLast
                      ? null
                      : TextButton(
                          onPressed: _finish,
                          child: Text(
                            l10n.skip,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    const _LanguagePage(),
                    for (final s in slides)
                      _FeaturePage(art: s.$1, title: s.$2, body: s.$3),
                  ],
                ),
              ),
              // Dots track the feature slides only (language page excluded).
              SizedBox(
                height: 8,
                child: _page == 0
                    ? null
                    : _Dots(count: slides.length, index: _page - 1),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: PrimaryButton(
                  label: isLast ? l10n.getStarted : l10n.next,
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguagePage extends ConsumerWidget {
  const _LanguagePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    Widget option(String code, String label, String sample) {
      final selected = current == code;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () =>
                ref.read(localeProvider.notifier).setLocale(Locale(code)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    child: Text(
                      sample,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(label, style: theme.textTheme.titleMedium),
                  ),
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Center(
            child: BrandWordmark(
              logoSize: 64,
              fontSize: AppFontSizes.h1,
              showTagline: false,
            ),
          ),
          const SizedBox(height: 28),
          Text(l10n.chooseLanguage, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            l10n.chooseLanguageSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          option('en', 'English', 'A'),
          option('hi', 'हिन्दी', 'अ'),
        ],
      ),
    );
  }
}

enum _Art { aiPractice, mockTests, analytics }

class _FeaturePage extends StatelessWidget {
  const _FeaturePage({
    required this.art,
    required this.title,
    required this.body,
  });

  final _Art art;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, c) {
        final size = (c.maxHeight * 0.5).clamp(180.0, 300.0);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              SizedBox(height: c.maxHeight * 0.06),
              _Illustration(art: art, size: size),
              const SizedBox(height: 40),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: AppFontSizes.h2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Icon composition on a soft circle, standing in for the illustrations.
class _Illustration extends StatelessWidget {
  const _Illustration({required this.art, required this.size});
  final _Art art;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final circle = isDark ? AppColors.darkTint : AppColors.lightTint;

    Widget badge(Widget child, Color color, {double pad = 8}) => Container(
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.06),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 12),
        ],
      ),
      child: child,
    );

    final sparkle = Icon(
      Icons.auto_awesome,
      size: size * 0.08,
      color: AppColors.primaryVariant,
    );

    final List<Widget> layers = switch (art) {
      _Art.aiPractice => [
        Positioned(
          bottom: size * 0.16,
          child: Icon(
            Icons.menu_book_rounded,
            size: size * 0.3,
            color: AppColors.success,
          ),
        ),
        Positioned(
          top: size * 0.18,
          child: Icon(
            Icons.laptop_mac_rounded,
            size: size * 0.5,
            color: AppColors.primary,
          ),
        ),
        Positioned(
          top: size * 0.1,
          right: size * 0.14,
          child: badge(
            Text(
              'AI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.09,
              ),
            ),
            AppColors.accent,
            pad: size * 0.035,
          ),
        ),
        Positioned(top: size * 0.4, right: size * 0.08, child: sparkle),
      ],
      _Art.mockTests => [
        Icon(
          Icons.assignment_turned_in_rounded,
          size: size * 0.58,
          color: AppColors.primary,
        ),
        Positioned(
          bottom: size * 0.16,
          right: size * 0.16,
          child: Container(
            padding: EdgeInsets.all(size * 0.02),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time_filled_rounded,
              size: size * 0.2,
              color: AppColors.secondary,
            ),
          ),
        ),
        Positioned(top: size * 0.18, right: size * 0.16, child: sparkle),
      ],
      _Art.analytics => [
        Icon(
          Icons.bar_chart_rounded,
          size: size * 0.58,
          color: AppColors.success,
        ),
        Positioned(
          top: size * 0.16,
          right: size * 0.16,
          child: badge(
            Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: size * 0.1,
            ),
            AppColors.primary,
          ),
        ),
        Positioned(bottom: size * 0.2, left: size * 0.16, child: sparkle),
      ],
    };

    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: circle, shape: BoxShape.circle),
        child: Stack(alignment: Alignment.center, children: layers),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 7,
            width: 7,
            decoration: BoxDecoration(
              color: i == index ? AppColors.primaryDark : scheme.outlineVariant,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}
