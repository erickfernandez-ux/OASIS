import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/local_json_store.dart';
import '../../../../core/design/design_system.dart';
import '../../application/providers/ritual_providers.dart';
import '../../domain/defaults/ritual_defaults.dart';
import '../../domain/entities/quiet_hours.dart';
import '../../domain/entities/ritual.dart';
import '../../domain/enums/ritual_type.dart';

class RitualsScreen extends ConsumerStatefulWidget {
  const RitualsScreen({super.key});

  @override
  ConsumerState<RitualsScreen> createState() => _RitualsScreenState();
}

class _RitualsScreenState extends ConsumerState<RitualsScreen> {
  static const _storageKey = 'rituals_state';
  late final List<Ritual> _rituals;
  late QuietHours _quietHours;
  bool _medicationCriticalInQuietHours = defaultMedicationCriticalInQuietHours;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _rituals = defaultRituals();
    _quietHours = defaultQuietHours;
    _loadPersistedState();
  }

  @override
  Widget build(BuildContext context) {
    return OasisScreenShell(
      title: 'Mis Rituales',
      subtitle: 'Pequenos recordatorios para sostener tu ritmo con calma.',
      accent: OasisSurfaces.settingsAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OasisSectionHeader(
            title: 'Rituales diarios',
            subtitle: 'Activalos y ajusta su hora segun tu dia.',
          ),
          const SizedBox(height: OasisSpacing.sm),
          for (final ritual in _rituals) ...[
            _RitualTile(
              ritual: ritual,
              onToggle: (value) {
                setState(() {
                  final index = _rituals.indexWhere((item) => item.id == ritual.id);
                  if (index >= 0) {
                    _rituals[index] = _rituals[index].copyWith(enabled: value);
                  }
                });
                _persistState();
              },
              onPickTime: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: ritual.hour, minute: ritual.minute),
                );
                if (picked == null) return;
                setState(() {
                  final index = _rituals.indexWhere((item) => item.id == ritual.id);
                  if (index >= 0) {
                    _rituals[index] = _rituals[index].copyWith(
                      hour: picked.hour,
                      minute: picked.minute,
                    );
                  }
                });
                await _persistState();
              },
            ),
            const SizedBox(height: OasisSpacing.sm),
          ],
          const SizedBox(height: OasisSpacing.md),
          OasisCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🌙', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: OasisSpacing.sm),
                    Expanded(
                      child: Text(
                        'Horas de calma',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Material(
                      type: MaterialType.transparency,
                      child: Switch(
                        value: _quietHours.enabled,
                        onChanged: (value) {
                          setState(() {
                            _quietHours = _quietHours.copyWith(enabled: value);
                          });
                          _persistState();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OasisSpacing.xs),
                Text(
                  'Evita interrupciones durante tu ventana de descanso.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: OasisSpacing.xs),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _medicationCriticalInQuietHours,
                  onChanged: (value) {
                    setState(() {
                      _medicationCriticalInQuietHours = value;
                    });
                    _persistState();
                  },
                  title: const Text('Medicación crítica durante calma'),
                  subtitle: const Text(
                    'Permitir solo medicación en la ventana de calma.',
                  ),
                ),
                const SizedBox(height: OasisSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickQuietHour(isStart: true),
                        child: Text('Inicio ${_formatTime(_quietHours.startHour, _quietHours.startMinute)}'),
                      ),
                    ),
                    const SizedBox(width: OasisSpacing.sm),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pickQuietHour(isStart: false),
                        child: Text('Fin ${_formatTime(_quietHours.endHour, _quietHours.endMinute)}'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: OasisSpacing.xxxl),
        ],
      ),
    );
  }

  Future<void> _pickQuietHour({required bool isStart}) async {
    final initial = isStart
        ? TimeOfDay(hour: _quietHours.startHour, minute: _quietHours.startMinute)
        : TimeOfDay(hour: _quietHours.endHour, minute: _quietHours.endMinute);

    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _quietHours = _quietHours.copyWith(
          startHour: picked.hour,
          startMinute: picked.minute,
        );
      } else {
        _quietHours = _quietHours.copyWith(
          endHour: picked.hour,
          endMinute: picked.minute,
        );
      }
    });
    await _persistState();
  }

  Future<void> _loadPersistedState() async {
    if (_loaded) return;
    final data = await LocalJsonStore.readMap(_storageKey);
    if (!mounted || data == null) {
      _loaded = true;
      return;
    }

    final ritualsRaw = (data['rituals'] as List?) ?? const <dynamic>[];
    final ritualsById = {
      for (final item in ritualsRaw.whereType<Map>())
        (item['id'] as String?): item.cast<String, dynamic>(),
    };

    setState(() {
      for (var i = 0; i < _rituals.length; i++) {
        final raw = ritualsById[_rituals[i].id];
        if (raw == null) continue;
        _rituals[i] = _rituals[i].copyWith(
          enabled: (raw['enabled'] as bool?) ?? _rituals[i].enabled,
          hour: (raw['hour'] as int?) ?? _rituals[i].hour,
          minute: (raw['minute'] as int?) ?? _rituals[i].minute,
        );
      }

      final quietRaw = data['quietHours'];
      if (quietRaw is Map) {
        final quietJson = quietRaw.cast<String, dynamic>();
        _quietHours = _quietHours.copyWith(
          enabled: (quietJson['enabled'] as bool?) ?? _quietHours.enabled,
          startHour: (quietJson['startHour'] as int?) ?? _quietHours.startHour,
          startMinute:
              (quietJson['startMinute'] as int?) ?? _quietHours.startMinute,
          endHour: (quietJson['endHour'] as int?) ?? _quietHours.endHour,
          endMinute: (quietJson['endMinute'] as int?) ?? _quietHours.endMinute,
        );
      }

      _medicationCriticalInQuietHours =
          (data['medicationCriticalInQuietHours'] as bool?) ??
              _medicationCriticalInQuietHours;
    });

    _loaded = true;
  }

  Future<void> _persistState() async {
    await LocalJsonStore.writeMap(_storageKey, {
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

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _RitualTile extends StatelessWidget {
  const _RitualTile({
    required this.ritual,
    required this.onToggle,
    required this.onPickTime,
  });

  final Ritual ritual;
  final ValueChanged<bool> onToggle;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    return OasisCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_emojiFor(ritual.type), style: const TextStyle(fontSize: 20)),
          const SizedBox(width: OasisSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ritual.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: OasisSpacing.xs),
                Text(
                  ritual.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: OasisSpacing.sm),
                TextButton.icon(
                  onPressed: onPickTime,
                  icon: const Icon(Icons.schedule_rounded),
                  label: Text(_formatTime(ritual.hour, ritual.minute)),
                ),
              ],
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: Switch(
              value: ritual.enabled,
              onChanged: onToggle,
            ),
          ),
        ],
      ),
    );
  }

  String _emojiFor(RitualType type) {
    return switch (type) {
      RitualType.morning => '🌅',
      RitualType.night => '🌙',
      RitualType.journal => '📖',
      RitualType.medication => '💊',
      RitualType.hydration => '💧',
      RitualType.movement => '🚶',
      RitualType.agenda => '🗓️',
    };
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
