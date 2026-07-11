import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/constants/app_branding.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/security/lock_service.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';
import 'package:money_tracker_app/features/security/view/pin_entry_sheet.dart';
import 'package:money_tracker_app/features/settings/bloc/settings_bloc.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({
    super.key,
    required this.lockService,
    required this.onUnlocked,
    this.onBiometricAuthStateChanged,
  });

  final LockService lockService;
  final VoidCallback onUnlocked;
  final ValueChanged<bool>? onBiometricAuthStateChanged;

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _biometricAvailable = false;
  bool _autoBiometricAttempted = false;
  bool _unlocked = false;
  String _entry = '';
  bool _isVerifying = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBiometricAvailability();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometricUnlock(auto: true));
  }

  Future<void> _loadBiometricAvailability() async {
    final settingsState = context.read<SettingsBloc>().state;
    final useBiometric = settingsState is SettingsLoaded
        ? settingsState.settings.useBiometric
        : false;
    if (!useBiometric) return;

    final available = await widget.lockService.canUseBiometrics();
    if (!mounted) return;
    setState(() => _biometricAvailable = available);
  }

  Future<void> _tryBiometricUnlock({bool auto = false}) async {
    if (_unlocked || _isVerifying) return;
    if (auto) {
      if (_autoBiometricAttempted) return;
      _autoBiometricAttempted = true;
    }

    final settingsState = context.read<SettingsBloc>().state;
    if (settingsState is! SettingsLoaded ||
        !settingsState.settings.useBiometric) {
      return;
    }

    final available = await widget.lockService.canUseBiometrics();
    if (!available || !mounted || _unlocked) return;

    widget.onBiometricAuthStateChanged?.call(true);
    try {
      final authenticated =
          await widget.lockService.authenticateWithBiometrics();
      if (!mounted || _unlocked) return;

      if (authenticated) {
        _unlocked = true;
        widget.onUnlocked();
      }
    } finally {
      widget.onBiometricAuthStateChanged?.call(false);
    }
  }

  void _showPinError(String message) {
    HapticFeedback.mediumImpact();
    setState(() {
      _hasError = true;
      _errorMessage = message;
      _entry = '';
      _isVerifying = false;
    });
  }

  void _onDigit(String digit) {
    if (_unlocked || _isVerifying || _entry.length >= LockService.pinLength) {
      return;
    }
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _entry += digit;
    });
    HapticFeedback.selectionClick();
    if (_entry.length == LockService.pinLength) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_unlocked || _isVerifying || _entry.isEmpty) return;
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _entry = _entry.substring(0, _entry.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _isVerifying = true);
    final valid = await widget.lockService.verifyPin(_entry);
    if (!mounted || _unlocked) return;

    if (valid) {
      _unlocked = true;
      widget.onUnlocked();
      return;
    }

    _showPinError('Incorrect PIN. Try again.');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final settingsState = context.watch<SettingsBloc>().state;
    final useBiometric = settingsState is SettingsLoaded
        ? settingsState.settings.useBiometric
        : false;
    final showBiometricButton = useBiometric && _biometricAvailable;

    return Material(
      color: isDark ? MColors.dark : MColors.light,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(MSizes.defaultSpace),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                padding: const EdgeInsets.all(MSizes.lg),
                decoration: BoxDecoration(
                  color: MColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  showBiometricButton
                      ? Icons.fingerprint
                      : Icons.lock_outline_rounded,
                  size: 48,
                  color: MColors.primary,
                ),
              ),
              const SizedBox(height: MSizes.lg),
              Text(
                AppBranding.displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: MSizes.xs),
              Text(
                showBiometricButton
                    ? 'Use fingerprint or enter PIN'
                    : 'Enter your PIN to continue',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
              if (showBiometricButton) ...[
                const SizedBox(height: MSizes.md),
                OutlinedButton.icon(
                  onPressed: () => _tryBiometricUnlock(auto: false),
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock with fingerprint'),
                ),
              ],
              const SizedBox(height: MSizes.lg),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: PinDots(
                  key: ValueKey('${_entry.length}_$_hasError'),
                  length: LockService.pinLength,
                  filledCount: _entry.length,
                  hasError: _hasError,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: MSizes.sm),
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ] else if (_isVerifying) ...[
                const SizedBox(height: MSizes.sm),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
              const Spacer(),
              PinKeypad(
                showBiometric: false,
                onDigit: _onDigit,
                onBackspace: _onBackspace,
              ),
              const SizedBox(height: MSizes.lg),
            ],
          ),
        ),
      ),
    );
  }
}
