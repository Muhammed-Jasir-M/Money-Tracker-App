import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_app/core/security/lock_service.dart';
import 'package:money_tracker_app/data/models/settings/app_settings.dart';
import 'package:money_tracker_app/features/security/view/lock_screen.dart';
import 'package:money_tracker_app/features/settings/bloc/settings_bloc.dart';

class LockGate extends StatefulWidget {
  const LockGate({
    super.key,
    required this.child,
    this.lockService,
  });

  final Widget child;
  final LockService? lockService;

  @override
  State<LockGate> createState() => LockGateState();
}

class LockGateState extends State<LockGate> with WidgetsBindingObserver {
  late final LockService _lockService = widget.lockService ?? LockService();

  bool _isLocked = false;
  bool _initialized = false;
  bool _wentToBackground = false;
  bool _biometricAuthInProgress = false;
  DateTime? _unlockedAt;

  LockService get lockService => _lockService;

  void setBiometricAuthInProgress(bool inProgress) {
    _biometricAuthInProgress = inProgress;
  }

  void unlock() {
    setState(() {
      _isLocked = false;
      _initialized = true;
      _wentToBackground = false;
      _biometricAuthInProgress = false;
      _unlockedAt = DateTime.now();
    });
  }

  void lock() {
    if (_currentSettings?.lockEnabled != true) return;
    setState(() => _isLocked = true);
  }

  AppSettings? get _currentSettings {
    final state = context.read<SettingsBloc>().state;
    return state is SettingsLoaded ? state.settings : null;
  }

  bool get _lockEnabled => _currentSettings?.lockEnabled == true;

  bool get _shouldShowLock =>
      _isLocked || (!_initialized && _lockEnabled);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeLockState());
  }

  Future<void> _initializeLockState() async {
    if (!_lockEnabled) {
      if (!mounted) return;
      setState(() {
        _isLocked = false;
        _initialized = true;
      });
      return;
    }

    var hasPin = false;
    try {
      hasPin = await _lockService.hasPin();
    } on LockException {
      hasPin = false;
    }
    if (!mounted) return;

    setState(() {
      _isLocked = hasPin;
      _initialized = true;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only true background — not inactive (biometric/permission dialogs).
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _wentToBackground = true;
      return;
    }

    if (state != AppLifecycleState.resumed || !_wentToBackground) return;

    _wentToBackground = false;

    if (_biometricAuthInProgress) return;

    final unlockedAt = _unlockedAt;
    if (unlockedAt != null &&
        DateTime.now().difference(unlockedAt) < const Duration(seconds: 2)) {
      return;
    }

    if (_lockEnabled) {
      setState(() => _isLocked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showLock = _shouldShowLock;

    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) {
        if (current is! SettingsLoaded) return false;
        if (previous is! SettingsLoaded) return true;
        return previous.settings.lockEnabled != current.settings.lockEnabled;
      },
      listener: (context, state) {
        if (state is! SettingsLoaded) return;
        if (!state.settings.lockEnabled) {
          setState(() => _isLocked = false);
        }
      },
      child: Stack(
        children: [
          Offstage(
            offstage: showLock,
            child: widget.child,
          ),
          if (showLock)
            Positioned.fill(
              child: LockScreen(
                lockService: _lockService,
                onUnlocked: unlock,
                onBiometricAuthStateChanged: setBiometricAuthInProgress,
              ),
            ),
        ],
      ),
    );
  }
}
