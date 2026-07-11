import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class LockException implements Exception {
  LockException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LockService {
  LockService({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
  })  : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            ),
        _localAuth = localAuth ?? LocalAuthentication();

  static const pinLength = 4;
  static const _pinHashKey = 'app_pin_hash';

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;

  Future<bool> hasPin() async {
    final hash = await _readPinHash();
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    _validatePinFormat(pin);
    await _writePinHash(_hashPin(pin));
  }

  Future<bool> verifyPin(String pin) async {
    _validatePinFormat(pin);
    final stored = await _readPinHash();
    if (stored == null || stored.isEmpty) return false;
    return stored == _hashPin(pin);
  }

  Future<void> clearPin() async {
    await _deletePinHash();
  }

  Future<bool> canUseBiometrics() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;

      final canCheck = await _localAuth.canCheckBiometrics;
      if (canCheck) {
        final available = await _localAuth.getAvailableBiometrics();
        if (available.isNotEmpty) return true;
      }

      // Some Android OEMs (e.g. Honor) report an empty list even when enrolled.
      return isSupported && canCheck;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics({String? reason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason ?? 'Unlock Money Tracker',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on MissingPluginException {
      throw LockException(
        'Biometrics plugin is not ready. Fully stop the app, then run flutter run again.',
      );
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable' ||
          e.code == 'NotEnrolled' ||
          e.code == 'PasscodeNotSet') {
        throw LockException(
          'Set up fingerprint or face unlock in your device settings first.',
        );
      }
      return false;
    }
  }

  Future<String?> _readPinHash() {
    return _guardStorage(
      () => _secureStorage.read(key: _pinHashKey),
    );
  }

  Future<void> _writePinHash(String hash) {
    return _guardStorage(
      () => _secureStorage.write(key: _pinHashKey, value: hash),
    );
  }

  Future<void> _deletePinHash() {
    return _guardStorage(
      () => _secureStorage.delete(key: _pinHashKey),
    );
  }

  Future<T> _guardStorage<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on MissingPluginException {
      throw LockException(
        'Secure storage is not ready. Fully stop the app, then run flutter run again.',
      );
    } on PlatformException catch (e) {
      throw LockException(
        e.message ?? 'Could not access secure storage on this device.',
      );
    }
  }

  void _validatePinFormat(String pin) {
    if (pin.length != pinLength || int.tryParse(pin) == null) {
      throw LockException('PIN must be $pinLength digits');
    }
  }

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }
}
