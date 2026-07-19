import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/privacy/privacy_pin_service.dart';
import '../../features/settings/domain/entities/user_settings.dart';
import '../../features/settings/presentation/providers/settings_controller.dart';

class PrivacyGate extends ConsumerStatefulWidget {
  const PrivacyGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<PrivacyGate> createState() => _PrivacyGateState();
}

class _PrivacyGateState extends ConsumerState<PrivacyGate>
    with WidgetsBindingObserver {
  static const MethodChannel _privacyChannel = MethodChannel('oasis/privacy');

  final _pinController = TextEditingController();
  final _localAuth = LocalAuthentication();

  bool _locked = false;
  bool _pinVerified = false;
  bool _biometricVerified = false;
  bool _biometricAvailable = false;
  bool _biometricAvailabilityResolved = false;
  bool _secureFlagApplied = false;
  bool _policyInitialized = false;
  bool _repairingPolicy = false;
  int? _lastPolicyHash;
  String? _errorMessage;
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBiometricAvailability();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final settings = ref.read(settingsControllerProvider).valueOrNull;
    if (settings == null) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgroundedAt = DateTime.now();
      if (settings.privacyRefugeMode && settings.privacyLockEnabled) {
        _lockNow();
      }
      return;
    }

    if (state == AppLifecycleState.resumed && _backgroundedAt != null) {
      final autoLockMinutes = settings.privacyAutoLockMinutes;
      if (settings.privacyLockEnabled && autoLockMinutes > 0) {
        final diff = DateTime.now().difference(_backgroundedAt!);
        if (diff.inMinutes >= autoLockMinutes) {
          _lockNow();
        }
      }
    }
  }

  Future<void> _loadBiometricAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final supported = await _localAuth.isDeviceSupported();
      if (!mounted) return;
      setState(() {
        _biometricAvailable = canCheck && supported;
        _biometricAvailabilityResolved = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _biometricAvailable = false;
        _biometricAvailabilityResolved = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).valueOrNull;
    if (settings != null) {
      final policyHash = Object.hash(
        settings.privacyLockEnabled,
        settings.privacyUsePin,
        settings.privacyUseBiometric,
        settings.privacyHideInRecents,
        settings.privacyAutoLockMinutes,
        settings.privacyRefugeMode,
      );
      if (_lastPolicyHash != policyHash) {
        _lastPolicyHash = policyHash;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          unawaited(_syncPolicy(settings));
        });
      }
    }

    final shouldLock = _shouldLock(settings);
    final accessGranted = settings == null ? true : _isAccessGranted(settings);
    final effectiveLocked = _locked || (_policyInitialized && shouldLock && !accessGranted);

    if (!shouldLock) {
      return widget.child;
    }

    if (!effectiveLocked) {
      return widget.child;
    }

    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (overlayContext) {
            return Material(
              color: const Color(0xFFF7F3EC),
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('🔒', style: TextStyle(fontSize: 44)),
                          const SizedBox(height: 16),
                          Text(
                            'Desbloquear OASIS',
                            style: Theme.of(overlayContext).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tu espacio permanece protegido en este dispositivo.',
                            style: Theme.of(overlayContext).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (settings?.privacyUsePin == true) ...[
                            TextField(
                              controller: _pinController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              autocorrect: false,
                              enableSuggestions: false,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(8),
                              ],
                              onSubmitted: (_) => _unlockWithPin(settings!),
                              enableInteractiveSelection: false,
                              decoration: const InputDecoration(
                                labelText: 'PIN',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => _unlockWithPin(settings),
                                child: Text(
                                  settings!.privacyUseBiometric
                                      ? 'Validar PIN'
                                      : 'Desbloquear',
                                ),
                              ),
                            ),
                            if (_pinVerified && settings.privacyUseBiometric)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text('PIN verificado'),
                              ),
                          ],
                          if (settings?.privacyUseBiometric == true) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: _biometricAvailable
                                    ? () => _unlockWithBiometrics(settings!)
                                    : null,
                                child: Text(
                                  settings!.privacyUsePin
                                      ? 'Validar huella'
                                      : 'Usar huella',
                                ),
                              ),
                            ),
                            if (!_biometricAvailable)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'La biometría no está disponible en este dispositivo.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (_biometricVerified && settings.privacyUsePin)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text('Huella verificada'),
                              ),
                          ],
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Theme.of(overlayContext).colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  bool _shouldLock(UserSettings? settings) {
    if (settings == null || !settings.privacyLockEnabled) {
      return false;
    }
    return settings.privacyUsePin || settings.privacyUseBiometric;
  }

  bool _isAccessGranted(UserSettings settings) {
    final pinReady = !settings.privacyUsePin || _pinVerified;
    final bioReady = !settings.privacyUseBiometric || _biometricVerified;
    return pinReady && bioReady;
  }

  Future<void> _syncPolicy(UserSettings settings) async {
    if (_repairingPolicy) {
      return;
    }

    if (_secureFlagApplied != settings.privacyHideInRecents) {
      _applySecureFlag(settings.privacyHideInRecents);
    }

    final shouldLock = _shouldLock(settings);
    if (!shouldLock) {
      _policyInitialized = true;
      if (_locked) {
        setState(() {
          _locked = false;
          _pinVerified = false;
          _biometricVerified = false;
          _errorMessage = null;
        });
      }
      return;
    }

    if (!_biometricAvailabilityResolved) {
      return;
    }

    final hasPin = await PrivacyPinService.hasPin();
    if (!mounted) return;

    final normalized = _normalizePrivacyPolicy(settings, hasPin);
    if (normalized != settings) {
      _repairingPolicy = true;
      try {
        await ref.read(settingsControllerProvider.notifier).saveSettings(
              normalized,
            );
      } finally {
        _repairingPolicy = false;
      }
      if (!mounted) return;
      return;
    }

    _policyInitialized = true;
    if (_shouldLock(settings) && !_isAccessGranted(settings)) {
      _lockNow();
    }
  }

  UserSettings _normalizePrivacyPolicy(UserSettings settings, bool hasPin) {
    if (!settings.privacyLockEnabled) {
      return settings;
    }

    if (settings.privacyUsePin && settings.privacyUseBiometric) {
      if (hasPin && _biometricAvailable) {
        return settings;
      }
      if (hasPin) {
        return settings.copyWith(privacyUseBiometric: false);
      }
      if (_biometricAvailable) {
        return settings.copyWith(privacyUsePin: false);
      }
      return settings.copyWith(
        privacyLockEnabled: false,
        privacyUsePin: false,
        privacyUseBiometric: false,
      );
    }

    if (settings.privacyUsePin) {
      if (hasPin) {
        return settings;
      }
      return settings.copyWith(
        privacyLockEnabled: false,
        privacyUsePin: false,
      );
    }

    if (settings.privacyUseBiometric) {
      if (_biometricAvailable) {
        return settings;
      }
      return settings.copyWith(
        privacyLockEnabled: false,
        privacyUseBiometric: false,
      );
    }

    return settings.copyWith(privacyLockEnabled: false);
  }

  Future<void> _applySecureFlag(bool enabled) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      _secureFlagApplied = enabled;
      return;
    }

    try {
      await _privacyChannel.invokeMethod<void>('setSecureFlag', {
        'enabled': enabled,
      });
      _secureFlagApplied = enabled;
    } catch (_) {
      _secureFlagApplied = false;
    }
  }

  void _lockNow() {
    if (!mounted) return;
    if (_locked) return;
    setState(() {
      _locked = true;
      _pinVerified = false;
      _biometricVerified = false;
      _errorMessage = null;
    });
  }

  Future<void> _unlockWithPin(UserSettings settings) async {
    final valid = await PrivacyPinService.verifyPin(_pinController.text.trim());
    if (!mounted) return;
    if (!valid) {
      setState(() => _errorMessage = 'El PIN no coincide.');
      return;
    }
    setState(() {
      _pinVerified = true;
      _errorMessage = null;
    });
    _finishUnlockIfComplete(settings);
  }

  Future<void> _unlockWithBiometrics(UserSettings settings) async {
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: 'Desbloquear OASIS',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
      if (!mounted) return;
      if (!ok) {
        setState(() => _errorMessage = 'No se pudo validar la biometría.');
        return;
      }
      setState(() {
        _biometricVerified = true;
        _errorMessage = null;
      });
      _finishUnlockIfComplete(settings);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'La biometría no está disponible ahora.');
    }
  }

  void _finishUnlockIfComplete(UserSettings settings) {
    final pinReady = !settings.privacyUsePin || _pinVerified;
    final bioReady = !settings.privacyUseBiometric || _biometricVerified;
    if (!pinReady || !bioReady) {
      return;
    }
    setState(() {
      _locked = false;
      _pinController.clear();
      _errorMessage = null;
    });
  }
}
