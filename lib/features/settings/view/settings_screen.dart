import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/settings/app_settings.dart';
import 'package:money_tracker_app/features/categories/bloc/category_bloc.dart';
import 'package:money_tracker_app/features/settings/bloc/settings_bloc.dart';
import 'package:money_tracker_app/features/settings/view/manage_categories_screen.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/shared/widgets/confirm_dialog.dart';
import 'package:money_tracker_app/shared/widgets/text_form_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  String? _loadedName;
  bool _isEditingName = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _syncNameField(String userName) {
    if (_loadedName != userName) {
      _loadedName = userName;
      _nameController.text = userName;
    }
  }

  Future<void> _saveName() async {
    context.read<SettingsBloc>().add(UpdateUserName(_nameController.text));
    setState(() => _isEditingName = false);
    MHelperFunctions.showSnackBar(
      context: context,
      title: 'Saved',
      message: 'Your name was updated',
      bgColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  Future<void> _clearTransactions() async {
    final confirmed = await _confirmAction(
      title: 'Clear all transactions?',
      message: 'This will permanently delete every transaction.',
      confirmLabel: 'Clear',
      icon: Icons.receipt_long_outlined,
    );
    if (!confirmed || !mounted) return;

    final transactionBloc = context.read<TransactionBloc>();
    await transactionBloc.repository.clearAll();
    transactionBloc.add(LoadTransaction());

    if (!mounted) return;
    MHelperFunctions.showSnackBar(
      context: context,
      title: 'Cleared',
      message: 'All transactions were removed',
      bgColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  Future<void> _clearCategories() async {
    final confirmed = await _confirmAction(
      title: 'Clear all categories?',
      message:
          'This will permanently delete every category. Existing transactions will keep their category labels.',
      confirmLabel: 'Clear',
      icon: Icons.folder_off_outlined,
    );
    if (!confirmed || !mounted) return;

    final categoryBloc = context.read<CategoryBloc>();
    await categoryBloc.repository.clearAll();
    categoryBloc.add(LoadCategories());

    if (!mounted) return;
    MHelperFunctions.showSnackBar(
      context: context,
      title: 'Cleared',
      message: 'All categories were removed',
      bgColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  Future<void> _resetAllData() async {
    final confirmed = await _confirmAction(
      title: 'Reset all data?',
      message:
          'This will delete all transactions and categories. This cannot be undone.',
      confirmLabel: 'Reset',
      isDestructive: true,
      icon: Icons.delete_forever_outlined,
    );
    if (!confirmed || !mounted) return;

    final transactionBloc = context.read<TransactionBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    await transactionBloc.repository.clearAll();
    await categoryBloc.repository.clearAll();
    transactionBloc.add(LoadTransaction());
    categoryBloc.add(LoadCategories());

    if (!mounted) return;
    MHelperFunctions.showSnackBar(
      context: context,
      title: 'Reset complete',
      message: 'All transactions and categories were removed',
      bgColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  Future<bool> _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
    IconData? icon,
  }) {
    return MConfirmDialog.show(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      isDestructive: isDestructive,
      icon: icon,
    );
  }

  void _cancelNameEdit(String savedName) {
    _nameController.text = savedName;
    setState(() => _isEditingName = false);
  }

  Widget _buildProfileSection(AppSettings settings) {
    final hasSavedName = settings.userName.trim().isNotEmpty;
    final showEditor = !hasSavedName || _isEditingName;

    if (showEditor) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MTextFormField(
            controller: _nameController,
            label: 'Name',
            hintText: 'Enter your name',
            prefixIcon: Icons.person_outline,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: MSizes.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasSavedName) ...[
                TextButton(
                  onPressed: () => _cancelNameEdit(settings.userName),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: MSizes.sm),
              ],
              FilledButton(
                onPressed: _nameController.text.trim().isEmpty ||
                        _nameController.text.trim() == settings.userName
                    ? null
                    : _saveName,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _isEditingName = true),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: MSizes.xs),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      settings.userName.trim(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _isEditingName = true),
                tooltip: 'Edit name',
                icon: Icon(
                  Icons.edit_outlined,
                  color: MColors.primary,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        _syncNameField(settings.userName);

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            MSizes.defaultSpace,
            MSizes.defaultSpace,
            MSizes.defaultSpace,
            MSizes.lg,
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
              title: 'Profile',
              child: _buildProfileSection(settings),
            ),
            const SizedBox(height: MSizes.md),
            _SettingsSectionCard(
              isDark: isDark,
              title: 'Appearance',
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: const Text('System'),
                    icon: Icon(Icons.brightness_auto, color: MColors.primary),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: const Text('Light'),
                    icon: Icon(Icons.light_mode, color: MColors.primary),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: const Text('Dark'),
                    icon: Icon(Icons.dark_mode, color: MColors.primary),
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
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.category_outlined,
                    title: 'Manage categories',
                    subtitle: 'Add, edit, or delete income and expense categories',
                    onTap: () {
                      MHelperFunctions.navigateToScreen(
                        context,
                        const ManageCategoriesScreen(),
                      );
                    },
                  ),
                  const SizedBox(height: MSizes.sm),
                  _SettingsTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Clear transactions',
                    subtitle: 'Remove all transactions only',
                    onTap: _clearTransactions,
                  ),
                  const SizedBox(height: MSizes.sm),
                  _SettingsTile(
                    icon: Icons.folder_off_outlined,
                    title: 'Clear categories',
                    subtitle: 'Remove all categories only',
                    onTap: _clearCategories,
                  ),
                  const SizedBox(height: MSizes.sm),
                  _SettingsTile(
                    icon: Icons.delete_forever_outlined,
                    title: 'Reset all data',
                    subtitle: 'Delete transactions and categories',
                    onTap: _resetAllData,
                    destructive: true,
                  ),
                ],
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
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final accent = destructive ? Colors.red : MColors.primary;

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
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: accent),
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
                            color: destructive ? Colors.red : null,
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
