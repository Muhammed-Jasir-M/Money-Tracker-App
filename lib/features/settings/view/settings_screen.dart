import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/core/constants/app_branding.dart';
import 'package:money_tracker_app/core/backup/backup_service.dart';
import 'package:money_tracker_app/core/constants/currencies.dart';
import 'package:money_tracker_app/core/export/csv_export_service.dart';
import 'package:money_tracker_app/core/export/monthly_report_service.dart';
import 'package:money_tracker_app/core/security/lock_service.dart';
import 'package:money_tracker_app/core/storage/receipt_storage.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/data/models/settings/app_settings.dart';
import 'package:money_tracker_app/features/budgets/bloc/budget_bloc.dart';
import 'package:money_tracker_app/features/budgets/view/manage_budgets_screen.dart';
import 'package:money_tracker_app/features/categories/bloc/category_bloc.dart';
import 'package:money_tracker_app/features/security/view/pin_entry_sheet.dart';
import 'package:money_tracker_app/features/settings/bloc/settings_bloc.dart';
import 'package:money_tracker_app/features/settings/view/manage_categories_screen.dart';
import 'package:money_tracker_app/features/transactions/bloc/transaction_bloc.dart';
import 'package:money_tracker_app/shared/widgets/appbar.dart';
import 'package:money_tracker_app/shared/widgets/confirm_dialog.dart';
import 'package:money_tracker_app/shared/widgets/empty_state.dart';
import 'package:money_tracker_app/shared/widgets/month_picker_sheet.dart';
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
  bool _isBackupBusy = false;
  bool _isExportBusy = false;
  bool _isReportBusy = false;
  bool? _biometricAvailable;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBiometricAvailability();
  }

  Future<void> _loadBiometricAvailability() async {
    final repository = context.read<SettingsBloc>().repository;
    try {
      final available = await repository.lockService.canUseBiometrics();
      if (!mounted) return;
      setState(() => _biometricAvailable = available);
    } catch (_) {
      if (!mounted) return;
      setState(() => _biometricAvailable = false);
    }
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
      isDestructive: true,
      icon: Icons.receipt_long_outlined,
    );
    if (!confirmed || !mounted) return;

    final transactionBloc = context.read<TransactionBloc>();
    await ReceiptStorage().clearAll();
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
      isDestructive: true,
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

  Future<void> _clearBudgets() async {
    final confirmed = await _confirmAction(
      title: 'Clear all budgets?',
      message: 'This will remove every monthly spending limit.',
      confirmLabel: 'Clear',
      isDestructive: true,
      icon: Icons.account_balance_wallet_outlined,
    );
    if (!confirmed || !mounted) return;

    final budgetBloc = context.read<BudgetBloc>();
    await budgetBloc.repository.clearAll();
    budgetBloc.add(LoadBudgets());

    if (!mounted) return;
    MHelperFunctions.showSnackBar(
      context: context,
      title: 'Cleared',
      message: 'All budgets were removed',
      bgColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  BackupService _backupService() {
    return BackupService(
      transactionRepository: context.read<TransactionBloc>().repository,
      categoryRepository: context.read<CategoryBloc>().repository,
      budgetRepository: context.read<BudgetBloc>().repository,
      settingsRepository: context.read<SettingsBloc>().repository,
    );
  }

  CsvExportService _csvExportService() {
    return CsvExportService(
      transactionRepository: context.read<TransactionBloc>().repository,
    );
  }

  MonthlyReportService _monthlyReportService() {
    return MonthlyReportService(
      transactionRepository: context.read<TransactionBloc>().repository,
    );
  }

  Future<void> _exportCsv(AppSettings settings) async {
    setState(() => _isExportBusy = true);
    try {
      await _csvExportService().exportAndShare(
        currencySymbol: settings.currencySymbol,
      );
      if (!mounted) return;
      MHelperFunctions.showSuccessSnackBar(
        context,
        title: 'Export ready',
        message: 'Choose where to save or share your CSV file',
      );
    } catch (e) {
      if (!mounted) return;
      MHelperFunctions.showErrorSnackBar(
        context,
        title: 'Export failed',
        message: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isExportBusy = false);
    }
  }

  Future<DateTime?> _pickReportMonth() {
    return showMonthPickerSheet(context: context);
  }

  Future<void> _exportMonthlyReport(AppSettings settings) async {
    final month = await _pickReportMonth();
    if (month == null || !mounted) return;

    setState(() => _isReportBusy = true);
    try {
      await _monthlyReportService().exportMonthAndShare(
        month: month,
        currencySymbol: settings.currencySymbol,
      );
      if (!mounted) return;
      MHelperFunctions.showSuccessSnackBar(
        context,
        title: 'Report ready',
        message: 'CSV and PDF for ${DateFormat('MMMM yyyy').format(month)}',
      );
    } on MonthlyReportException catch (e) {
      if (!mounted) return;
      MHelperFunctions.showErrorSnackBar(
        context,
        title: 'Report failed',
        message: e.message,
      );
    } catch (e) {
      if (!mounted) return;
      MHelperFunctions.showErrorSnackBar(
        context,
        title: 'Report failed',
        message: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isReportBusy = false);
    }
  }

  Future<void> _onLockToggle(bool enabled, AppSettings settings) async {
    final repository = context.read<SettingsBloc>().repository;
    final settingsBloc = context.read<SettingsBloc>();

    try {
      if (enabled) {
        final hasPin = await repository.hasPin();
        if (!hasPin && mounted) {
          final created = await PinEntrySheet.show(
            context: context,
            mode: PinEntryMode.setup,
            onCompleted: (pin) async {
              await repository.setPin(pin);
            },
          );
          if (created != true || !mounted) return;
        }
        settingsBloc.add(UpdateLockEnabled(true));
        await _loadBiometricAvailability();
        if (!mounted) return;
        MHelperFunctions.showSuccessSnackBar(
          context,
          title: 'App lock enabled',
          message: 'You will need your PIN when reopening the app',
        );
        return;
      }

      final verified = await PinEntrySheet.show(
        context: context,
        mode: PinEntryMode.verifyToDisable,
        verifyPin: repository.verifyPin,
        onCompleted: (_) async {
          await repository.clearPin();
          settingsBloc.add(UpdateLockEnabled(false));
        },
      );
      if (verified != true || !mounted) return;
      MHelperFunctions.showSuccessSnackBar(
        context,
        title: 'App lock disabled',
      );
    } on LockException catch (e) {
      if (!mounted) return;
      MHelperFunctions.showErrorSnackBar(
        context,
        title: 'App lock unavailable',
        message: e.message,
      );
    } catch (e) {
      if (!mounted) return;
      MHelperFunctions.showErrorSnackBar(
        context,
        title: 'App lock failed',
        message: e.toString(),
      );
    }
  }

  Future<void> _onBiometricToggle(bool enabled, AppSettings settings) async {
    if (!settings.lockEnabled) return;

    final repository = context.read<SettingsBloc>().repository;
    final settingsBloc = context.read<SettingsBloc>();

    try {
      if (enabled) {
        final available = await repository.lockService.canUseBiometrics();
        if (!available) {
          if (!mounted) return;
          MHelperFunctions.showErrorSnackBar(
            context,
            title: 'Biometrics unavailable',
            message:
                'Add a fingerprint or face unlock in your device settings first',
          );
          return;
        }

        final authenticated =
            await repository.lockService.authenticateWithBiometrics(
          reason: 'Confirm biometrics to enable app unlock',
        );
        if (!authenticated || !mounted) return;

        settingsBloc.add(UpdateUseBiometric(true));
        MHelperFunctions.showSuccessSnackBar(
          context,
          title: 'Biometric unlock enabled',
        );
        return;
      }

      settingsBloc.add(UpdateUseBiometric(false));
      if (!mounted) return;
      MHelperFunctions.showSuccessSnackBar(
        context,
        title: 'Biometric unlock disabled',
      );
    } on LockException catch (e) {
      if (!mounted) return;
      MHelperFunctions.showErrorSnackBar(
        context,
        title: 'Biometric unlock failed',
        message: e.message,
      );
    }
  }

  String _biometricSubtitle(AppSettings settings) {
    if (!settings.lockEnabled) {
      return 'Enable app lock first';
    }
    if (_biometricAvailable == null) {
      return 'Checking fingerprint support...';
    }
    if (_biometricAvailable == false) {
      return 'Set up fingerprint or face unlock in device settings';
    }
    return 'Use fingerprint or face unlock';
  }

  Future<void> _changePin(AppSettings settings) async {
    if (!settings.lockEnabled) return;

    final repository = context.read<SettingsBloc>().repository;
    final verified = await PinEntrySheet.show(
      context: context,
      mode: PinEntryMode.verifyCurrent,
      verifyPin: repository.verifyPin,
      onCompleted: (_) async {},
    );
    if (verified != true || !mounted) return;

    final changed = await PinEntrySheet.show(
      context: context,
      mode: PinEntryMode.setup,
      onCompleted: (pin) async {
        await repository.setPin(pin);
      },
    );
    if (changed != true || !mounted) return;

    MHelperFunctions.showSuccessSnackBar(
      context,
      title: 'PIN updated',
    );
  }

  Future<void> _exportBackup() async {
    setState(() => _isBackupBusy = true);
    try {
      await _backupService().exportAndShare();
      if (!mounted) return;
      MHelperFunctions.showSnackBar(
        context: context,
        title: 'Backup ready',
        message: 'Choose where to save or share your backup file',
        bgColor: Colors.green,
        icon: Icons.check_circle,
      );
    } on BackupException catch (e) {
      if (!mounted) return;
      MHelperFunctions.showSnackBar(
        context: context,
        title: 'Export failed',
        message: e.message,
        bgColor: Colors.red,
        icon: Icons.error,
      );
    } catch (e) {
      if (!mounted) return;
      MHelperFunctions.showSnackBar(
        context: context,
        title: 'Export failed',
        message: e.toString(),
        bgColor: Colors.red,
        icon: Icons.error,
      );
    } finally {
      if (mounted) setState(() => _isBackupBusy = false);
    }
  }

  Future<void> _restoreBackup() async {
    final confirmed = await _confirmAction(
      title: 'Restore backup?',
      message:
          'This will replace all transactions, categories, budgets, settings, and photos with the backup file.',
      confirmLabel: 'Continue',
      isDestructive: true,
      icon: Icons.restore_outlined,
    );
    if (!confirmed || !mounted) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip', 'json'],
    );
    if (!mounted) return;
    if (result == null || result.files.single.path == null) return;

    final backupService = _backupService();
    final transactionBloc = context.read<TransactionBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    final budgetBloc = context.read<BudgetBloc>();
    final settingsBloc = context.read<SettingsBloc>();

    setState(() => _isBackupBusy = true);
    try {
      await backupService.restoreFromFile(result.files.single.path!);

      transactionBloc.add(LoadTransaction());
      categoryBloc.add(LoadCategories());
      budgetBloc.add(LoadBudgets());
      settingsBloc.add(LoadSettings());

      if (!mounted) return;
      MHelperFunctions.showSnackBar(
        context: context,
        title: 'Restore complete',
        message: 'Your data was restored from the backup file',
        bgColor: Colors.green,
        icon: Icons.check_circle,
      );
    } on BackupException catch (e) {
      if (!mounted) return;
      MHelperFunctions.showSnackBar(
        context: context,
        title: 'Restore failed',
        message: e.message,
        bgColor: Colors.red,
        icon: Icons.error,
      );
    } catch (e) {
      if (!mounted) return;
      MHelperFunctions.showSnackBar(
        context: context,
        title: 'Restore failed',
        message: e.toString(),
        bgColor: Colors.red,
        icon: Icons.error,
      );
    } finally {
      if (mounted) setState(() => _isBackupBusy = false);
    }
  }

  Future<void> _resetAllData() async {
    final confirmed = await _confirmAction(
      title: 'Reset all data?',
      message:
          'This will delete all transactions, categories, budgets, photos, and reset your profile, theme, and currency. This cannot be undone.',
      confirmLabel: 'Reset',
      isDestructive: true,
      icon: Icons.delete_forever_outlined,
    );
    if (!confirmed || !mounted) return;

    final transactionBloc = context.read<TransactionBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    final budgetBloc = context.read<BudgetBloc>();
    final settingsBloc = context.read<SettingsBloc>();
    await ReceiptStorage().clearAll();
    await transactionBloc.repository.clearAll();
    await categoryBloc.repository.clearAll();
    await budgetBloc.repository.clearAll();
    await settingsBloc.repository.resetToDefaults();
    transactionBloc.add(LoadTransaction());
    categoryBloc.add(LoadCategories());
    budgetBloc.add(LoadBudgets());
    settingsBloc.add(LoadSettings());
    setState(() {
      _isEditingName = false;
      _loadedName = null;
    });

    if (!mounted) return;
    MHelperFunctions.showSnackBar(
      context: context,
      title: 'Reset complete',
      message: 'All app data and settings were restored to defaults',
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
    return Scaffold(
      appBar: tabScreenAppBar(context, title: 'Settings'),
      body: BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoading || state is SettingsInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SettingsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(MSizes.defaultSpace),
              child: MEmptyState(
                icon: Icons.error_outline,
                title: 'Could not load settings',
                subtitle: state.message,
                actionLabel: 'Try again',
                onAction: () {
                  context.read<SettingsBloc>().add(LoadSettings());
                },
              ),
            ),
          );
        }

        final settings = (state as SettingsLoaded).settings;
        final isDark = MHelperFunctions.isDarkMode(context);
        _syncNameField(settings.userName);

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            MSizes.defaultSpace,
            MSizes.sm,
            MSizes.defaultSpace,
            MSizes.lg,
          ),
          children: [
            _SettingsSectionCard(
              isDark: isDark,
              title: 'Profile',
              child: _buildProfileSection(settings),
            ),
            const SizedBox(height: MSizes.md),
            _SettingsSectionCard(
              isDark: isDark,
              title: 'Appearance',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: MSizes.sm),
                  SegmentedButton<ThemeMode>(
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
                  const SizedBox(height: MSizes.md),
                  Text(
                    'Currency',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: MSizes.sm),
                  Wrap(
                    spacing: MSizes.sm,
                    runSpacing: MSizes.sm,
                    children: CurrencyOptions.symbols.map((symbol) {
                      final selected = settings.currencySymbol == symbol;
                      return ChoiceChip(
                        label: Text(
                          symbol,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        selected: selected,
                        onSelected: (_) {
                          context
                              .read<SettingsBloc>()
                              .add(UpdateCurrencySymbol(symbol));
                        },
                        selectedColor: MColors.primary.withValues(alpha: 0.2),
                        side: BorderSide(
                          color: selected
                              ? MColors.primary
                              : (isDark
                                  ? MColors.outline
                                  : MColors.outline.withValues(alpha: 0.5)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: MSizes.md),
            _SettingsSectionCard(
              isDark: isDark,
              title: 'Manage',
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
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Manage budgets',
                    subtitle: 'Set monthly limits for expenses and categories',
                    onTap: () {
                      MHelperFunctions.navigateToScreen(
                        context,
                        const ManageBudgetsScreen(),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: MSizes.md),
            _SettingsSectionCard(
              isDark: isDark,
              title: 'Security',
              child: Column(
                children: [
                  _SettingsSwitchTile(
                    icon: Icons.lock_outline,
                    title: 'App lock',
                    subtitle: settings.lockEnabled
                        ? 'Require PIN when opening the app'
                        : 'Protect the app with a 4-digit PIN',
                    value: settings.lockEnabled,
                    onChanged: (value) => _onLockToggle(value, settings),
                  ),
                  const SizedBox(height: MSizes.sm),
                  _SettingsSwitchTile(
                    icon: Icons.fingerprint,
                    title: 'Biometric unlock',
                    subtitle: _biometricSubtitle(settings),
                    value: settings.useBiometric,
                    onChanged: settings.lockEnabled && _biometricAvailable == true
                        ? (value) => _onBiometricToggle(value, settings)
                        : null,
                  ),
                  if (settings.lockEnabled) ...[
                    const SizedBox(height: MSizes.sm),
                    _SettingsTile(
                      icon: Icons.pin_outlined,
                      title: 'Change PIN',
                      subtitle: 'Update your 4-digit unlock PIN',
                      onTap: () => _changePin(settings),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: MSizes.md),
            _SettingsSectionCard(
              isDark: isDark,
              title: 'Backup & restore',
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.folder_zip_outlined,
                    title: 'Export backup',
                    subtitle: _isBackupBusy
                        ? 'Please wait...'
                        : 'ZIP file with data.json and photo files',
                    onTap: _isBackupBusy ? null : _exportBackup,
                  ),
                  const SizedBox(height: MSizes.sm),
                  _SettingsTile(
                    icon: Icons.restore_outlined,
                    title: 'Restore backup',
                    subtitle: 'Replace current data from a .zip or .json backup',
                    onTap: _isBackupBusy ? null : _restoreBackup,
                  ),
                  const SizedBox(height: MSizes.sm),
                  _SettingsTile(
                    icon: Icons.table_chart_outlined,
                    title: 'Export all transactions (CSV)',
                    subtitle: _isExportBusy
                        ? 'Please wait...'
                        : 'Full spreadsheet export for Excel or Google Sheets',
                    onTap: _isExportBusy || _isBackupBusy || _isReportBusy
                        ? null
                        : () => _exportCsv(settings),
                  ),
                  const SizedBox(height: MSizes.sm),
                  _SettingsTile(
                    icon: Icons.picture_as_pdf_outlined,
                    title: 'Monthly report (CSV + PDF)',
                    subtitle: _isReportBusy
                        ? 'Please wait...'
                        : 'Pick a month and share income, expense, and transactions',
                    onTap: _isExportBusy || _isBackupBusy || _isReportBusy
                        ? null
                        : () => _exportMonthlyReport(settings),
                  ),
                ],
              ),
            ),
            const SizedBox(height: MSizes.md),
            _SettingsSectionCard(
              isDark: isDark,
              title: 'Clear & reset',
              child: Column(
                children: [
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
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Clear budgets',
                    subtitle: 'Remove all monthly spending limits',
                    onTap: _clearBudgets,
                  ),
                  const SizedBox(height: MSizes.sm),
                  _SettingsTile(
                    icon: Icons.delete_forever_outlined,
                    title: 'Reset all data',
                    subtitle: 'Delete everything and restore defaults',
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
                    subtitle: '${AppBranding.version} · ${AppBranding.applicationId}',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
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

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

    return Material(
      color: isDark ? MColors.dark : MColors.bgLight,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: MSizes.sm,
          vertical: MSizes.sm,
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeThumbColor: MColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
