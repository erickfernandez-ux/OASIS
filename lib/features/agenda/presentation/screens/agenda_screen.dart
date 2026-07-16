import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/usecase_providers.dart';
import '../../../../core/design/design_system.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/icons/app_icons.dart';
import '../../../../core/theme/spacing/app_spacing.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/theme/typography/app_typography.dart';
import '../../../../shared/providers/app_message_system_provider.dart';
import '../../../../shared/providers/app_launch_intents.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../../calendar/domain/entities/event.dart';
import '../../../calendar/presentation/providers/calendar_controller.dart';
import '../../domain/entities/task.dart';
import '../../domain/enums/task_status.dart';
import '../providers/agenda_controller.dart';

enum _AgendaTab { calendar, tasks, reminders }

enum _EventRepeatPattern { none, daily, weekly, monthly }

class _AgendaFutureIntegrations {
  const _AgendaFutureIntegrations._();

  static const String notifications = 'Preparado: notificaciones por evento';

  static String repeatMessage() {
    const patterns = [
      _EventRepeatPattern.daily,
      _EventRepeatPattern.weekly,
      _EventRepeatPattern.monthly,
    ];
    final labels = patterns.map((p) => switch (p) {
          _EventRepeatPattern.daily => 'diaria',
          _EventRepeatPattern.weekly => 'semanal',
          _EventRepeatPattern.monthly => 'mensual',
          _EventRepeatPattern.none => 'sin repeticion',
        });
    return 'Preparado: reglas de repeticion (${labels.join(', ')})';
  }
}

const _exampleTaskTitles = <String>{
  'Revisar correos pendientes',
  'Llamar al dentista',
  'Comprar ingredientes para la cena',
};

const _exampleEventTitles = <String>{
  'Reunión de equipo',
  'Cita médica',
  'Cena con amigos',
};

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  _AgendaTab _activeTab = _AgendaTab.calendar;

  final _taskTitleController = TextEditingController();
  final _taskDescriptionController = TextEditingController();
  final _taskDueDateController = TextEditingController();
  DateTime? _taskDueDate;
  Task? _editingTask;

  final _eventTitleController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventLocationController = TextEditingController();
  final _eventStartController = TextEditingController();
  final _eventEndController = TextEditingController();
  DateTime _eventStart = DateTime.now();
  DateTime _eventEnd = DateTime.now().add(const Duration(hours: 1));
  String _eventColor = '#7EA08B';
  Event? _editingEvent;

  static const Map<String, Color> _palette = {
    '#7EA08B': Color(0xFF7EA08B),
    '#6D9DC5': Color(0xFF6D9DC5),
    '#C18C6A': Color(0xFFC18C6A),
    '#B68BB5': Color(0xFFB68BB5),
    '#A6A48F': Color(0xFFA6A48F),
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _consumeLaunchIntent();
    });
  }

  @override
  void dispose() {
    _taskTitleController.dispose();
    _taskDescriptionController.dispose();
    _taskDueDateController.dispose();
    _eventTitleController.dispose();
    _eventDescriptionController.dispose();
    _eventLocationController.dispose();
    _eventStartController.dispose();
    _eventEndController.dispose();
    super.dispose();
  }

  void _consumeLaunchIntent() {
    final intent = ref.read(appLaunchIntentProvider);
    if (intent == AppLaunchIntent.openAgendaTasksNewTask) {
      setState(() => _activeTab = _AgendaTab.tasks);
      ref.read(appLaunchIntentProvider.notifier).state = null;
      _showTaskDialog();
      return;
    }

    if (intent == AppLaunchIntent.openAgendaCalendarNewEvent ||
        intent == AppLaunchIntent.openCalendarNewEvent) {
      setState(() => _activeTab = _AgendaTab.calendar);
      ref.read(appLaunchIntentProvider.notifier).state = null;
      _showEventDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final spacing = context.appSpacing;
    final typography = context.appTypography;
    final messageSystem = ref.watch(appMessageSystemProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OasisWatercolorBackground(
        accent: OasisSurfaces.calendarAccent,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait<void>([
                ref.read(calendarControllerProvider.notifier).refresh(),
                ref.read(agendaControllerProvider.notifier).refresh(),
              ]);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(spacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Hero(
                          tag: OasisHeroTags.agendaHeader,
                          child: Material(
                            type: MaterialType.transparency,
                            child: SectionTitle(
                              title: 'Agenda',
                              subtitle:
                                  'Calendario, tareas y recordatorios unidos.',
                              showDivider: false,
                            ),
                          ),
                        ),
                        SizedBox(height: spacing.md),
                        _buildSegmentedTabs(colors, spacing, typography),
                        SizedBox(height: spacing.lg),
                        AnimatedSwitcher(
                          duration: MotionSpec.selectionFade,
                          switchInCurve: MotionSpec.easeOut,
                          switchOutCurve: MotionSpec.easeInOut,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.06, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: KeyedSubtree(
                            key: ValueKey<_AgendaTab>(_activeTab),
                            child: switch (_activeTab) {
                              _AgendaTab.calendar => _buildCalendarTab(
                                  colors,
                                  spacing,
                                  typography,
                                  messageSystem,
                                ),
                              _AgendaTab.tasks => _buildTasksTab(
                                  colors,
                                  spacing,
                                  typography,
                                  messageSystem,
                                ),
                              _AgendaTab.reminders =>
                                _buildRemindersTab(
                                  colors,
                                  spacing,
                                  typography,
                                  messageSystem,
                                ),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedTabs(
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.semantic.surfaceVariant.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.semantic.outline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colors.semantic.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: 'Calendario',
              selected: _activeTab == _AgendaTab.calendar,
              onTap: () => setState(() => _activeTab = _AgendaTab.calendar),
              colors: colors,
              typography: typography,
              spacing: spacing,
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: 'Tareas',
              selected: _activeTab == _AgendaTab.tasks,
              onTap: () => setState(() => _activeTab = _AgendaTab.tasks),
              colors: colors,
              typography: typography,
              spacing: spacing,
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: 'Recordatorios',
              selected: _activeTab == _AgendaTab.reminders,
              onTap: () => setState(() => _activeTab = _AgendaTab.reminders),
              colors: colors,
              typography: typography,
              spacing: spacing,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab(
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
    AppMessageSystem messageSystem,
  ) {
    final calendarState = ref.watch(calendarControllerProvider);

    return calendarState.when(
      data: (state) {
        final dayItems = state.timelineItemsForSelectedDay();
        final exampleEvents = state.events.where(_isExampleEvent).toList(growable: false);
        final firstDayOfMonth =
            DateTime(state.selectedDay.year, state.selectedDay.month, 1);
        final startOffset = firstDayOfMonth.weekday % 7;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => ref
                        .read(calendarControllerProvider.notifier)
                        .setViewMode(CalendarView.dayAgenda),
                    icon: const Icon(AppIcons.agenda),
                    label: const Text('Agenda del dia'),
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: () => ref
                        .read(calendarControllerProvider.notifier)
                        .setViewMode(CalendarView.monthView),
                    icon: const Icon(AppIcons.agenda),
                    label: const Text('Mes'),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.md),
            if (state.viewMode == CalendarView.dayAgenda) ...[
              Row(
                children: [
                  Text(
                    DateFormat('EEEE, d MMM', 'es_ES').format(state.selectedDay),
                    style: typography.title
                        .copyWith(color: colors.semantic.textPrimary),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => ref
                        .read(calendarControllerProvider.notifier)
                        .setSelectedDay(
                          state.selectedDay.subtract(const Duration(days: 1)),
                        ),
                    icon: const Icon(AppIcons.back),
                  ),
                  IconButton(
                    onPressed: () => ref
                        .read(calendarControllerProvider.notifier)
                        .setSelectedDay(
                          state.selectedDay.add(const Duration(days: 1)),
                        ),
                    icon: const Icon(AppIcons.forward),
                  ),
                ],
              ),
              SizedBox(height: spacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: spacing.sm,
                  runSpacing: spacing.sm,
                  children: [
                    FilledButton.icon(
                      onPressed: _showEventDialog,
                      icon: const Icon(AppIcons.add),
                      label: const Text('Nuevo evento'),
                    ),
                    if (exampleEvents.isNotEmpty)
                      TextButton.icon(
                        onPressed: () => _clearExampleEvents(exampleEvents),
                        icon: const Icon(AppIcons.delete),
                        label: Text('Quitar ejemplos (${exampleEvents.length})'),
                      ),
                  ],
                ),
              ),
              SizedBox(height: spacing.sm),
              OasisCard(
                padding: EdgeInsets.all(spacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _AgendaFutureIntegrations.notifications,
                      style: typography.caption.copyWith(
                        color: colors.semantic.textSecondary,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    Text(
                      _AgendaFutureIntegrations.repeatMessage(),
                      style: typography.caption.copyWith(
                        color: colors.semantic.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing.md),
              if (dayItems.isEmpty)
                OasisCard(
                  padding: EdgeInsets.all(spacing.md),
                  child: Text(
                    messageSystem.emptyStateFor(AppEmptyMessageKey.agendaEvents),
                    style: typography.body
                        .copyWith(color: colors.semantic.textSecondary),
                  ),
                )
              else
                Column(
                  children: dayItems.map((item) {
                    final accent = _timelineAccent(item.kind, item.color, item.isCompleted, colors);
                    return Padding(
                      padding: EdgeInsets.only(bottom: spacing.sm),
                      child: OasisCard(
                        padding: EdgeInsets.all(spacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 4,
                              height: 54,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.72),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            SizedBox(width: spacing.sm),
                            SizedBox(
                              width: 72,
                              child: Text(
                                DateFormat('HH:mm').format(item.time),
                                style: typography.label.copyWith(
                                  color: colors.semantic.textSecondary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: typography.body.copyWith(
                                      color: colors.semantic.textPrimary,
                                    ),
                                  ),
                                  SizedBox(height: spacing.xs),
                                  Text(
                                    item.subtitle,
                                    style: typography.label.copyWith(
                                      color: colors.semantic.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (item.kind == 'event')
                              IconButton(
                                tooltip: 'Editar evento',
                                onPressed: () {
                                  final eventId = item.id.replaceFirst('event-', '');
                                  final event = state.events.firstWhere(
                                    (event) => event.id == eventId,
                                  );
                                  _showEventDialog(event: event);
                                },
                                icon: const Icon(AppIcons.edit),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy', 'es_ES').format(state.selectedDay),
                    style: typography.title
                        .copyWith(color: colors.semantic.textPrimary),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => ref
                            .read(calendarControllerProvider.notifier)
                            .setSelectedDay(
                              DateTime(
                                state.selectedDay.year,
                                state.selectedDay.month - 1,
                                1,
                              ),
                            ),
                        icon: const Icon(AppIcons.back),
                      ),
                      IconButton(
                        onPressed: () => ref
                            .read(calendarControllerProvider.notifier)
                            .setSelectedDay(
                              DateTime(
                                state.selectedDay.year,
                                state.selectedDay.month + 1,
                                1,
                              ),
                            ),
                        icon: const Icon(AppIcons.forward),
                      ),
                    ],
                  ),
                ],
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
                itemCount: 42,
                itemBuilder: (context, index) {
                  final day = firstDayOfMonth.add(Duration(days: index - startOffset));
                  final dayOnly = DateUtils.dateOnly(day);
                  final eventCount = state.events
                      .where((event) => DateUtils.isSameDay(event.startDateTime, dayOnly))
                      .length;
                  final taskCount = state.tasks
                      .where((task) =>
                          task.dueDate != null &&
                          DateUtils.isSameDay(task.dueDate!, dayOnly))
                      .length;
                  final contentCount = eventCount + taskCount;
                  final isCurrentMonth = day.month == state.selectedDay.month;
                  final isSelected = DateUtils.isSameDay(dayOnly, state.selectedDay);

                  return GestureDetector(
                    onTap: () {
                      ref.read(calendarControllerProvider.notifier).setSelectedDay(day);
                      ref
                          .read(calendarControllerProvider.notifier)
                          .setViewMode(CalendarView.dayAgenda);
                    },
                    child: OasisCard(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${day.day}',
                            style: typography.label.copyWith(
                              color: isCurrentMonth
                                  ? colors.semantic.textPrimary
                                  : colors.semantic.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          if (contentCount > 0)
                            Text(
                              contentCount == 1
                                  ? '●'
                                  : contentCount == 2
                                      ? '●●'
                                      : '●●●',
                              style: TextStyle(
                                color: isSelected
                                    ? colors.semantic.primary
                                    : colors.semantic.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: spacing.sm),
              Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  FilledButton.icon(
                    onPressed: _showEventDialog,
                    icon: const Icon(AppIcons.add),
                    label: const Text('Nuevo evento'),
                  ),
                  if (exampleEvents.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _clearExampleEvents(exampleEvents),
                      icon: const Icon(AppIcons.delete),
                      label: Text('Quitar ejemplos (${exampleEvents.length})'),
                    ),
                ],
              ),
            ],
          ],
        );
      },
      loading: () => const Center(
        child: LoadingIndicator(type: LoadingType.breathingPaper),
      ),
      error: (error, _) => Text(error.toString()),
    );
  }

  Widget _buildTasksTab(
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
    AppMessageSystem messageSystem,
  ) {
    final tasksState = ref.watch(agendaControllerProvider);

    return tasksState.when(
      data: (tasks) {
        final exampleTasks = tasks.where(_isExampleTask).toList(growable: false);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: spacing.sm,
                runSpacing: spacing.sm,
                children: [
                  FilledButton.icon(
                    onPressed: _showTaskDialog,
                    icon: const Icon(AppIcons.add),
                    label: const Text('Nueva tarea'),
                  ),
                  if (exampleTasks.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _clearExampleTasks(exampleTasks),
                      icon: const Icon(AppIcons.delete),
                      label: Text('Quitar ejemplos (${exampleTasks.length})'),
                    ),
                ],
              ),
            ),
            SizedBox(height: spacing.md),
            if (tasks.isEmpty)
              OasisCard(
                padding: EdgeInsets.all(spacing.md),
                child: Text(
                  messageSystem.emptyStateFor(AppEmptyMessageKey.agendaTasks),
                  style: typography.body
                      .copyWith(color: colors.semantic.textSecondary),
                ),
              )
            else
              Column(
                children: tasks.map((task) {
                  final isCompleted = task.status == TaskStatus.completed;
                  return Padding(
                    padding: EdgeInsets.only(bottom: spacing.sm),
                    child: OasisCard(
                      padding: EdgeInsets.all(spacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: isCompleted,
                            onChanged: (_) {
                              if (isCompleted) {
                                ref
                                    .read(agendaControllerProvider.notifier)
                                    .uncompleteTask(task.id);
                              } else {
                                ref
                                    .read(agendaControllerProvider.notifier)
                                    .completeTask(task.id);
                              }
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: typography.body.copyWith(
                                    color: colors.semantic.textPrimary,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                if ((task.description ?? '').trim().isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: spacing.xs),
                                    child: Text(
                                      task.description!,
                                      style: typography.label.copyWith(
                                        color: colors.semantic.textSecondary,
                                      ),
                                    ),
                                  ),
                                if (task.dueDate != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: spacing.xs),
                                    child: Text(
                                      'Vence: ${DateFormat('dd/MM/yyyy').format(task.dueDate!)}',
                                      style: typography.label.copyWith(
                                        color: colors.semantic.textSecondary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showTaskDialog(task: task);
                              }
                              if (value == 'delete') {
                                ref
                                    .read(agendaControllerProvider.notifier)
                                    .deleteTask(task.id);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Editar'),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Eliminar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
      loading: () => const Center(
        child: LoadingIndicator(type: LoadingType.breathingPaper),
      ),
      error: (error, _) => Text(error.toString()),
    );
  }

  Widget _buildRemindersTab(
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
    AppMessageSystem messageSystem,
  ) {
    return OasisCard(
      padding: EdgeInsets.all(spacing.lg),
      child: Center(
        child: Column(
          children: [
            Text(
              '🔔',
              style: typography.displayMedium,
            ),
            SizedBox(height: spacing.sm),
            Text(
              messageSystem.emptyStateFor(AppEmptyMessageKey.agendaReminders),
              textAlign: TextAlign.center,
              style: typography.body.copyWith(
                color: colors.semantic.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _timelineAccent(
    String kind,
    String? colorHex,
    bool isCompleted,
    AppColors colors,
  ) {
    if (kind == 'event') {
      return _parseHexColor(colorHex) ?? colors.semantic.primary;
    }
    if (kind == 'medication') {
      return colors.semantic.info;
    }
    if (kind == 'task') {
      return isCompleted ? colors.semantic.success : colors.semantic.warning;
    }
    return colors.semantic.textSecondary;
  }

  bool _isExampleTask(Task task) {
    return task.id.startsWith('sample-task-') ||
        task.tags.contains('ejemplo') ||
        _exampleTaskTitles.contains(task.title);
  }

  bool _isExampleEvent(Event event) {
    return event.id.startsWith('sample-event-') ||
        _exampleEventTitles.contains(event.title);
  }

  Future<void> _clearExampleTasks(List<Task> tasks) async {
    if (tasks.isEmpty) {
      return;
    }

    final deleteTask = ref.read(deleteTaskProvider);
    for (final task in tasks) {
      await deleteTask(task.id);
    }
    await ref.read(agendaControllerProvider.notifier).refresh();

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Se quitaron ${tasks.length} ejemplos de tareas.')),
    );
  }

  Future<void> _clearExampleEvents(List<Event> events) async {
    if (events.isEmpty) {
      return;
    }

    final deleteEvent = ref.read(deleteEventProvider);
    for (final event in events) {
      await deleteEvent(event.id);
    }
    await Future.wait<void>([
      ref.read(calendarControllerProvider.notifier).refresh(),
      ref.read(agendaControllerProvider.notifier).refresh(),
    ]);

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Se quitaron ${events.length} ejemplos de eventos.')),
    );
  }

  void _showTaskDialog({Task? task}) {
    _editingTask = task;
    _taskTitleController.text = task?.title ?? '';
    _taskDescriptionController.text = task?.description ?? '';
    _taskDueDate = task?.dueDate;
    _taskDueDateController.text = _taskDueDate == null
        ? ''
        : DateFormat('dd/MM/yyyy').format(_taskDueDate!);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            await _attemptCloseTaskDialog(dialogContext);
          },
          child: AppDialog(
            title: task == null ? 'Nueva tarea' : 'Editar tarea',
            actions: [
              TextButton(
                onPressed: () => _attemptCloseTaskDialog(dialogContext),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => _saveTask(dialogContext),
                child: const Text('Guardar'),
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: _taskTitleController,
                  label: 'Titulo',
                  hint: 'Escribe la tarea',
                ),
                SizedBox(height: context.appSpacing.md),
                AppTextField(
                  controller: _taskDescriptionController,
                  label: 'Descripcion',
                  hint: 'Detalles opcionales',
                  maxLines: 3,
                ),
                SizedBox(height: context.appSpacing.md),
                AppTextField(
                  controller: _taskDueDateController,
                  label: 'Fecha limite',
                  readOnly: true,
                  hint: 'Seleccionar',
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: _taskDueDate ?? DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked == null || !mounted || !dialogContext.mounted) {
                      return;
                    }
                    setState(() {
                      _taskDueDate = picked;
                      _taskDueDateController.text =
                          DateFormat('dd/MM/yyyy').format(picked);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _hasTaskDraftChanges() {
    return _taskTitleController.text.trim().isNotEmpty ||
        _taskDescriptionController.text.trim().isNotEmpty ||
        _taskDueDate != null;
  }

  Future<void> _attemptCloseTaskDialog(BuildContext dialogContext) async {
    if (!_hasTaskDraftChanges()) {
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }
      _clearTaskForm();
      return;
    }

    final action = await showDialog<String>(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: const Text('Que quieres hacer con los cambios?'),
        content: const Text('Puedes guardar, descartar o seguir editando.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text('Descartar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (!mounted || !dialogContext.mounted) {
      return;
    }

    if (action == 'save') {
      await _saveTask(dialogContext);
      return;
    }

    if (action == 'discard') {
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }
      _clearTaskForm();
    }
  }

  Future<void> _saveTask(BuildContext dialogContext) async {
    final title = _taskTitleController.text.trim();
    final description = _taskDescriptionController.text.trim();
    if (title.isEmpty) return;

    if (_editingTask == null) {
      await ref.read(agendaControllerProvider.notifier).createTask(
            title: title,
            description: description.isEmpty ? null : description,
            dueDate: _taskDueDate,
          );
    } else {
      await ref.read(agendaControllerProvider.notifier).updateTask(
            id: _editingTask!.id,
            title: title,
            description: description.isEmpty ? null : description,
            dueDate: _taskDueDate,
            status: _editingTask!.status,
          );
    }

    if (!mounted || !dialogContext.mounted) return;
    Navigator.pop(dialogContext);
    _clearTaskForm();
  }

  void _clearTaskForm() {
    _taskTitleController.clear();
    _taskDescriptionController.clear();
    _taskDueDateController.clear();
    _taskDueDate = null;
    _editingTask = null;
  }

  void _showEventDialog({Event? event}) {
    _editingEvent = event;
    _eventTitleController.text = event?.title ?? '';
    _eventDescriptionController.text = event?.description ?? '';
    _eventLocationController.text = event?.location ?? '';
    _eventStart = event?.startDateTime ?? DateTime.now();
    _eventEnd = event?.endDateTime ?? DateTime.now().add(const Duration(hours: 1));
    _eventStartController.text = DateFormat('dd/MM/yyyy HH:mm').format(_eventStart);
    _eventEndController.text = DateFormat('dd/MM/yyyy HH:mm').format(_eventEnd);
    _eventColor = event?.color ?? '#7EA08B';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            await _attemptCloseEventDialog(dialogContext);
          },
          child: AppDialog(
            title: event == null ? 'Nuevo evento' : 'Editar evento',
            actions: [
              TextButton(
                onPressed: () => _attemptCloseEventDialog(dialogContext),
                child: const Text('Cancelar'),
              ),
              if (event != null)
                TextButton(
                  onPressed: () async {
                    await ref
                        .read(calendarControllerProvider.notifier)
                        .deleteEvent(event.id);
                    if (!mounted || !dialogContext.mounted) return;
                    Navigator.pop(dialogContext);
                    _clearEventForm();
                  },
                  child: const Text('Eliminar'),
                ),
              FilledButton(
                onPressed: () => _saveEvent(dialogContext),
                child: const Text('Guardar'),
              ),
            ],
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppTextField(
                    controller: _eventTitleController,
                    label: 'Titulo',
                    hint: 'Reunion',
                  ),
                  SizedBox(height: context.appSpacing.md),
                  AppTextField(
                    controller: _eventDescriptionController,
                    label: 'Descripcion',
                    hint: 'Detalles',
                    maxLines: 3,
                  ),
                  SizedBox(height: context.appSpacing.md),
                  AppTextField(
                    controller: _eventLocationController,
                    label: 'Ubicacion',
                    hint: 'Sala A',
                  ),
                  SizedBox(height: context.appSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _eventStartController,
                          label: 'Inicio',
                          readOnly: true,
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: dialogContext,
                              initialDate: _eventStart,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (pickedDate == null ||
                                !mounted ||
                                !dialogContext.mounted) {
                              return;
                            }
                            final pickedTime = await showTimePicker(
                              context: dialogContext,
                              initialTime: TimeOfDay.fromDateTime(_eventStart),
                            );
                            if (pickedTime == null ||
                                !mounted ||
                                !dialogContext.mounted) {
                              return;
                            }
                            setState(() {
                              _eventStart = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              _eventStartController.text =
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(_eventStart);
                            });
                          },
                        ),
                      ),
                      SizedBox(width: context.appSpacing.sm),
                      Expanded(
                        child: AppTextField(
                          controller: _eventEndController,
                          label: 'Fin',
                          readOnly: true,
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: dialogContext,
                              initialDate: _eventEnd,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (pickedDate == null ||
                                !mounted ||
                                !dialogContext.mounted) {
                              return;
                            }
                            final pickedTime = await showTimePicker(
                              context: dialogContext,
                              initialTime: TimeOfDay.fromDateTime(_eventEnd),
                            );
                            if (pickedTime == null ||
                                !mounted ||
                                !dialogContext.mounted) {
                              return;
                            }
                            setState(() {
                              _eventEnd = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              _eventEndController.text =
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(_eventEnd);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.appSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Color',
                      style: Theme.of(dialogContext).textTheme.labelMedium,
                    ),
                  ),
                  SizedBox(height: context.appSpacing.xs),
                  Wrap(
                    spacing: context.appSpacing.sm,
                    children: _palette.entries
                        .map(
                          (entry) => GestureDetector(
                            onTap: () => setState(() => _eventColor = entry.key),
                            child: AnimatedContainer(
                              duration: MotionSpec.longPress,
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: entry.value,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _eventColor == entry.key
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool _hasEventDraftChanges() {
    return _eventTitleController.text.trim().isNotEmpty ||
        _eventDescriptionController.text.trim().isNotEmpty ||
        _eventLocationController.text.trim().isNotEmpty;
  }

  Future<void> _attemptCloseEventDialog(BuildContext dialogContext) async {
    if (!_hasEventDraftChanges()) {
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }
      _clearEventForm();
      return;
    }

    final action = await showDialog<String>(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: const Text('Que quieres hacer con los cambios?'),
        content: const Text('Puedes guardar, descartar o seguir editando.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: const Text('Descartar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (!mounted || !dialogContext.mounted) {
      return;
    }

    if (action == 'save') {
      await _saveEvent(dialogContext);
      return;
    }

    if (action == 'discard') {
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }
      _clearEventForm();
    }
  }

  Future<void> _saveEvent(BuildContext dialogContext) async {
    final title = _eventTitleController.text.trim();
    if (title.isEmpty) return;

    final description = _eventDescriptionController.text.trim();
    final location = _eventLocationController.text.trim();

    if (_editingEvent == null) {
      await ref.read(calendarControllerProvider.notifier).createEvent(
            title: title,
            startDateTime: _eventStart,
            endDateTime: _eventEnd,
            description: description.isEmpty ? null : description,
            location: location.isEmpty ? null : location,
            color: _eventColor,
          );
    } else {
      await ref.read(calendarControllerProvider.notifier).updateEvent(
            id: _editingEvent!.id,
            title: title,
            description: description.isEmpty ? null : description,
            startDateTime: _eventStart,
            endDateTime: _eventEnd,
            location: location.isEmpty ? null : location,
            color: _eventColor,
          );
    }

    if (!mounted || !dialogContext.mounted) return;
    Navigator.pop(dialogContext);
    _clearEventForm();
  }

  void _clearEventForm() {
    _eventTitleController.clear();
    _eventDescriptionController.clear();
    _eventLocationController.clear();
    _eventStartController.clear();
    _eventEndController.clear();
    _eventStart = DateTime.now();
    _eventEnd = DateTime.now().add(const Duration(hours: 1));
    _eventColor = '#7EA08B';
    _editingEvent = null;
  }

  Color? _parseHexColor(String? value) {
    if (value == null || value.isEmpty) return null;
    final cleaned = value.replaceFirst('#', '');
    if (cleaned.length != 6) return null;
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.typography,
    required this.spacing,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppColors colors;
  final AppTypography typography;
  final AppSpacing spacing;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: MotionSpec.selectionFade,
      curve: MotionSpec.easeOut,
      scale: selected ? 1.0 : 0.985,
      child: AnimatedContainer(
        duration: MotionSpec.selectionFade,
        curve: MotionSpec.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? colors.semantic.primary.withValues(alpha: 0.16)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? colors.semantic.primary.withValues(alpha: 0.3)
                : Colors.transparent,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colors.semantic.primary.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding:
                EdgeInsets.symmetric(vertical: spacing.sm, horizontal: spacing.xs),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: typography.label.copyWith(
                color: selected
                    ? colors.semantic.primary
                    : colors.semantic.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: selected ? 0.2 : 0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
