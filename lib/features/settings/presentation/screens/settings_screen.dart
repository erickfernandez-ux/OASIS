import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/privacy/privacy_data_service.dart';
import '../../../../core/privacy/privacy_pin_service.dart';
import '../../../../core/design/design_system.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/utils/local_json_store.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../medications/domain/entities/medication.dart';
import '../../../medications/domain/value_objects/dosage.dart';
import '../../../medications/presentation/providers/medications_controller.dart';
import '../../../rituals/application/providers/ritual_providers.dart';
import '../../../rituals/domain/defaults/ritual_defaults.dart';
import '../../../rituals/domain/entities/quiet_hours.dart';
import '../../../rituals/domain/entities/ritual.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/enums/canvas_intensity_preference.dart';
import '../../domain/enums/canvas_motion_preference.dart';
import '../../domain/enums/canvas_style_preference.dart';
import '../../domain/enums/theme_mode_preference.dart';
import '../providers/settings_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const Duration _hoverDuration = MotionSpec.hover;
  static const Duration _selectionFade = MotionSpec.selectionFade;
  static const Duration _transitionDuration = MotionSpec.backgroundCrossfade;

  final Map<String, Color> _medicationColors = <String, Color>{};
  final Map<String, bool> _reminders = <String, bool>{
    'Agenda': true,
    'Journal': true,
    'Medicación': true,
    'Hidratación': true,
    'Caminar': false,
    'Sueño': true,
  };

  bool _reduceMotion = false;
  bool _largeText = false;
  bool _veryLargeText = false;
  bool _highContrastDraft = false;
  bool _medicationCriticalInQuietHours = defaultMedicationCriticalInQuietHours;
  int _hoveredShelterIndex = -1;
  String? _selectedShelterAsset;
  bool _ritualsLoaded = false;
  List<Ritual> _rituals = defaultRituals();
  QuietHours _quietHours = defaultQuietHours;

  String? _ambientMessage;
  Timer? _ambientMessageTimer;
  bool _savingName = false;
  bool _savingMedication = false;
  bool _exportingBackup = false;
  bool _deletingData = false;
  late Future<List<PrivacyStorageStat>> _privacyStatsFuture;

  @override
  void initState() {
    super.initState();
    _privacyStatsFuture = PrivacyDataService.collectStats();
  }

  @override
  void dispose() {
    _ambientMessageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsControllerProvider);

    if (!_ritualsLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadRitualSettings();
      });
    }

    return state.when(
      data: (settings) => AnimatedSwitcher(
        duration: _transitionDuration,
        switchInCurve: MotionSpec.easeInOut,
        switchOutCurve: MotionSpec.easeInOut,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: OasisScreenShell(
          key: ValueKey<String>(
            '${settings.canvasStyle.name}-${settings.canvasIntensity.name}-${settings.canvasMotion.name}-${settings.themeMode.name}',
          ),
          title: 'Mi Espacio',
          subtitle: 'Haz de OASIS un lugar que se sienta tuyo.',
          accent: OasisSurfaces.settingsAccent,
          environment: settings.canvasStyle,
          child: _buildContent(context, settings),
        ),
      ),
      loading: () => const Padding(
        padding: EdgeInsets.only(top: OasisSpacing.xl),
        child: Center(
          child: LoadingIndicator(type: LoadingType.breathingPaper),
        ),
      ),
      error: (error, _) => Text(error.toString()),
    );
  }

  Widget _buildContent(BuildContext context, UserSettings settings) {
    final spacing = context.appSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileSection(context, settings),
        SizedBox(height: spacing.md),
        _buildShelterSection(context, settings),
        SizedBox(height: spacing.md),
        _buildDepthSection(context, settings),
        SizedBox(height: spacing.md),
        _buildMotionSection(context, settings),
        SizedBox(height: spacing.md),
        _buildAppearanceSection(context, settings),
        SizedBox(height: spacing.md),
        _buildAccessibilitySection(context, settings),
        SizedBox(height: spacing.md),
        _buildRitualsAndRemindersSection(context, settings),
        SizedBox(height: spacing.md),
        _buildRemindersSection(context),
        SizedBox(height: spacing.md),
        _buildMedicationsSection(context),
        SizedBox(height: spacing.md),
        _buildPrivacySection(context, settings),
        SizedBox(height: spacing.lg),
        _buildInfoSection(context),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context, UserSettings settings) {
    return _cardEnvelope(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Privacidad',
            subtitle: 'Tu información permanece en tu dispositivo y bajo tu control.',
          ),
          const SizedBox(height: OasisSpacing.sm),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Bloquear OASIS'),
            subtitle: const Text('Pedir autenticación para entrar.'),
            value: settings.privacyLockEnabled,
            onChanged: (value) async {
              if (!mounted) return;
              final openPinDialog = _openPinDialog;
              if (!value) {
                await _savePrivacySettings(
                  settings.copyWith(privacyLockEnabled: false),
                );
                return;
              }

              final hasPin = await PrivacyPinService.hasPin();
              if (!hasPin) {
                await openPinDialog();
                if (!mounted) return;
              }
              final pinReady = await PrivacyPinService.hasPin();
              if (!pinReady) {
                _showSnackBar('Configura un PIN para activar el bloqueo.');
                return;
              }

              await _savePrivacySettings(
                settings.copyWith(
                  privacyLockEnabled: true,
                  privacyUsePin: true,
                  privacyUseBiometric: false,
                ),
              );
            },
          ),
          if (settings.privacyLockEnabled) ...[
            const SizedBox(height: OasisSpacing.sm),
            const Text('Método de autenticación'),
            const SizedBox(height: OasisSpacing.xs),
            Wrap(
              spacing: OasisSpacing.sm,
              runSpacing: OasisSpacing.sm,
              children: [
                ChoiceChip(
                  label: const Text('PIN'),
                  selected: _privacyAuthModeFor(settings) == _PrivacyAuthMode.pin,
                  onSelected: (_) async {
                    if (!mounted) return;
                    final openPinDialog = _openPinDialog;
                    final hasPin = await PrivacyPinService.hasPin();
                    if (!hasPin) {
                      await openPinDialog();
                      if (!mounted) return;
                    }
                    final pinReady = await PrivacyPinService.hasPin();
                    if (!pinReady) {
                      _showSnackBar('Primero configura un PIN.');
                      return;
                    }
                    await _savePrivacySettings(
                      settings.copyWith(
                        privacyUsePin: true,
                        privacyUseBiometric: false,
                      ),
                    );
                  },
                ),
                FutureBuilder<bool>(
                  future: _canUseBiometrics(),
                  builder: (context, snapshot) {
                    final canUseBiometrics = snapshot.data ?? false;
                    return ChoiceChip(
                      label: const Text('Huella'),
                      selected: _privacyAuthModeFor(settings) == _PrivacyAuthMode.biometric,
                      onSelected: canUseBiometrics
                          ? (_) => _savePrivacySettings(
                                settings.copyWith(
                                  privacyUsePin: false,
                                  privacyUseBiometric: true,
                                ),
                              )
                          : null,
                    );
                  },
                ),
                FutureBuilder<bool>(
                  future: _canUseBiometrics(),
                  builder: (context, snapshot) {
                    final canUseBiometrics = snapshot.data ?? false;
                    return ChoiceChip(
                      label: const Text('Ambos'),
                      selected: _privacyAuthModeFor(settings) == _PrivacyAuthMode.both,
                      onSelected: canUseBiometrics
                          ? (_) async {
                              if (!mounted) return;
                              final openPinDialog = _openPinDialog;
                              final hasPin = await PrivacyPinService.hasPin();
                              if (!hasPin) {
                                await openPinDialog();
                                if (!mounted) return;
                              }
                              final pinReady = await PrivacyPinService.hasPin();
                              if (!pinReady) {
                                _showSnackBar('Necesitas un PIN antes de usar ambos métodos.');
                                return;
                              }
                              await _savePrivacySettings(
                                settings.copyWith(
                                  privacyUsePin: true,
                                  privacyUseBiometric: true,
                                ),
                              );
                            }
                          : null,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: OasisSpacing.sm),
            FutureBuilder<bool>(
              future: PrivacyPinService.hasPin(),
              builder: (context, snapshot) {
                final hasPin = snapshot.data ?? false;
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasPin ? 'PIN configurado.' : 'Aún no hay PIN configurado.',
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: _openPinDialog,
                      child: Text(hasPin ? 'Cambiar PIN' : 'Configurar PIN'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: OasisSpacing.sm),
            DropdownButtonFormField<int>(
              initialValue: settings.privacyAutoLockMinutes,
              decoration: const InputDecoration(
                labelText: 'Cerrar automáticamente después de',
              ),
              items: const [
                DropdownMenuItem<int>(value: 0, child: Text('Nunca')),
                DropdownMenuItem<int>(value: 1, child: Text('1 minuto')),
                DropdownMenuItem<int>(value: 5, child: Text('5 minutos')),
                DropdownMenuItem<int>(value: 15, child: Text('15 minutos')),
              ],
              onChanged: (value) {
                if (value == null) return;
                _savePrivacySettings(
                  settings.copyWith(privacyAutoLockMinutes: value),
                );
              },
            ),
          ],
          const SizedBox(height: OasisSpacing.sm),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ocultar contenido en aplicaciones recientes'),
            subtitle: const Text('En Android activa FLAG_SECURE para evitar capturas y miniaturas.'),
            value: settings.privacyHideInRecents,
            onChanged: (value) => _savePrivacySettings(
              settings.copyWith(privacyHideInRecents: value),
            ),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Modo Refugio'),
            subtitle: const Text('Al cambiar de app, OASIS volverá a pedir desbloqueo al regresar.'),
            value: settings.privacyRefugeMode,
            onChanged: (value) => _savePrivacySettings(
              settings.copyWith(privacyRefugeMode: value),
            ),
          ),
          const SizedBox(height: OasisSpacing.md),
          const Text('Tus datos'),
          const SizedBox(height: OasisSpacing.xs),
          const Text('✓ Se almacenan localmente.'),
          const Text('✓ No se envían a servidores.'),
          const Text('✓ No se venden.'),
          const Text('✓ No se utilizan para publicidad.'),
          const Text('✓ Permanecen en tu dispositivo.'),
          const SizedBox(height: OasisSpacing.sm),
          Text(
            PrivacyDataService.platformProtectionDescription(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: OasisSpacing.md),
          const Text('Espacio ocupado'),
          const SizedBox(height: OasisSpacing.xs),
          FutureBuilder<List<PrivacyStorageStat>>(
            future: _privacyStatsFuture,
            builder: (context, snapshot) {
              final stats = snapshot.data ?? const <PrivacyStorageStat>[];
              if (snapshot.connectionState == ConnectionState.waiting && stats.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: OasisSpacing.sm),
                  child: LoadingIndicator(type: LoadingType.breathingPaper),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: stats
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${item.label.padRight(16, '.')} ${PrivacyDataService.formatBytes(item.bytes)}',
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: OasisSpacing.md),
          Wrap(
            spacing: OasisSpacing.sm,
            runSpacing: OasisSpacing.sm,
            children: [
              FilledButton.tonalIcon(
                onPressed: _exportingBackup ? null : () => _exportEncryptedBackup(context),
                icon: const Icon(Icons.enhanced_encryption_outlined),
                label: Text(_exportingBackup ? 'Exportando...' : 'Exportar backup'),
              ),
              FilledButton.tonalIcon(
                onPressed: _deletingData ? null : () => _confirmDeleteAllData(context),
                icon: const Icon(Icons.delete_forever_outlined),
                label: Text(_deletingData ? 'Eliminando...' : 'Eliminar todos mis datos'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _savePrivacySettings(UserSettings settings) async {
    await ref.read(settingsControllerProvider.notifier).saveSettings(settings);
    _refreshPrivacyStats();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<bool> _canUseBiometrics() async {
    final auth = LocalAuthentication();
    try {
      return await auth.canCheckBiometrics && await auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  _PrivacyAuthMode _privacyAuthModeFor(UserSettings settings) {
    if (settings.privacyUsePin && settings.privacyUseBiometric) {
      return _PrivacyAuthMode.both;
    }
    if (settings.privacyUseBiometric) {
      return _PrivacyAuthMode.biometric;
    }
    return _PrivacyAuthMode.pin;
  }

  void _refreshPrivacyStats() {
    setState(() {
      _privacyStatsFuture = PrivacyDataService.collectStats();
    });
  }

  Future<void> _openPinDialog() async {
    final firstController = TextEditingController();
    final secondController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AppDialog(
          title: 'Configurar PIN',
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                final first = firstController.text.trim();
                final second = secondController.text.trim();
                if (first.length < 4 || first != second) {
                  _showSnackBar('El PIN debe tener al menos 4 dígitos y coincidir.');
                  return;
                }
                await PrivacyPinService.savePin(first);
                if (!mounted || !dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                setState(() {});
                _showSnackBar('PIN guardado.');
              },
              child: const Text('Guardar'),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: firstController,
                label: 'Nuevo PIN',
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: secondController,
                label: 'Repetir PIN',
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ],
          ),
        );
      },
    );

    firstController.dispose();
    secondController.dispose();
  }

  Future<void> _exportEncryptedBackup(BuildContext context) async {
    setState(() => _exportingBackup = true);
    try {
      final result = await PrivacyDataService.exportEncryptedBackup();
      if (!mounted) return;
      _showSnackBar('Backup cifrado listo: ${result.filePath}');
      _refreshPrivacyStats();
    } finally {
      if (mounted) {
        setState(() => _exportingBackup = false);
      }
    }
  }

  Future<void> _confirmDeleteAllData(BuildContext context) async {
    final confirmController = TextEditingController();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AppDialog(
          title: 'Eliminar todos mis datos',
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (confirmController.text.trim() != 'ELIMINAR') {
                  return;
                }
                setState(() => _deletingData = true);
                await PrivacyDataService.wipeAllUserData();
                await ref
                    .read(settingsControllerProvider.notifier)
                    .saveSettings(const UserSettings());
                await ref.read(medicationsControllerProvider.notifier).refresh();
                if (!mounted || !dialogContext.mounted) return;
                setState(() {
                  _rituals = defaultRituals();
                  _quietHours = defaultQuietHours;
                  _medicationCriticalInQuietHours =
                      defaultMedicationCriticalInQuietHours;
                  _ritualsLoaded = true;
                });
                _refreshPrivacyStats();
                Navigator.pop(dialogContext);
                _showSnackBar('Tus datos locales fueron eliminados.');
                if (mounted) {
                  setState(() => _deletingData = false);
                }
              },
              child: const Text('Eliminar'),
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Esta acción requiere confirmación y no se puede deshacer.'),
              const SizedBox(height: 12),
              AppTextField(
                controller: confirmController,
                label: 'Escribe ELIMINAR',
              ),
            ],
          ),
        );
      },
    );
    confirmController.dispose();
  }

  Widget _buildProfileSection(BuildContext context, UserSettings settings) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Hero(
      tag: OasisHeroTags.settingsHeader,
      child: Material(
        type: MaterialType.transparency,
        child: _cardEnvelope(
          context,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OasisSectionHeader(
                title: 'Perfil',
                subtitle: 'Tu presencia también forma parte de este refugio.',
              ),
              const SizedBox(height: OasisSpacing.sm),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/logos/oasis_logo.png',
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: OasisSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.preferredName.trim().isEmpty
                              ? 'Tu nombre en OASIS'
                              : settings.preferredName.trim(),
                          style: typography.title,
                        ),
                        const SizedBox(height: OasisSpacing.xs),
                        Text(
                          'Más adelante podrás sumar una foto para hacerlo más tuyo.',
                          style: typography.label
                              .copyWith(color: colors.semantic.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () => _openNameDialog(context, settings),
                    child: const Text('Editar nombre'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShelterSection(BuildContext context, UserSettings settings) {
    final colors = context.appColors;
    final shelters = _shelterCards();
    final selectedAsset =
        _selectedShelterAsset ?? _defaultShelterAssetFor(settings);

    return _cardEnvelope(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Mi Refugio',
            subtitle: 'Elige el lugar donde quieres encontrarte cada día.',
          ),
          const SizedBox(height: OasisSpacing.sm),
          AnimatedSwitcher(
            duration: _selectionFade,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _ambientMessage == null
                ? const SizedBox.shrink()
                : Container(
                    key: ValueKey<String>(_ambientMessage!),
                    margin: const EdgeInsets.only(bottom: OasisSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                      horizontal: OasisSpacing.sm,
                      vertical: OasisSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: colors.semantic.primary.withValues(alpha: 0.18),
                    ),
                    child: Text(_ambientMessage!),
                  ),
          ),
          GridView.builder(
            itemCount: shelters.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: OasisSpacing.sm,
              mainAxisSpacing: OasisSpacing.sm,
              childAspectRatio: 0.96,
            ),
            itemBuilder: (context, index) {
              final shelter = shelters[index];
              final selected = selectedAsset == shelter.assetPath;
              final hovered = _hoveredShelterIndex == index;

              return MouseRegion(
                onEnter: (_) => setState(() => _hoveredShelterIndex = index),
                onExit: (_) => setState(() => _hoveredShelterIndex = -1),
                child: GestureDetector(
                  onTap: () => _selectShelter(shelter),
                  child: AnimatedScale(
                    duration: _hoverDuration,
                    curve: MotionSpec.easeOut,
                    scale: hovered ? 1.02 : 1,
                    child: AnimatedContainer(
                      duration: _hoverDuration,
                      curve: MotionSpec.easeOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: hovered || selected
                            ? [
                                BoxShadow(
                                  color: colors.semantic.primary
                                      .withValues(alpha: 0.22),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : const [],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(shelter.assetPath, fit: BoxFit.cover),
                            AnimatedContainer(
                              duration: _selectionFade,
                              color: Colors.black.withValues(
                                alpha: selected ? 0.18 : 0.32,
                              ),
                            ),
                            Positioned(
                              left: 10,
                              right: 10,
                              bottom: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shelter.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    shelter.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.92),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (selected)
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(Icons.check_circle,
                                    color: Colors.white),
                              ),
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
      ),
    );
  }

  Widget _buildDepthSection(BuildContext context, UserSettings settings) {
    final colors = context.appColors;

    return _cardEnvelope(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Profundidad del ambiente',
            subtitle: 'Define cuánto se mezcla el papel con el paisaje que te acompaña.',
          ),
          const SizedBox(height: OasisSpacing.sm),
          OasisSegmentedSelector<CanvasIntensityPreference>(
            value: settings.canvasIntensity,
            segments: const [
              (value: CanvasIntensityPreference.verySubtle, label: 'Suave'),
              (value: CanvasIntensityPreference.subtle, label: 'Media'),
              (value: CanvasIntensityPreference.medium, label: 'Profunda'),
            ],
            onChanged: (value) => ref
                .read(settingsControllerProvider.notifier)
                .setCanvasIntensity(value),
          ),
          const SizedBox(height: OasisSpacing.sm),
          AnimatedSwitcher(
            duration: _selectionFade,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: _depthPreview(settings.canvasIntensity, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildMotionSection(BuildContext context, UserSettings settings) {
    final colors = context.appColors;

    return _cardEnvelope(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Movimiento del entorno',
            subtitle: 'Permite que el paisaje respire a un ritmo sereno.',
          ),
          const SizedBox(height: OasisSpacing.sm),
          OasisSegmentedSelector<CanvasMotionPreference>(
            value: settings.canvasMotion,
            segments: const [
              (value: CanvasMotionPreference.off, label: 'Sin movimiento'),
              (value: CanvasMotionPreference.reduced, label: 'Suave'),
              (value: CanvasMotionPreference.enabled, label: 'Natural'),
            ],
            onChanged: (value) => ref
                .read(settingsControllerProvider.notifier)
                .setCanvasMotion(value),
          ),
          const SizedBox(height: OasisSpacing.sm),
          _motionPreview(settings.canvasMotion, colors),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, UserSettings settings) {
    return _cardEnvelope(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Apariencia',
            subtitle: 'Elige la luz que mejor acompaña tu momento.',
          ),
          const SizedBox(height: OasisSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _themeOption(
                  context,
                  icon: Icons.wb_sunny_outlined,
                  label: 'Modo claro',
                  selected: settings.themeMode == ThemeModePreference.light,
                  onTap: () => ref
                      .read(settingsControllerProvider.notifier)
                      .setThemeMode(ThemeModePreference.light),
                ),
              ),
              const SizedBox(width: OasisSpacing.sm),
              Expanded(
                child: _themeOption(
                  context,
                  icon: Icons.dark_mode_outlined,
                  label: 'Modo oscuro',
                  selected: settings.themeMode == ThemeModePreference.dark,
                  onTap: () => ref
                      .read(settingsControllerProvider.notifier)
                      .setThemeMode(ThemeModePreference.dark),
                ),
              ),
              const SizedBox(width: OasisSpacing.sm),
              Expanded(
                child: _themeOption(
                  context,
                  icon: Icons.phone_android_outlined,
                  label: 'Automático',
                  selected: settings.themeMode == ThemeModePreference.system,
                  onTap: () => ref
                      .read(settingsControllerProvider.notifier)
                      .setThemeMode(ThemeModePreference.system),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilitySection(BuildContext context, UserSettings settings) {
    return _cardEnvelope(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Accesibilidad',
            subtitle: 'Ajustes para que la experiencia se sienta cómoda y amable.',
          ),
          const SizedBox(height: OasisSpacing.sm),
          Text('Texto', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: OasisSpacing.xs),
          OasisSegmentedSelector<String>(
            value: _veryLargeText
                ? 'Muy grande'
                : _largeText
                    ? 'Grande'
                    : 'Normal',
            segments: const [
              (value: 'Normal', label: 'Normal'),
              (value: 'Grande', label: 'Grande'),
              (value: 'Muy grande', label: 'Muy grande'),
            ],
            onChanged: (value) {
              setState(() {
                _largeText = value == 'Grande';
                _veryLargeText = value == 'Muy grande';
              });
            },
          ),
          const SizedBox(height: OasisSpacing.sm),
          SwitchListTile.adaptive(
            value: _reduceMotion,
            onChanged: (value) => setState(() => _reduceMotion = value),
            title: const Text('Reducir movimiento'),
            subtitle: Text(_reduceMotion ? 'Activar' : 'Desactivar'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile.adaptive(
            value: _highContrastDraft || settings.highContrast,
            onChanged: (value) => setState(() => _highContrastDraft = value),
            title: const Text('Mayor contraste'),
            subtitle: Text(
              (_highContrastDraft || settings.highContrast)
                  ? 'Activar'
                  : 'Desactivar',
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersSection(BuildContext context) {
    return _cardEnvelope(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Recordatorios',
            subtitle: 'Elige qué apoyos quieres recibir en tu rutina diaria.',
          ),
          const SizedBox(height: OasisSpacing.sm),
          ..._reminders.entries.map(
            (entry) => SwitchListTile.adaptive(
              value: entry.value,
              onChanged: (value) =>
                  setState(() => _reminders[entry.key] = value),
              title: Text(entry.key),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsSection(BuildContext context) {
    final typography = context.appTypography;
    final colors = context.appColors;
    final medicationsState = ref.watch(medicationsControllerProvider);

    return _cardEnvelope(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: OasisSectionHeader(
                  title: 'Medicamentos',
                  subtitle:
                      'Wellbeing usa esta información para cuidarte con continuidad.',
                ),
              ),
              FilledButton.tonal(
                onPressed: () => _openMedicationDialog(context),
                child: const Text('Agregar medicamento'),
              ),
            ],
          ),
          const SizedBox(height: OasisSpacing.sm),
          medicationsState.when(
            data: (medications) {
              if (medications.isEmpty) {
                return Text(
                  'Tu cuidado empieza en pequeño.\nAquí puedes organizarlo con calma.',
                  style: typography.body
                      .copyWith(color: colors.semantic.textSecondary),
                );
              }
              return Column(
                children: medications.map((medication) {
                  final schedule = medication.schedule.join(' · ');
                  final color =
                      _medicationColors[medication.id] ?? const Color(0xFF8BC4D6);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: OasisSpacing.sm),
                    child: AnimatedContainer(
                      duration: _hoverDuration,
                      curve: MotionSpec.easeOut,
                      child: OasisGlassCard(
                        padding: const EdgeInsets.all(OasisSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 14,
                              height: 64,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(width: OasisSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(medication.name, style: typography.title),
                                  const SizedBox(height: OasisSpacing.xs),
                                  Text('Dosis: ${medication.dosage}'),
                                  const SizedBox(height: OasisSpacing.xs),
                                  Text(
                                    'Horario: $schedule',
                                    style: typography.label.copyWith(
                                      color: colors.semantic.textSecondary,
                                    ),
                                  ),
                                  if ((medication.instructions ?? '')
                                      .trim()
                                      .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: OasisSpacing.xs),
                                      child: Text(
                                        'Observaciones: ${medication.instructions!.trim()}',
                                        style: typography.label.copyWith(
                                          color: colors.semantic.textSecondary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Editar',
                              onPressed: () => _openMedicationDialog(
                                context,
                                medication: medication,
                                initialColor: color,
                              ),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Eliminar',
                              onPressed: () => ref
                                  .read(medicationsControllerProvider.notifier)
                                  .deleteMedication(medication.id),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: OasisSpacing.md),
              child: Center(
                child: LoadingIndicator(type: LoadingType.breathingPaper),
              ),
            ),
            error: (error, _) => Text(error.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final typography = context.appTypography;
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OasisSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Image.asset(
              'assets/logos/oasis_logo.png',
              height: 46,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: OasisSpacing.md),
            Text('OASIS', style: typography.title),
            const SizedBox(height: OasisSpacing.xs),
            Text(
              'Versión Alpha',
              style:
                  typography.label.copyWith(color: colors.semantic.textSecondary),
            ),
            const SizedBox(height: OasisSpacing.xs),
            Text(
              'Built with care.',
              style: typography.body.copyWith(color: colors.semantic.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardEnvelope(BuildContext context, {required Widget child}) {
    final colors = context.appColors;

    return OasisGlassCard(
      padding: const EdgeInsets.all(OasisSpacing.lg),
      child: AnimatedContainer(
        duration: _selectionFade,
        curve: MotionSpec.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: colors.semantic.surface.withValues(alpha: 0.48),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(OasisSpacing.md),
        child: child,
      ),
    );
  }

  Widget _themeOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: _selectionFade,
        curve: MotionSpec.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: OasisSpacing.sm,
          vertical: OasisSpacing.md,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? colors.semantic.primary.withValues(alpha: 0.2)
              : colors.semantic.surface.withValues(alpha: 0.42),
        ),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: OasisSpacing.xs),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _depthPreview(CanvasIntensityPreference intensity, dynamic colors) {
    final config = switch (intensity) {
      CanvasIntensityPreference.verySubtle => (0.22, 4.0, 8.0, 0.26),
      CanvasIntensityPreference.subtle => (0.34, 8.0, 12.0, 0.34),
      CanvasIntensityPreference.medium => (0.46, 12.0, 18.0, 0.44),
    };

    return AnimatedContainer(
      key: ValueKey<CanvasIntensityPreference>(intensity),
      duration: _transitionDuration,
      curve: MotionSpec.easeInOut,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: colors.semantic.surface.withValues(alpha: config.$1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: config.$4),
            blurRadius: config.$3,
            spreadRadius: 0.3,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/backgrounds/papel.webp', fit: BoxFit.cover),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: config.$2, sigmaY: config.$2),
              child: Container(color: Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _motionPreview(CanvasMotionPreference motion, dynamic colors) {
    final speed = switch (motion) {
      CanvasMotionPreference.off => 1.0,
      CanvasMotionPreference.reduced => 1.04,
      CanvasMotionPreference.enabled => 1.08,
    };

    final label = switch (motion) {
      CanvasMotionPreference.off => 'Sin movimiento',
      CanvasMotionPreference.reduced => 'Suave',
      CanvasMotionPreference.enabled => 'Natural',
    };

    return TweenAnimationBuilder<double>(
      key: ValueKey<CanvasMotionPreference>(motion),
      tween: Tween<double>(begin: 1, end: speed),
      duration: _transitionDuration,
      curve: MotionSpec.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: colors.semantic.primary.withValues(alpha: 0.16),
            ),
            alignment: Alignment.center,
            child: AnimatedOpacity(
              duration: _selectionFade,
              opacity: 1,
              child: Text('Preview: $label'),
            ),
          ),
        );
      },
    );
  }

  List<_ShelterCardData> _shelterCards() {
    return const [
      _ShelterCardData(
        style: CanvasStylePreference.forest,
        name: 'Bosque',
        title: '🌲 Bosque',
        description: 'Calma y naturaleza.',
        assetPath: 'assets/backgrounds/bosque.webp',
      ),
      _ShelterCardData(
        style: CanvasStylePreference.mist,
        name: 'Bruma',
        title: '🌫 Bruma',
        description: 'Silencio y concentración.',
        assetPath: 'assets/backgrounds/bruma.webp',
      ),
      _ShelterCardData(
        style: CanvasStylePreference.coast,
        name: 'Costa',
        title: '🌊 Costa',
        description: 'Luz fresca y amplitud.',
        assetPath: 'assets/backgrounds/costa.webp',
      ),
      _ShelterCardData(
        style: CanvasStylePreference.linen,
        name: 'Lino',
        title: '🧵 Lino',
        description: 'Calidez sobria para enfocarte.',
        assetPath: 'assets/backgrounds/lino.webp',
      ),
      _ShelterCardData(
        style: CanvasStylePreference.forest,
        name: 'Papel',
        title: '📜 Papel',
        description: 'Textura limpia y serena.',
        assetPath: 'assets/backgrounds/papel.webp',
      ),
      _ShelterCardData(
        style: CanvasStylePreference.coast,
        name: 'Amanecer',
        title: '🌅 Amanecer',
        description: 'Comenzar de nuevo.',
        assetPath: 'assets/backgrounds/amanecer.webp',
      ),
      _ShelterCardData(
        style: CanvasStylePreference.sereneNight,
        name: 'Noche Serena',
        title: '🌙 Noche Serena',
        description: 'Descanso y tranquilidad.',
        assetPath: 'assets/backgrounds/noche serena.webp',
      ),
    ];
  }

  Future<void> _selectShelter(_ShelterCardData shelter) async {
    await ref.read(settingsControllerProvider.notifier).setCanvasStyle(shelter.style);
    if (!mounted) return;

    setState(() {
      _selectedShelterAsset = shelter.assetPath;
      _ambientMessage = 'Ahora OASIS respira como ${shelter.name}.';
    });

    _ambientMessageTimer?.cancel();
    _ambientMessageTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _ambientMessage = null);
    });
  }

  Future<void> _loadRitualSettings() async {
    final raw = await LocalJsonStore.readMap('rituals_state');
    final snapshot = ritualSettingsFromMap(raw);
    if (!mounted) return;

    setState(() {
      _ritualsLoaded = true;
      _rituals = snapshot.rituals;
      _quietHours = snapshot.quietHours;
      _medicationCriticalInQuietHours =
          snapshot.medicationCriticalInQuietHours;
    });
  }

  Future<void> _persistAndSyncRitualSettings() async {
    await LocalJsonStore.writeMap('rituals_state', {
      'rituals': _rituals
          .map((ritual) => {
                'id': ritual.id,
                'enabled': ritual.enabled,
                'hour': ritual.hour,
                'minute': ritual.minute,
              })
          .toList(growable: false),
      'quietHours': {
        'enabled': _quietHours.enabled,
        'startHour': _quietHours.startHour,
        'startMinute': _quietHours.startMinute,
        'endHour': _quietHours.endHour,
        'endMinute': _quietHours.endMinute,
      },
      'medicationCriticalInQuietHours': _medicationCriticalInQuietHours,
    });

    final scheduler = ref.read(ritualSchedulerProvider);
    await scheduler.syncRituals(
      rituals: _rituals,
      quietHours: _quietHours,
    );
  }

  Widget _buildRitualsAndRemindersSection(
    BuildContext context,
    UserSettings settings,
  ) {
    return _cardEnvelope(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Rituales y Recordatorios',
            subtitle:
                'Activa invitaciones suaves, ajusta horarios y horas de calma.',
          ),
          const SizedBox(height: OasisSpacing.sm),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Notificaciones del sistema'),
            subtitle: Text(
              settings.notificationsEnabled
                  ? 'Las notificaciones están activas y se sincronizan con tus rituales.'
                  : 'No se enviarán notificaciones del sistema.',
            ),
            value: settings.notificationsEnabled,
            onChanged: (value) async {
              await ref
                  .read(settingsControllerProvider.notifier)
                  .saveSettings(settings.copyWith(notificationsEnabled: value));

              final scheduler = ref.read(ritualSchedulerProvider);
              if (!value) {
                await scheduler.clearAll();
                return;
              }

              await scheduler.syncRituals(
                rituals: _rituals,
                quietHours: _quietHours,
              );
            },
          ),
          const SizedBox(height: OasisSpacing.xs),
          for (final ritual in _rituals) ...[
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(ritual.title),
              subtitle: Text(
                '${_formatTime(ritual.hour, ritual.minute)} · ${ritual.description}',
              ),
              value: ritual.enabled,
              onChanged: (value) async {
                setState(() {
                  final idx = _rituals.indexWhere((item) => item.id == ritual.id);
                  if (idx >= 0) {
                    _rituals[idx] = _rituals[idx].copyWith(enabled: value);
                  }
                });
                await _persistAndSyncRitualSettings();
              },
            ),
          ],
          const SizedBox(height: OasisSpacing.xs),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Horas de calma'),
            subtitle: Text(
              '${_formatTime(_quietHours.startHour, _quietHours.startMinute)} - ${_formatTime(_quietHours.endHour, _quietHours.endMinute)}',
            ),
            value: _quietHours.enabled,
            onChanged: (value) async {
              setState(() {
                _quietHours = _quietHours.copyWith(enabled: value);
              });
              await _persistAndSyncRitualSettings();
            },
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Medicación crítica en horas de calma'),
            subtitle: const Text(
              'Permitir medicación aunque el modo calma esté activo.',
            ),
            value: _medicationCriticalInQuietHours,
            onChanged: (value) async {
              setState(() {
                _medicationCriticalInQuietHours = value;
              });
              await _persistAndSyncRitualSettings();
            },
          ),
          const SizedBox(height: OasisSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => context.push(RouteConstants.rituals),
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Abrir ajustes avanzados de Rituales'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _openNameDialog(BuildContext context, UserSettings settings) async {
    final controller = TextEditingController(text: settings.preferredName);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AppDialog(
              title: 'Editar nombre',
              actions: [
                TextButton(
                  onPressed: _savingName
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: _savingName
                      ? null
                      : () async {
                          if (!mounted) return;
                          setState(() => _savingName = true);
                          setDialogState(() {});

                          try {
                            await ref
                                .read(settingsControllerProvider.notifier)
                                .setPreferredName(controller.text);

                            if (!mounted) return;
                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                          } finally {
                            if (mounted) {
                              setState(() => _savingName = false);
                              if (dialogContext.mounted) {
                                setDialogState(() {});
                              }
                            }
                          }
                        },
                  child: Text(_savingName ? 'Guardando...' : 'Guardar'),
                ),
              ],
              child: AppTextField(
                controller: controller,
                hint: 'Escribe cómo prefieres que OASIS te acompañe',
              ),
            );
          },
        );
      },
    );
    controller.dispose();
  }

  Future<void> _openMedicationDialog(
    BuildContext context, {
    Medication? medication,
    Color? initialColor,
  }) async {
    final nameController = TextEditingController(text: medication?.name ?? '');
    final doseController = TextEditingController(
      text: medication != null ? medication.dosage.amount.toString() : '',
    );
    final scheduleController = TextEditingController(
      text: medication?.schedule.join(', ') ?? '',
    );
    final instructionsController = TextEditingController(
      text: medication?.instructions ?? '',
    );

    var selectedUnit = medication?.dosage.unit ?? DosageUnit.milligram;
    var selectedColor = initialColor ?? const Color(0xFF8BC4D6);
    final colorOptions = <Color>[
      const Color(0xFF8BC4D6),
      const Color(0xFF98D8AA),
      const Color(0xFFF6C28B),
      const Color(0xFFB9A4F2),
      const Color(0xFFE79AA8),
    ];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AppDialog(
              title: medication == null
                  ? 'Agregar medicamento'
                  : 'Editar medicamento',
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: _savingMedication
                      ? null
                      : () async {
                          if (!mounted) return;
                          setState(() => _savingMedication = true);
                          setDialogState(() {});

                          try {
                            final name = nameController.text.trim();
                            final parsedDose =
                                double.tryParse(doseController.text.trim());
                            final schedule =
                                _parseSchedule(scheduleController.text);
                            if (name.isEmpty ||
                                parsedDose == null ||
                                parsedDose <= 0) {
                              return;
                            }
                            if (schedule.isEmpty) {
                              return;
                            }

                            final dosage =
                                Dosage(amount: parsedDose, unit: selectedUnit);
                            final instructions = instructionsController.text.trim();

                            if (medication == null) {
                              await ref
                                  .read(medicationsControllerProvider.notifier)
                                  .createMedication(
                                    name: name,
                                    dosage: dosage,
                                    schedule: schedule,
                                    instructions: instructions.isEmpty
                                        ? null
                                        : instructions,
                                  );
                            } else {
                              await ref
                                  .read(medicationsControllerProvider.notifier)
                                  .updateMedication(
                                    medication.copyWith(
                                      name: name,
                                      dosage: dosage,
                                      schedule: schedule,
                                      instructions: instructions.isEmpty
                                          ? null
                                          : instructions,
                                    ),
                                  );
                            }

                            if (!mounted) return;

                            final refreshed =
                                ref.read(medicationsControllerProvider).value;
                            if (medication == null &&
                                refreshed != null &&
                                refreshed.isNotEmpty) {
                              final latest = refreshed.last;
                              setState(() =>
                                  _medicationColors[latest.id] = selectedColor);
                            }
                            if (medication != null) {
                              setState(() => _medicationColors[medication.id] =
                                  selectedColor);
                            }

                            if (!dialogContext.mounted) return;
                            Navigator.of(dialogContext).pop();
                          } finally {
                            if (mounted) {
                              setState(() => _savingMedication = false);
                              if (dialogContext.mounted) {
                                setDialogState(() {});
                              }
                            }
                          }
                        },
                  child: Text(_savingMedication ? 'Guardando...' : 'Guardar'),
                ),
              ],
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      controller: nameController,
                      label: 'Nombre',
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: doseController,
                      label: 'Dosis',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<DosageUnit>(
                      initialValue: selectedUnit,
                      items: DosageUnit.values
                          .map(
                            (unit) => DropdownMenuItem<DosageUnit>(
                              value: unit,
                              child: Text(unit.symbol),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedUnit = value);
                      },
                      decoration: const InputDecoration(labelText: 'Unidad'),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: scheduleController,
                      label: 'Horario',
                      hint: '08:00, 20:00',
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Color',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: colorOptions
                          .map(
                            (color) => GestureDetector(
                              onTap: () =>
                                  setDialogState(() => selectedColor = color),
                              child: AnimatedContainer(
                                duration: _selectionFade,
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedColor == color
                                        ? Colors.black87
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: instructionsController,
                      label: 'Observaciones',
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    doseController.dispose();
    scheduleController.dispose();
    instructionsController.dispose();
  }

  String _defaultShelterAssetFor(UserSettings settings) {
    return switch (settings.canvasStyle) {
      CanvasStylePreference.forest => 'assets/backgrounds/bosque.webp',
      CanvasStylePreference.mist => 'assets/backgrounds/bruma.webp',
      CanvasStylePreference.coast => 'assets/backgrounds/costa.webp',
      CanvasStylePreference.linen => 'assets/backgrounds/lino.webp',
      CanvasStylePreference.sereneNight => 'assets/backgrounds/noche serena.webp',
    };
  }

  List<String> _parseSchedule(String raw) {
    return raw
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }
}

class _ShelterCardData {
  final CanvasStylePreference style;
  final String name;
  final String title;
  final String description;
  final String assetPath;

  const _ShelterCardData({
    required this.style,
    required this.name,
    required this.title,
    required this.description,
    required this.assetPath,
  });
}

enum _PrivacyAuthMode { pin, biometric, both }
