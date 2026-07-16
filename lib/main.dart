import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/config/app_router.dart';
import 'core/constants/route_constants.dart';
import 'core/design/design_system.dart';
import 'core/di/di.dart';
import 'features/rituals/application/providers/ritual_providers.dart';
import 'features/rituals/domain/defaults/ritual_defaults.dart';
import 'features/wellbeing/presentation/providers/wellbeing_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/local_json_store.dart';
import 'shared/widgets/privacy_gate.dart';
import 'shared/widgets/startup_splash_gate.dart';

/// Entry point of OASIS.
/// Initializes Supabase only when configuration is present and wraps the app
/// in ProviderScope for Riverpod.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hasRealSupabaseConfig =
      !AppConfig.supabaseUrl.contains('placeholder') &&
          !AppConfig.supabaseAnonKey.contains('placeholder');

  if (hasRealSupabaseConfig) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }

  runApp(const ProviderScope(child: OasisApp()));
}

class OasisApp extends ConsumerStatefulWidget {
  const OasisApp({super.key});

  @override
  ConsumerState<OasisApp> createState() => _OasisAppState();
}

class _OasisAppState extends ConsumerState<OasisApp> {
  bool _ritualEngineBootstrapped = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrapRitualEngine();
    });
  }

  Future<void> _bootstrapRitualEngine() async {
    if (_ritualEngineBootstrapped) return;
    _ritualEngineBootstrapped = true;

    final scheduler = ref.read(ritualSchedulerProvider);
    final router = ref.read(appRouterProvider);

    await scheduler.initialize(
      onOpenRoute: (route) async {
        router.go(route);
      },
      onAction: (actionId, payload) async {
        final wellbeing = ref.read(wellbeingControllerProvider.notifier);

        switch (actionId) {
          case 'medication_taken':
            final data = _decodePayload(payload);
            final medicationId = data['medicationId'] as String?;
            if (medicationId != null && medicationId.isNotEmpty) {
              await wellbeing.markMedicationTaken(medicationId);
            }
            break;
          case 'hydration_done':
            await wellbeing.registerWater(250);
            break;
          case 'open_journal':
            router.go(RouteConstants.journal);
            break;
          case 'snooze_15':
            if (payload != null && payload.isNotEmpty) {
              await scheduler.scheduleSnoozeFromPayload(
                payload,
                const Duration(minutes: 15),
              );
            }
            break;
          default:
            final data = _decodePayload(payload);
            final route = (data['route'] as String?) ?? RouteConstants.home;
            router.go(route);
            break;
        }
      },
    );

    final raw = await LocalJsonStore.readMap('rituals_state');
    final snapshot = ritualSettingsFromMap(raw);
    await scheduler.syncRituals(
      rituals: snapshot.rituals,
      quietHours: snapshot.quietHours,
    );
  }

  Map<String, dynamic> _decodePayload(String? payload) {
    if (payload == null || payload.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final canvasTheme = ref.watch(canvasThemeProvider);

    return MaterialApp.router(
      title: 'OASIS',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.lightTheme(canvasTheme: canvasTheme),
      darkTheme: AppTheme.darkTheme(canvasTheme: canvasTheme),
      themeMode: ref.watch(themeModeProvider),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(
            physics:
                const BouncingScrollPhysics(parent: ClampingScrollPhysics()),
          ),
          child: PrivacyGate(
            child: StartupSplashGate(
              child: OrganicFade(child: child ?? const SizedBox.shrink()),
            ),
          ),
        );
      },
    );
  }
}
