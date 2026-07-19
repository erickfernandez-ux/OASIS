import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/icons/app_icons.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/spacing/app_spacing.dart';
import '../../../../core/theme/typography/app_typography.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/design/design_system.dart';
import '../../../../features/settings/domain/entities/user_settings.dart';
import '../../../../features/settings/presentation/providers/settings_controller.dart';
import '../../../../shared/providers/app_launch_intents.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../controllers/home_controller.dart';

/// Home dashboard MVP backed by Riverpod and mock repositories.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = context.appSpacing;
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final settings = ref.watch(settingsControllerProvider).valueOrNull;

    return OasisWatercolorBackground(
      accent: OasisSurfaces.homeAccent,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: spacing.lg, vertical: spacing.md),
          child: dashboardAsync.when(
            data: (data) => _buildContent(
              context,
              ref,
              data,
              settings,
            ),
            loading: () => _buildLoading(context),
            error: (error, _) => _buildError(context, error),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    HomeDashboardData data,
    UserSettings? settings,
  ) {
    final spacing = context.appSpacing;
    final typography = context.appTypography;
    final colors = context.appColors;

    final quickActions = <_QuickAction>[
      _QuickAction(
        label: 'Nueva nota',
        icon: AppIcons.notes,
        heroTag: OasisHeroTags.notesHeader,
        onPressed: () {
          ref.read(appLaunchIntentProvider.notifier).state =
              AppLaunchIntent.openNotesNewNote;
          context.push(RouteConstants.notes);
        },
      ),
      _QuickAction(
          label: 'Nueva tarea',
          icon: AppIcons.agenda,
        heroTag: null,
          onPressed: () {
            ref.read(appLaunchIntentProvider.notifier).state =
                AppLaunchIntent.openAgendaTasksNewTask;
            context.go(RouteConstants.agenda);
          }),
      _QuickAction(
          label: 'Nueva cita',
          icon: AppIcons.add,
          heroTag: null,
          onPressed: () {
            ref.read(appLaunchIntentProvider.notifier).state =
                AppLaunchIntent.openAgendaCalendarNewEvent;
            context.go(RouteConstants.agenda);
          }),
      _QuickAction(
          label: 'Registrar estado',
          icon: AppIcons.wellbeing,
          heroTag: OasisHeroTags.journalHeader,
          onPressed: () => context.go(RouteConstants.journal)),
    ];

    final resumeRows = <_InfoRowData>[
      if (data.latestNoteLabel != null)
        _InfoRowData(title: 'Última nota', value: data.latestNoteLabel!),
      if (data.latestTaskLabel != null)
        _InfoRowData(title: 'Última tarea', value: data.latestTaskLabel!),
      if (data.latestJournalLabel != null)
        _InfoRowData(title: 'Última entrada', value: data.latestJournalLabel!),
      if (data.pomodoroSessions > 0)
        _InfoRowData(
          title: 'Última sesión',
          value: '${data.pomodoroSessions} sesiones completadas',
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OasisStagger(
          index: 0,
          child: _buildWelcomeHeader(
            context: context,
            spacing: spacing,
            typography: typography,
            colors: colors,
            settings: settings,
          ),
        ),
        SizedBox(height: spacing.lg),
        OasisStagger(
          index: 1,
          child: _HomePaperCard(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, '✨ Captura rápida'),
                SizedBox(height: spacing.sm),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final buttonWidth = constraints.maxWidth >= 840
                        ? 172.0
                        : constraints.maxWidth >= 600
                            ? 158.0
                            : (constraints.maxWidth - spacing.sm) / 2;

                    return Wrap(
                      spacing: spacing.sm,
                      runSpacing: spacing.sm,
                      children: quickActions
                          .map(
                            (action) => SizedBox(
                              width: buttonWidth,
                              child: _QuickToolTile(
                                label: action.label,
                                icon: action.icon,
                                heroTag: action.heroTag,
                                onTap: action.onPressed,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        if (resumeRows.isNotEmpty) ...[
          SizedBox(height: spacing.md),
          OasisStagger(
            index: 2,
            child: _HomePaperCard(
              padding: EdgeInsets.all(spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Continúa donde quedaste'),
                  SizedBox(height: spacing.sm),
                  ...resumeRows
                      .map((item) => Padding(
                            padding: EdgeInsets.only(bottom: spacing.xs),
                            child: _buildInfoRow(
                              context,
                              title: item.title,
                              value: item.value,
                              icon: AppIcons.info,
                            ),
                          )),
                ],
              ),
            ),
          ),
        ],
        if (data.priorityTask != null) ...[
          SizedBox(height: spacing.md),
          OasisStagger(
            index: 3,
            child: _HomePaperCard(
              level: 3,
              padding: EdgeInsets.all(spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Prioridad del día'),
                  SizedBox(height: spacing.sm),
                  _buildInfoRow(
                    context,
                    title: data.priorityTask!.title,
                    value: [
                      if (data.priorityTask!.timeLabel != null)
                        data.priorityTask!.timeLabel!,
                      data.priorityTask!.priorityLabel,
                    ].join(' • '),
                    icon: AppIcons.agenda,
                  ),
                ],
              ),
            ),
          ),
        ],
        SizedBox(height: spacing.md),
        OasisStagger(
          index: 4,
          child: _HomePaperCard(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'Medicación'),
                SizedBox(height: spacing.sm),
                if (data.nextMedicationName != null)
                  _buildInfoRow(
                    context,
                    title: data.nextMedicationName!,
                    value: [
                      if (data.nextMedicationDoseLabel != null)
                        data.nextMedicationDoseLabel!,
                      if (data.nextMedicationTimeLabel != null)
                        data.nextMedicationTimeLabel!,
                      if (data.nextMedicationStatusLabel != null)
                        data.nextMedicationStatusLabel!,
                    ].join(' • '),
                    icon: AppIcons.wellbeing,
                  )
                else
                  Text(
                    'Sin medicación activa',
                    style: typography.body
                        .copyWith(color: colors.semantic.textSecondary),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing.md),
        OasisStagger(
          index: 5,
          child: _HomePaperCard(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'Agenda del día'),
                SizedBox(height: spacing.sm),
                if (data.todayEvents.isNotEmpty)
                  ...data.todayEvents
                      .map((event) => Padding(
                            padding: EdgeInsets.only(bottom: spacing.xs),
                            child: _buildInfoRow(
                              context,
                              title: event.title,
                              value: event.timeLabel,
                              icon: AppIcons.add,
                            ),
                          ))
                else
                  Text(
                    'Sin eventos para hoy',
                    style: typography.body
                        .copyWith(color: colors.semantic.textSecondary),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing.md),
        OasisStagger(
          index: 6,
          child: _HomePaperCard(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'Hidratación'),
                SizedBox(height: spacing.sm),
                _buildInfoRow(
                  context,
                  title: '${data.waterConsumedMl} ml hoy',
                  value: 'Registro real de consumo',
                  icon: AppIcons.info,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing.md),
        OasisStagger(
          index: 7,
          child: _HomePaperCard(
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'Estado emocional'),
                SizedBox(height: spacing.sm),
                _buildInfoRow(
                  context,
                  title: data.moodLabel,
                  value: data.energyLabel != null
                      ? 'Energía ${data.energyLabel}'
                      : 'Último registro emocional',
                  icon: AppIcons.wellbeing,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader({
    required BuildContext context,
    required AppSpacing spacing,
    required AppTypography typography,
    required AppColors colors,
    required UserSettings? settings,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(spacing.md, spacing.md, spacing.md, spacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.semantic.surface.withValues(alpha: 0.22),
            colors.semantic.surface.withValues(alpha: 0.04),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🌿 Buenos días, Erick',
                      style: typography.displayLarge
                          .copyWith(color: colors.semantic.textPrimary),
                    ),
                    SizedBox(height: spacing.xs / 2),
                    Text(
                      'Hoy parece un buen día para ir con calma.',
                      style: typography.body
                          .copyWith(color: colors.semantic.textSecondary),
                    ),
                  ],
                ),
              ),
              _LiftOnTouch(
                onTap: () => _showPrivacyInfo(context, settings),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.semantic.surface.withValues(alpha: 0.38),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colors.semantic.primary.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: colors.semantic.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPrivacyInfo(BuildContext context, UserSettings? settings) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final spacing = context.appSpacing;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(spacing.md),
          child: _HomePaperCard(
            level: 3,
            padding: EdgeInsets.all(spacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacidad',
                  style: typography.title
                      .copyWith(color: colors.semantic.textPrimary),
                ),
                SizedBox(height: spacing.sm),
                _buildPrivacyLine(
                  context,
                  label: 'Bloqueo de app',
                  value: (settings?.privacyLockEnabled ?? false)
                      ? 'Activo'
                      : 'Inactivo',
                ),
                _buildPrivacyLine(
                  context,
                  label: 'PIN',
                  value: (settings?.privacyUsePin ?? false)
                      ? 'Activo'
                      : 'Inactivo',
                ),
                _buildPrivacyLine(
                  context,
                  label: 'Biometría',
                  value: (settings?.privacyUseBiometric ?? false)
                      ? 'Activa'
                      : 'Inactiva',
                ),
                _buildPrivacyLine(
                  context,
                  label: 'Ocultar en recientes',
                  value: (settings?.privacyHideInRecents ?? false)
                      ? 'Activo'
                      : 'Inactivo',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrivacyLine(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final typography = context.appTypography;
    final colors = context.appColors;
    final spacing = context.appSpacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: typography.body.copyWith(
                color: colors.semantic.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: typography.label.copyWith(
              color: colors.semantic.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    final spacing = context.appSpacing;
    final typography = context.appTypography;
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🌿 Buenos días, Erick',
          style: typography.displayLarge
              .copyWith(color: colors.semantic.textPrimary),
        ),
        SizedBox(height: spacing.sm),
        Text(
          'Cargando tu resumen del día...',
          style: typography.body.copyWith(color: colors.semantic.textSecondary),
        ),
        SizedBox(height: spacing.lg),
        OasisCard(
          padding: EdgeInsets.all(spacing.lg),
          child: const Center(
            child: LoadingIndicator(type: LoadingType.breathingPaper),
          ),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    final spacing = context.appSpacing;
    final typography = context.appTypography;
    final colors = context.appColors;

    return OasisCard(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No pudimos cargar el resumen',
            style:
                typography.title.copyWith(color: colors.semantic.textPrimary),
          ),
          SizedBox(height: spacing.sm),
          Text(
            error.toString(),
            style:
                typography.body.copyWith(color: colors.semantic.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final typography = context.appTypography;
    final colors = context.appColors;
    return Text(
      title,
      style: typography.title.copyWith(color: colors.semantic.textPrimary),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final spacing = context.appSpacing;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: colors.semantic.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon,
              size: AppIconSize.sm.value + 2, color: colors.semantic.primary),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: typography.label
                      .copyWith(color: colors.semantic.textPrimary)),
              SizedBox(height: spacing.xs / 2),
              Text(value,
                  style: typography.body
                      .copyWith(color: colors.semantic.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

}

class _QuickAction {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final String? heroTag;

  const _QuickAction(
      {required this.label,
      required this.icon,
      required this.onPressed,
      this.heroTag});
}

class _InfoRowData {
  final String title;
  final String value;

  const _InfoRowData({required this.title, required this.value});
}

class _QuickToolTile extends StatelessWidget {
  const _QuickToolTile({
    required this.label,
    required this.icon,
    required this.onTap,
    this.heroTag,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final spacing = context.appSpacing;

    final tile = _LiftOnTouch(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: EdgeInsets.symmetric(horizontal: spacing.sm),
        decoration: BoxDecoration(
          color: colors.semantic.surface.withValues(alpha: 0.34),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: colors.semantic.primary.withValues(alpha: 0.10),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: AppIconSize.lg.value + 1, color: colors.semantic.primary),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.body.copyWith(
                  color: colors.semantic.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (heroTag == null) {
      return tile;
    }

    return Hero(
      tag: heroTag!,
      child: Material(
        type: MaterialType.transparency,
        child: tile,
      ),
    );
  }
}

class _HomePaperCard extends StatelessWidget {
  const _HomePaperCard({
    required this.child,
    required this.padding,
    this.level = 2,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final int level;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final blur = switch (level) {
      1 => 16.0,
      2 => 22.0,
      3 => 26.0,
      _ => 30.0,
    };

    final shadowAlpha = switch (level) {
      1 => 0.08,
      2 => 0.10,
      3 => 0.12,
      _ => 0.14,
    };

    final panel = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2E2826)
                    : const Color(0xFFFFF9F0))
                .withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.42),
              width: 0.9,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7EA08B).withValues(alpha: shadowAlpha),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.85, -0.95),
                        radius: 1.2,
                        colors: [
                          colors.semantic.primary.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );

    return panel;
  }
}

class _LiftOnTouch extends StatefulWidget {
  const _LiftOnTouch({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_LiftOnTouch> createState() => _LiftOnTouchState();
}

class _LiftOnTouchState extends State<_LiftOnTouch> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: MotionSpec.micro,
        curve: MotionSpec.easeOut,
        transform: Matrix4.identity()
          ..setTranslationRaw(0.0, _pressed ? -2.0 : 0.0, 0.0),
        child: widget.child,
      ),
    );
  }
}
