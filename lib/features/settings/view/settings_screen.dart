import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/features/settings/bloc/settings_bloc.dart';
import 'package:money_tracker_app/features/settings/view/manage_categories_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoading || state is SettingsInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SettingsError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        final settings = (state as SettingsLoaded).settings;
        final isDark = MHelperFunctions.isDarkMode(context);

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            MSizes.defaultSpace,
            MSizes.defaultSpace,
            MSizes.defaultSpace,
            88,
          ),
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: MSizes.spaceBtwSections),
            _SettingsSectionCard(
              isDark: isDark,
              title: 'Appearance',
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text('System'),
                    icon: Icon(Icons.brightness_auto),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text('Light'),
                    icon: Icon(Icons.light_mode),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text('Dark'),
                    icon: Icon(Icons.dark_mode),
                  ),
                ],
                selected: {settings.themeMode},
                onSelectionChanged: (selection) {
                  context
                      .read<SettingsBloc>()
                      .add(UpdateThemeMode(selection.first));
                },
              ),
            ),
            const SizedBox(height: MSizes.md),
            _SettingsSectionCard(
              isDark: isDark,
              title: 'Data',
              child: _SettingsTile(
                icon: Icons.category_outlined,
                title: 'Manage categories',
                onTap: () {
                  MHelperFunctions.navigateToScreen(
                    context,
                    const ManageCategoriesScreen(),
                  );
                },
              ),
            ),
            const SizedBox(height: MSizes.md),
            _SettingsSectionCard(
              isDark: isDark,
              title: 'About',
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.offline_bolt_outlined,
                    title: 'Offline & private',
                    subtitle:
                        'All data stays on your device. No account or cloud sync.',
                  ),
                  const SizedBox(height: MSizes.sm),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: '1.0.0',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({
    required this.isDark,
    required this.title,
    required this.child,
  });

  final bool isDark;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MSizes.md),
      decoration: BoxDecoration(
        color: isDark ? MColors.cardDark : MColors.cardLight,
        borderRadius: BorderRadius.circular(MSizes.borderRadiusLg),
        border: isDark
            ? null
            : Border.all(color: MColors.outline.withValues(alpha: 0.35)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: MColors.primary,
                ),
          ),
          const SizedBox(height: MSizes.md),
          child,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

    return Material(
      color: isDark ? MColors.dark : MColors.bgLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MSizes.sm,
            vertical: MSizes.md,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: MColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: MColors.primary),
              ),
              const SizedBox(width: MSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
