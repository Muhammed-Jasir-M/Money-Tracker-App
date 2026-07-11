import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

        return ListView(
          padding: const EdgeInsets.all(MSizes.defaultSpace),
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: MSizes.spaceBtwSections),
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: MSizes.sm),
            SegmentedButton<ThemeMode>(
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
            const SizedBox(height: MSizes.spaceBtwSections),
            Text(
              'Data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: MSizes.sm),
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('Manage categories'),
              trailing: const Icon(Icons.chevron_right),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              onTap: () {
                MHelperFunctions.navigateToScreen(
                  context,
                  const ManageCategoriesScreen(),
                );
              },
            ),
            const SizedBox(height: MSizes.spaceBtwSections),
            Text(
              'About',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: MSizes.sm),
            ListTile(
              leading: const Icon(Icons.offline_bolt_outlined),
              title: const Text('Offline & private'),
              subtitle: const Text(
                'All data stays on your device. No account or cloud sync.',
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Version'),
              subtitle: const Text('1.0.0'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ],
        );
      },
    );
  }
}
