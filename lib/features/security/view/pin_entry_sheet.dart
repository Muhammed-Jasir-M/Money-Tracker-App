import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_tracker_app/core/constants/colors.dart';
import 'package:money_tracker_app/core/constants/sizes.dart';
import 'package:money_tracker_app/core/security/lock_service.dart';
import 'package:money_tracker_app/core/utils/helper_functions.dart';

class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    this.onBiometric,
    this.showBiometric = false,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;
  final bool showBiometric;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: MSizes.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row
                  .map(
                    (digit) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: MSizes.sm),
                      child: _KeyButton(
                        label: digit,
                        onTap: () => onDigit(digit),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showBiometric)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: MSizes.sm),
                child: _KeyButton(
                  icon: Icons.fingerprint,
                  onTap: onBiometric,
                ),
              )
            else
              const SizedBox(width: 72 + MSizes.sm * 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MSizes.sm),
              child: _KeyButton(
                label: '0',
                onTap: () => onDigit('0'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MSizes.sm),
              child: _KeyButton(
                icon: Icons.backspace_outlined,
                onTap: onBackspace,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    this.label,
    this.icon,
    this.onTap,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap!();
              },
        borderRadius: BorderRadius.circular(36),
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? MColors.cardDark
                : MColors.cardLight,
            border: Border.all(
              color: isDark
                  ? MColors.outline.withValues(alpha: 0.35)
                  : MColors.outline.withValues(alpha: 0.25),
            ),
          ),
          child: icon != null
              ? Icon(icon, color: MColors.primary, size: 28)
              : Text(
                  label ?? '',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
        ),
      ),
    );
  }
}

class PinDots extends StatefulWidget {
  const PinDots({
    super.key,
    required this.length,
    required this.filledCount,
    this.hasError = false,
  });

  final int length;
  final int filledCount;
  final bool hasError;

  @override
  State<PinDots> createState() => _PinDotsState();
}

class _PinDotsState extends State<PinDots> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final accent = widget.hasError ? Colors.red : MColors.primary;
    final emptyBorder = widget.hasError
        ? Colors.red.withValues(alpha: 0.45)
        : (isDark
            ? Colors.white.withValues(alpha: 0.35)
            : MColors.primary.withValues(alpha: 0.35));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (index) {
            final filled = index < widget.filledCount;
            final isActive =
                !widget.hasError && index == widget.filledCount && !filled;

            Widget dot = AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: filled ? 18 : 16,
              height: filled ? 18 : 16,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? accent : Colors.transparent,
                border: Border.all(
                  color: filled ? accent : emptyBorder,
                  width: filled ? 0 : 2.5,
                ),
                boxShadow: filled
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            );

            if (isActive) {
              dot = ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.08).animate(
                  CurvedAnimation(
                    parent: _pulseController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: accent, width: 2.5),
                  ),
                ),
              );
            }

            return dot;
          }),
        ),
        const SizedBox(height: MSizes.sm),
        Text(
          _maskedLabel(widget.filledCount, widget.length),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                letterSpacing: 10,
                fontWeight: FontWeight.w700,
                color: widget.hasError
                    ? Colors.red
                    : Theme.of(context).colorScheme.onSurface.withValues(
                          alpha: widget.filledCount == 0 ? 0.35 : 0.85,
                        ),
              ),
        ),
      ],
    );
  }

  String _maskedLabel(int filled, int length) {
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(i < filled ? '●' : '○');
      if (i < length - 1) buffer.write(' ');
    }
    return buffer.toString();
  }
}

enum PinEntryMode { unlock, setup, confirm, verifyCurrent, verifyToDisable }

class PinEntrySheet extends StatefulWidget {
  const PinEntrySheet({
    super.key,
    required this.mode,
    required this.onCompleted,
    this.verifyPin,
    this.showBiometric = false,
    this.onBiometric,
  });

  final PinEntryMode mode;
  final Future<void> Function(String pin) onCompleted;
  final Future<bool> Function(String pin)? verifyPin;
  final bool showBiometric;
  final VoidCallback? onBiometric;

  static Future<bool?> show({
    required BuildContext context,
    required PinEntryMode mode,
    required Future<void> Function(String pin) onCompleted,
    Future<bool> Function(String pin)? verifyPin,
    bool showBiometric = false,
    VoidCallback? onBiometric,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: mode != PinEntryMode.unlock,
      enableDrag: mode != PinEntryMode.unlock,
      backgroundColor: Colors.transparent,
      builder: (context) => PinEntrySheet(
        mode: mode,
        onCompleted: onCompleted,
        verifyPin: verifyPin,
        showBiometric: showBiometric,
        onBiometric: onBiometric,
      ),
    );
  }

  @override
  State<PinEntrySheet> createState() => _PinEntrySheetState();
}

class _PinEntrySheetState extends State<PinEntrySheet> {
  String _entry = '';
  String? _setupPin;
  bool _confirmingSetup = false;
  bool _hasError = false;
  bool _isBusy = false;
  String? _errorMessage;

  PinEntryMode get _effectiveMode =>
      widget.mode == PinEntryMode.setup && _confirmingSetup
          ? PinEntryMode.confirm
          : widget.mode;

  String get _title => switch (_effectiveMode) {
        PinEntryMode.unlock => 'Enter PIN',
        PinEntryMode.setup => 'Create PIN',
        PinEntryMode.confirm => 'Confirm PIN',
        PinEntryMode.verifyCurrent => 'Enter current PIN',
        PinEntryMode.verifyToDisable => 'Enter PIN to disable lock',
      };

  String get _subtitle => switch (_effectiveMode) {
        PinEntryMode.unlock => 'Unlock Money Tracker',
        PinEntryMode.setup => 'Choose a ${LockService.pinLength}-digit PIN',
        PinEntryMode.confirm => 'Re-enter your PIN',
        PinEntryMode.verifyCurrent => 'Verify before changing your PIN',
        PinEntryMode.verifyToDisable => 'Your PIN is required to turn off app lock',
      };

  @override
  Widget build(BuildContext context) {
    final isDark = MHelperFunctions.isDarkMode(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? MColors.cardDark : MColors.cardLight,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(MSizes.borderRadiusLg),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(
          MSizes.defaultSpace,
          MSizes.md,
          MSizes.defaultSpace,
          MSizes.lg,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MColors.outline.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: MSizes.lg),
              Text(
                _title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: MSizes.xs),
              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(height: MSizes.lg),
              PinDots(
                length: LockService.pinLength,
                filledCount: _entry.length,
                hasError: _hasError,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: MSizes.sm),
                Text(
                  _errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                ),
              ],
              const SizedBox(height: MSizes.lg),
              if (_isBusy)
                const Padding(
                  padding: EdgeInsets.all(MSizes.lg),
                  child: CircularProgressIndicator(),
                )
              else
                PinKeypad(
                  onDigit: _onDigit,
                  onBackspace: _onBackspace,
                  showBiometric:
                      widget.mode == PinEntryMode.unlock && widget.showBiometric,
                  onBiometric: widget.onBiometric,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onDigit(String digit) {
    if (_isBusy || _entry.length >= LockService.pinLength) return;
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _entry += digit;
    });

    if (_entry.length == LockService.pinLength) {
      _submitEntry();
    }
  }

  void _onBackspace() {
    if (_isBusy || _entry.isEmpty) return;
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _entry = _entry.substring(0, _entry.length - 1);
    });
  }

  Future<void> _submitEntry() async {
    setState(() => _isBusy = true);

    try {
      switch (_effectiveMode) {
        case PinEntryMode.setup:
          _setupPin = _entry;
          setState(() {
            _entry = '';
            _confirmingSetup = true;
            _isBusy = false;
          });
          return;

        case PinEntryMode.confirm:
          if (_entry != _setupPin) {
            _showPinError('PINs do not match. Try again.');
            setState(() {
              _confirmingSetup = false;
              _setupPin = null;
            });
            return;
          }
          await widget.onCompleted(_entry);
          if (mounted) Navigator.of(context).pop(true);
          return;

        case PinEntryMode.verifyCurrent:
        case PinEntryMode.verifyToDisable:
        case PinEntryMode.unlock:
          final verify = widget.verifyPin;
          if (verify == null) {
            await widget.onCompleted(_entry);
            if (mounted) Navigator.of(context).pop(true);
            return;
          }
          final valid = await verify(_entry);
          if (!valid) {
            _showPinError('Incorrect PIN');
            return;
          }
          await widget.onCompleted(_entry);
          if (mounted && widget.mode != PinEntryMode.unlock) {
            Navigator.of(context).pop(true);
          }
          return;
      }
    } catch (e) {
      _showPinError(e.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showPinError(String message) {
    HapticFeedback.mediumImpact();
    setState(() {
      _hasError = true;
      _errorMessage = message;
      _entry = '';
      _isBusy = false;
    });
  }
}
