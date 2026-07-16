import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/icons/app_icons.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/spacing/app_spacing.dart';
import '../../../../core/theme/typography/app_typography.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/design/design_system.dart';
import '../../../../features/settings/presentation/providers/settings_controller.dart';
import '../../../../shared/providers/app_message_system_provider.dart';
import '../../../../shared/providers/app_launch_intents.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../controllers/home_controller.dart';

/// Home dashboard MVP backed by Riverpod and mock repositories.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final spacing = context.appSpacing;
    final typography = context.appTypography;
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).languageCode;
    final formattedDate = _formatDate(now, locale);
    final dashboardAsync = ref.watch(homeDashboardProvider);
    final privacyProtected = ref.watch(
      settingsControllerProvider.select(
        (state) => state.valueOrNull != null,
      ),
    );
    final preferredName = ref.watch(
      settingsControllerProvider.select(
        (state) => state.valueOrNull?.preferredName.trim() ?? '',
      ),
    );
    final greeting = ref.watch(appMessageSystemProvider).greetingFor(
          now: now,
          preferredName: preferredName,
        );

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
              spacing,
              typography,
              colors,
              formattedDate,
              data,
              greeting,
              privacyProtected,
            ),
            loading: () => _buildLoading(context, spacing, typography, colors),
            error: (error, _) =>
                _buildError(context, spacing, typography, colors, error),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AppSpacing spacing,
    AppTypography typography,
    AppColors colors,
    String formattedDate,
    HomeDashboardData data,
    GreetingMessage greeting,
    bool privacyProtected,
  ) {
    final now = DateTime.now();
    final messageSystem = ref.watch(appMessageSystemProvider);
    final quickActions = <_QuickAction>[
      _QuickAction(
          label: 'Nueva tarea',
          icon: AppIcons.agenda,
          heroTag: OasisHeroTags.agendaHeader,
          onPressed: () {
            ref.read(appLaunchIntentProvider.notifier).state =
                AppLaunchIntent.openAgendaTasksNewTask;
            context.go(RouteConstants.agenda);
          }),
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
          label: 'Nueva cita',
          icon: AppIcons.add,
          heroTag: OasisHeroTags.agendaHeader,
          onPressed: () {
            ref.read(appLaunchIntentProvider.notifier).state =
                AppLaunchIntent.openAgendaCalendarNewEvent;
            context.go(RouteConstants.agenda);
          }),
      _QuickAction(
          label: 'Nuevo registro',
          icon: AppIcons.wellbeing,
          heroTag: OasisHeroTags.journalHeader,
          onPressed: () => context.go(RouteConstants.journal)),
    ];

    final summaryItems = <_SummaryItem>[
      _SummaryItem(
        title: 'Tareas completadas',
        value: '${data.completedTasksCount}',
        subtitle: 'Progreso',
        detail: '${data.pendingTasksCount} pendientes',
      ),
      _SummaryItem(
        title: 'Agua consumida',
        value: '${data.waterConsumedMl} ml',
        subtitle: 'Hidratación',
        detail: 'Objetivo personal activo',
      ),
      _SummaryItem(
        title: 'Estado de ánimo',
        value: data.moodLabel,
        subtitle: 'Último registro',
        detail: 'Escucha tu energía',
      ),
      _SummaryItem(
        title: 'Sesiones Pomodoro',
        value: '${data.pomodoroSessions}',
        subtitle: 'Enfoque',
        detail: 'Ritmo del día',
      ),
    ];

    final todayCardMessage = _TodayCardMessage(
      emoji: data.pendingTasksCount == 0 ? '🍃' : '🌿',
      message: messageSystem.contextualHomePhrase(
        now: now,
        pendingTasksCount: data.pendingTasksCount,
        journalUsedYesterday: data.journalUsedYesterday,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OasisStagger(
          index: 0,
          child: _buildWelcomeHeader(
            spacing: spacing,
            typography: typography,
            colors: colors,
            formattedDate: formattedDate,
            greeting: greeting,
              privacyProtected: privacyProtected,
          ),
        ),
        SizedBox(height: spacing.lg),
        OasisStagger(
          index: 1,
          child: _HomePaperCard(
            padding: EdgeInsets.fromLTRB(
                spacing.md, spacing.md, spacing.md, spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hoy',
                  style: typography.displayLarge
                      .copyWith(color: colors.semantic.textPrimary),
                ),
                SizedBox(height: spacing.sm),
                _buildTodayRow(
                  context,
                  title: 'Tareas pendientes',
                  value: '${data.pendingTasksCount} por completar',
                  icon: AppIcons.agenda,
                ),
                SizedBox(height: spacing.xs),
                _buildTodayRow(
                  context,
                  title: 'Eventos de hoy',
                  value: '${data.todayEventsCount} programados',
                  icon: AppIcons.add,
                ),
                SizedBox(height: spacing.xs),
                _buildTodayRow(
                  context,
                  title: 'Próximo medicamento',
                  value: data.nextMedicationLabel,
                  icon: AppIcons.info,
                ),
                SizedBox(height: spacing.sm),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: spacing.md, vertical: spacing.sm),
                  decoration: BoxDecoration(
                    color: colors.semantic.surface.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colors.semantic.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        todayCardMessage.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      SizedBox(width: spacing.sm),
                      Expanded(
                        child: Text(
                          todayCardMessage.message,
                          style: typography.body
                              .copyWith(color: colors.semantic.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.md),
                OasisStagger(
                  index: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        height: 1,
                        color: colors.semantic.primary.withValues(alpha: 0.10),
                      ),
                      SizedBox(height: spacing.md),
                      Text(
                        'Acciones rápidas',
                        style: typography.title
                            .copyWith(color: colors.semantic.textPrimary),
                      ),
                      SizedBox(height: spacing.xs / 2),
                      Text(
                        'Pequeñas herramientas para sostener tu ritmo.',
                        style: typography.body
                            .copyWith(color: colors.semantic.textSecondary),
                      ),
                      SizedBox(height: spacing.sm),
                      Divider(
                        height: 1,
                        color: colors.semantic.primary.withValues(alpha: 0.10),
                      ),
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
                SizedBox(height: spacing.md),
                OasisStagger(
                  index: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        height: 1,
                        color: colors.semantic.primary.withValues(alpha: 0.10),
                      ),
                      SizedBox(height: spacing.md),
                      Text(
                        'Resumen del día',
                        style: typography.title
                            .copyWith(color: colors.semantic.textPrimary),
                      ),
                      SizedBox(height: spacing.xs / 2),
                      Text(
                        'Pequeñas notas para leer tu día de un vistazo.',
                        style: typography.body
                            .copyWith(color: colors.semantic.textSecondary),
                      ),
                      SizedBox(height: spacing.xs),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return _SummaryBoard(
                            spacing: spacing,
                            children: [
                              _BoardNote(
                                icon: Icons.water_drop_rounded,
                                value: summaryItems[1].value,
                                label: 'Agua',
                                caption: summaryItems[1].subtitle,
                                tint: const Color(0xFF7EB6C8),
                              ),
                              _BoardNote(
                                icon: Icons.mood_rounded,
                                value: summaryItems[2].value,
                                label: 'Mood',
                                caption: summaryItems[2].subtitle,
                                tint: const Color(0xFFD39B69),
                              ),
                              _BoardNote(
                                icon: Icons.timer_rounded,
                                value: summaryItems[3].value,
                                label: 'Focus',
                                caption: summaryItems[3].subtitle,
                                tint: const Color(0xFF8CA77B),
                              ),
                              _BoardNote(
                                icon: Icons.check_circle_rounded,
                                value: summaryItems[0].value,
                                label: 'Prog.',
                                caption: summaryItems[0].subtitle,
                                tint: const Color(0xFFB79BB7),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: spacing.lg),
        OasisStagger(
          index: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const OasisSectionHeader(
                title: 'Próximas tareas',
                subtitle: 'Tu agenda más cercana, lista para mover',
              ),
              SizedBox(height: spacing.xs),
              const OasisDivider(),
              SizedBox(height: spacing.sm),
              if (data.upcomingTasks.isEmpty)
                OasisEmptyState(
                  icon: AppIcons.agenda,
                  title: 'Hoy tienes un poco mas de espacio para respirar.',
                  description: messageSystem
                      .emptyStateFor(AppEmptyMessageKey.homeUpcomingTasks),
                )
              else
                ...data.upcomingTasks.asMap().entries.map(
                      (entry) => Padding(
                        padding: EdgeInsets.only(bottom: spacing.sm),
                        child: OasisStagger(
                          index: entry.key,
                          child: _HomePaperCard(
                            level: 2,
                            padding: EdgeInsets.all(spacing.md),
                            onTap: () {},
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: colors.semantic.primary
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    AppIcons.agenda,
                                    size: AppIconSize.md.value,
                                    color: colors.semantic.primary,
                                  ),
                                ),
                                SizedBox(width: spacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.value.title,
                                        style: typography.label.copyWith(
                                            color: colors.semantic.textPrimary),
                                      ),
                                      SizedBox(height: spacing.xs / 2),
                                      Text(
                                        [
                                          if (entry.value.timeLabel != null)
                                            entry.value.timeLabel,
                                          entry.value.priorityLabel,
                                          entry.value.statusLabel,
                                        ].join(' • '),
                                        style: typography.body.copyWith(
                                            color: colors.semantic.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader({
    required AppSpacing spacing,
    required AppTypography typography,
    required AppColors colors,
    required String formattedDate,
    required GreetingMessage greeting,
    required bool privacyProtected,
  }) {
    return Container(
      width: double.infinity,
      padding:
          EdgeInsets.fromLTRB(spacing.sm, spacing.sm, spacing.sm, spacing.md),
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
          Image.asset(
            'assets/logos/oasis_logo.png',
            height: 42,
            fit: BoxFit.contain,
          ),
          SizedBox(height: spacing.sm),
          Text(
            greeting.title,
            style: typography.displayLarge
                .copyWith(color: colors.semantic.textPrimary),
          ),
          SizedBox(height: spacing.xs / 2),
          TweenAnimationBuilder<double>(
            duration: MotionSpec.selectionFade,
            curve: MotionSpec.easeInOut,
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: child,
              );
            },
            child: Text(
              greeting.subtitle,
              style: typography.body
                  .copyWith(color: colors.semantic.textSecondary),
            ),
          ),
          SizedBox(height: spacing.xs / 2),
          Text(
            formattedDate,
            style:
                typography.body.copyWith(color: colors.semantic.textSecondary),
          ),
          SizedBox(height: spacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.semantic.surface.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: colors.semantic.primary.withValues(alpha: 0.16),
                ),
              ),
              child: Text(
                privacyProtected ? '🔒 Datos cifrados' : '🛡 Privacidad protegida',
                style: typography.label.copyWith(
                  color: colors.semantic.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(
    BuildContext context,
    AppSpacing spacing,
    AppTypography typography,
    AppColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          const AppMessageSystem()
            .greetingFor(now: DateTime.now(), preferredName: '')
            .title,
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

  Widget _buildError(
    BuildContext context,
    AppSpacing spacing,
    AppTypography typography,
    AppColors colors,
    Object error,
  ) {
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

  String _formatDate(DateTime date, String locale) {
    try {
      initializeDateFormatting(locale);
      return DateFormat('EEEE, d MMMM', locale).format(date);
    } catch (_) {
      return DateFormat('EEEE, d MMMM', 'en').format(date);
    }
  }

  Widget _buildTodayRow(
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

class _SummaryItem {
  final String title;
  final String value;
  final String subtitle;
  final String detail;

  const _SummaryItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.detail,
  });
}

class _TodayCardMessage {
  final String emoji;
  final String message;

  const _TodayCardMessage({required this.emoji, required this.message});
}

class _BoardNote extends StatelessWidget {
  const _BoardNote({
    required this.icon,
    required this.value,
    required this.label,
    required this.caption,
    required this.tint,
  });

  final IconData icon;
  final String value;
  final String label;
  final String caption;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return AspectRatio(
      aspectRatio: 1.18,
      child: _LiftOnTouch(
        onTap: () {},
        child: Transform.rotate(
          angle: 0.012,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(11, 10, 11, 9),
                decoration: BoxDecoration(
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF312B28)
                          : const Color(0xFFFFFBF2))
                      .withValues(alpha: 0.84),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.42),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: tint.withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: tint.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            icon,
                            size: AppIconSize.md.value,
                            color: tint,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 18,
                          height: 4,
                          decoration: BoxDecoration(
                            color: tint.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.label.copyWith(
                        color: colors.semantic.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.caption.copyWith(
                        color: colors.semantic.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typography.caption.copyWith(
                        color: colors.semantic.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryBoard extends StatelessWidget {
  const _SummaryBoard({required this.spacing, required this.children});

  final AppSpacing spacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: EdgeInsets.all(spacing.sm),
          decoration: BoxDecoration(
            color: (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2F2926)
                    : const Color(0xFFFFFAF2))
                .withValues(alpha: 0.54),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.32),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.semantic.primary.withValues(alpha: 0.06),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: spacing.xs,
            crossAxisSpacing: spacing.xs,
            childAspectRatio: 1.28,
            children: children,
          ),
        ),
      ),
    );
  }
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
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final int level;
  final VoidCallback? onTap;

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

    return _LiftOnTouch(onTap: onTap, child: panel);
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
