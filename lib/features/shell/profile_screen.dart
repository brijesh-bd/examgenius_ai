import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/l10n_ext.dart';
import '../../core/widgets/app_widgets.dart';
import '../../localization/settings_providers.dart';
import '../authentication/presentation/providers/auth_providers.dart';
import '../dashboard/presentation/providers/dashboard_providers.dart';

/// Minimal profile/settings: identity, language switcher, theme, logout.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final user = ref.watch(sessionProvider);
    final locale = ref.watch(localeProvider);
    final mode = ref.watch(themeModeProvider);
    final exam = ref.watch(targetExamNameProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: ListView(
        children: [
          ResponsiveCenter(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      child: Text(
                        (user?.firstName ?? '?').characters.first.toUpperCase(),
                        style: AppTextStyles.h3,
                      ),
                    ),
                    title: Text(user?.name ?? '', style: theme.textTheme.titleMedium),
                    subtitle: Text(
                      ['+91 ${user?.mobile ?? ''}', ?exam].join('\n'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(title: l10n.language),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'en', label: Text(l10n.english)),
                    ButtonSegment(value: 'hi', label: Text(l10n.hindi)),
                  ],
                  selected: {locale.languageCode},
                  onSelectionChanged: (s) =>
                      ref.read(localeProvider.notifier).setLocale(Locale(s.first)),
                ),
                const SizedBox(height: 24),
                SectionHeader(title: l10n.theme),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem)),
                    ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
                    ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
                  ],
                  selected: {mode},
                  onSelectionChanged: (s) =>
                      ref.read(themeModeProvider.notifier).setThemeMode(s.first),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l10n.logout),
                  onPressed: () => ref.read(sessionProvider.notifier).logout(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
