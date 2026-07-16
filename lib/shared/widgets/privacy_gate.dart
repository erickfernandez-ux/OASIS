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
  bool _secureFlagApplied = false;
  bool _policyInitialized = false;
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
      setState(() => _biometricAvailable = canCheck && supported);
    } catch (_) {
      if (!mounted) return;
      setState(() => _biometricAvailable = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).valueOrNull;
    if (settings != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncPolicy(settings);
      });
    }

    final shouldLock = _shouldLock(settings);
    final effectiveLocked = _locked || (!_policyInitialized && shouldLock);

    if (!shouldLock) {
      return widget.child;
    }

    if (!effectiveLocked) {
      return widget.child;
    }

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
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tu espacio permanece protegido en este dispositivo.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (settings?.privacyUsePin == true) ...[
                    TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 8,
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
                        color: Theme.of(context).colorScheme.error,
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
  }

  bool _shouldLock(UserSettings? settings) {
    if (settings == null || !settings.privacyLockEnabled) {
      return false;
    }
    return settings.privacyUsePin || settings.privacyUseBiometric;
  }

  void _syncPolicy(UserSettings settings) {
    if (_secureFlagApplied != settings.privacyHideInRecents) {
      _applySecureFlag(settings.privacyHideInRecents);
    }

    if (!_policyInitialized) {
      _policyInitialized = true;
      if (_shouldLock(settings)) {
        _lockNow();
      }
    }

    if (!_shouldLock(settings) && _locked) {
      setState(() {
        _locked = false;
        _pinVerified = false;
        _biometricVerified = false;
        _errorMessage = null;
      });
    }
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
    setState(() {
      _locked = true;
      _pinVerified = false;
      _biometricVerified = false;
      _pinController.clear();
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
      _pinVerified = false;
      _biometricVerified = false;
      _pinController.clear();
      _errorMessage = null;
    });
  }
}
