import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/icons/app_icons.dart';
import '../../../../core/theme/spacing/app_spacing.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/theme/typography/app_typography.dart';
import '../../../../core/design/design_system.dart';
import '../../../../core/design/design_system.dart' as od;
import '../../../../shared/providers/app_launch_intents.dart';
import '../../../../shared/widgets/app_dialog.dart';
import '../../../../shared/widgets/app_fab.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../domain/entities/event.dart';
import '../../domain/enums/event_type.dart';
import '../providers/calendar_controller.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(hours: 1));
  EventType _type = EventType.personal;
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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final intent = ref.read(appLaunchIntentProvider);
      if (intent == AppLaunchIntent.openCalendarNewEvent) {
        ref.read(appLaunchIntentProvider.notifier).state = null;
        _showEventDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final spacing = context.appSpacing;
    final typography = context.appTypography;
    final state = ref.watch(calendarControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton:
          AppFAB(label: 'Nuevo evento', onPressed: _showEventDialog),
      body: state.when(
        data: (calendarState) =>
            _buildContent(context, calendarState, colors, spacing, typography),
        loading: () => const Center(
          child: LoadingIndicator(type: LoadingType.breathingPaper),
        ),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    CalendarState calendarState,
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    return OasisWatercolorBackground(
      accent: OasisSurfaces.calendarAccent,
      child: SafeArea(
        child: CustomScrollView(
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
                          subtitle: 'Organicemos el dia con calma.',
                          showDivider: false,
                        ),
                      ),
                    ),
                    SizedBox(height: spacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () => ref
                                .read(calendarControllerProvider.notifier)
                                .setViewMode(CalendarView.dayAgenda),
                            icon: const Icon(AppIcons.agenda),
                            label: const Text('Agenda del día'),
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
                    SizedBox(height: spacing.lg),
                    if (calendarState.viewMode == CalendarView.dayAgenda) ...[
                      _buildDayAgenda(
                          context, calendarState, colors, spacing, typography),
                    ] else ...[
                      _buildMonthView(
                          context, calendarState, colors, spacing, typography),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayAgenda(
    BuildContext context,
    CalendarState calendarState,
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    final selectedDayKey = DateUtils.dateOnly(calendarState.selectedDay);
    final dayItems = calendarState.timelineItemsForSelectedDay();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              DateFormat('EEEE, d MMM', 'es_ES')
                  .format(calendarState.selectedDay),
              style:
                  typography.title.copyWith(color: colors.semantic.textPrimary),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => ref
                  .read(calendarControllerProvider.notifier)
                  .setSelectedDay(calendarState.selectedDay
                      .subtract(const Duration(days: 1))),
              icon: const Icon(AppIcons.back),
            ),
            IconButton(
              onPressed: () => ref
                  .read(calendarControllerProvider.notifier)
                  .setSelectedDay(
                      calendarState.selectedDay.add(const Duration(days: 1))),
              icon: const Icon(AppIcons.forward),
            ),
          ],
        ),
        SizedBox(height: spacing.md),
        AnimatedSwitcher(
          duration: MotionSpec.selectionFade,
          switchInCurve: MotionSpec.easeInOut,
          switchOutCurve: MotionSpec.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.02, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: dayItems.isEmpty
              ? OasisCard(
                  key: ValueKey<String>('empty-$selectedDayKey'),
                  padding: EdgeInsets.all(spacing.md),
                  child: Row(
                    children: [
                      const Text('🍃', style: TextStyle(fontSize: 22)),
                      SizedBox(width: spacing.sm),
                      Expanded(
                        child: Text(
                          'Hoy tienes un poco mas de espacio para respirar.',
                          style: typography.body.copyWith(
                            color: colors.semantic.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  key: ValueKey<String>('filled-$selectedDayKey'),
                  children: dayItems
                      .asMap()
                      .entries
                      .map((entry) => Padding(
                            padding: EdgeInsets.only(bottom: spacing.sm),
                            child: OasisStagger(
                              index: entry.key,
                              child: _buildTimelineNote(
                                context: context,
                                item: entry.value,
                                calendarState: calendarState,
                                colors: colors,
                                spacing: spacing,
                                typography: typography,
                              ),
                            ),
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildMonthView(
    BuildContext context,
    CalendarState calendarState,
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    final firstDayOfMonth = DateTime(
        calendarState.selectedDay.year, calendarState.selectedDay.month, 1);
    final startOffset = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMMM yyyy', 'es_ES')
                  .format(calendarState.selectedDay),
              style:
                  typography.title.copyWith(color: colors.semantic.textPrimary),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => ref
                      .read(calendarControllerProvider.notifier)
                      .setSelectedDay(DateTime(calendarState.selectedDay.year,
                          calendarState.selectedDay.month - 1, 1)),
                  icon: const Icon(AppIcons.back),
                ),
                IconButton(
                  onPressed: () => ref
                      .read(calendarControllerProvider.notifier)
                      .setSelectedDay(DateTime(calendarState.selectedDay.year,
                          calendarState.selectedDay.month + 1, 1)),
                  icon: const Icon(AppIcons.forward),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: spacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7),
          itemCount: 42,
          itemBuilder: (context, index) {
            final day =
                firstDayOfMonth.add(Duration(days: index - startOffset));
            final dayOnly = DateUtils.dateOnly(day);
            final eventCount = calendarState.events
                .where((event) =>
                    DateUtils.isSameDay(event.startDateTime, dayOnly))
                .length;
            final taskCount = calendarState.tasks
                .where((task) =>
                    task.dueDate != null &&
                    DateUtils.isSameDay(task.dueDate!, dayOnly))
                .length;
            final medicationCount = _medicationCountForDay(
              calendarState: calendarState,
              dayOnly: dayOnly,
            );
            final contentCount = eventCount + taskCount + medicationCount;
            final eventColor = calendarState.events
                .where((event) =>
                    DateUtils.isSameDay(event.startDateTime, dayOnly))
                .map((event) => _parseHexColor(event.color))
                .whereType<Color>()
                .cast<Color?>()
                .firstWhere((color) => color != null, orElse: () => null);
            final isCurrentMonth = day.month == calendarState.selectedDay.month;
            final isSelected =
                DateUtils.isSameDay(dayOnly, calendarState.selectedDay);
            final isToday = DateUtils.isSameDay(dayOnly, DateTime.now());
            final indicatorColor =
                (eventColor ?? colors.semantic.primary).withValues(alpha: 0.66);

            return _MonthDayTile(
              isToday: isToday,
              isSelected: isSelected,
              dayNumber: day.day,
              isCurrentMonth: isCurrentMonth,
              indicator: _activityIndicator(contentCount),
              indicatorColor: indicatorColor,
              typography: typography,
              semanticTextPrimary: colors.semantic.textPrimary,
              semanticTextSecondary: colors.semantic.textSecondary,
              onTap: () {
                ref
                    .read(calendarControllerProvider.notifier)
                    .setSelectedDay(day);
                ref
                    .read(calendarControllerProvider.notifier)
                    .setViewMode(CalendarView.dayAgenda);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimelineNote({
    required BuildContext context,
    required CalendarTimelineItem item,
    required CalendarState calendarState,
    required AppColors colors,
    required AppSpacing spacing,
    required AppTypography typography,
  }) {
    final accent = _timelineAccent(item, colors);

    return OasisCard(
      padding: EdgeInsets.all(spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 58,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.7),
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
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.72),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: spacing.xs),
                    Expanded(
                      child: Text(
                        item.title,
                        style: typography.body.copyWith(
                          color: colors.semantic.textPrimary,
                        ),
                      ),
                    ),
                  ],
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
          Row(
            children: [
              if (item.kind == 'event')
                IconButton(
                  tooltip: 'Editar evento',
                  onPressed: () {
                    final eventId = item.id.replaceFirst('event-', '');
                    final event =
                        calendarState.events.firstWhere((e) => e.id == eventId);
                    _showEventDialog(event: event);
                  },
                  icon: Icon(
                    AppIcons.edit,
                    size: AppIconSize.sm.value + 2,
                    color: colors.semantic.textSecondary,
                  ),
                ),
              _buildTimelineIcon(item.kind, item.isCompleted, colors),
            ],
          ),
        ],
      ),
    );
  }

  Color _timelineAccent(CalendarTimelineItem item, AppColors colors) {
    if (item.kind == 'event') {
      return _parseHexColor(item.color) ?? colors.semantic.primary;
    }
    if (item.kind == 'medication') {
      return colors.semantic.info;
    }
    if (item.kind == 'task') {
      return item.isCompleted
          ? colors.semantic.success
          : colors.semantic.warning;
    }
    return colors.semantic.textSecondary;
  }

  int _medicationCountForDay({
    required CalendarState calendarState,
    required DateTime dayOnly,
  }) {
    var count = 0;
    for (final medication in calendarState.medications) {
      for (final schedule in medication.schedule) {
        final parsed = _parseScheduleTime(schedule, dayOnly);
        if (parsed != null && DateUtils.isSameDay(parsed, dayOnly)) {
          count++;
        }
      }
    }
    return count;
  }

  DateTime? _parseScheduleTime(String schedule, DateTime day) {
    final parts = schedule.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  String _activityIndicator(int contentCount) {
    if (contentCount <= 0) return '';
    if (contentCount == 1) return '○';
    if (contentCount == 2) return '●';
    if (contentCount <= 4) return '●●';
    return '●●●';
  }

  Widget _buildTimelineIcon(String kind, bool isCompleted, AppColors colors) {
    IconData icon;
    Color color;
    switch (kind) {
      case 'event':
        icon = AppIcons.agenda;
        color = colors.semantic.primary;
        break;
      case 'task':
        icon = isCompleted ? AppIcons.success : AppIcons.info;
        color = isCompleted ? colors.semantic.success : colors.semantic.warning;
        break;
      case 'medication':
        icon = AppIcons.add;
        color = colors.semantic.info;
        break;
      default:
        icon = AppIcons.info;
        color = colors.semantic.textSecondary;
    }
    return Icon(icon, color: color, size: AppIconSize.md.value);
  }

  void _showEventDialog({Event? event}) {
    _editingEvent = event;
    _titleController.text = event?.title ?? '';
    _descriptionController.text = event?.description ?? '';
    _locationController.text = event?.location ?? '';
    _start = event?.startDateTime ?? DateTime.now();
    _end = event?.endDateTime ?? DateTime.now().add(const Duration(hours: 1));
    _startController.text = DateFormat('dd/MM/yyyy HH:mm').format(_start);
    _endController.text = DateFormat('dd/MM/yyyy HH:mm').format(_end);
    _type = event?.type ?? EventType.personal;
    _eventColor = event?.color ?? '#7EA08B';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            await _attemptCloseDialog(dialogContext);
          },
          child: AppDialog(
            title: event == null ? 'Nuevo evento' : 'Editar evento',
            actions: [
              TextButton(
                  onPressed: () => _attemptCloseDialog(dialogContext),
                  child: const Text('Cancelar')),
              if (event != null)
                TextButton(
                  onPressed: () async {
                    await ref
                        .read(calendarControllerProvider.notifier)
                        .deleteEvent(event.id);
                    if (!mounted || !dialogContext.mounted) return;
                    Navigator.pop(dialogContext);
                    _clearForm();
                  },
                  child: const Text('Eliminar'),
                ),
              FilledButton(
                  onPressed: () => _saveEvent(dialogContext),
                  child: const Text('Guardar')),
            ],
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppTextField(
                      controller: _titleController,
                      label: 'Título',
                      hint: 'Reunión'),
                  SizedBox(height: context.appSpacing.md),
                  AppTextField(
                      controller: _descriptionController,
                      label: 'Descripción',
                      hint: 'Detalles',
                      maxLines: 3),
                  SizedBox(height: context.appSpacing.md),
                  AppTextField(
                      controller: _locationController,
                      label: 'Ubicación',
                      hint: 'Sala A'),
                  SizedBox(height: context.appSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _startController,
                          label: 'Inicio',
                          readOnly: true,
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: dialogContext,
                              initialDate: _start,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 3650)),
                            );
                            if (pickedDate == null ||
                                !mounted ||
                                !dialogContext.mounted) {
                              return;
                            }
                            final pickedTime = await showTimePicker(
                              context: dialogContext,
                              initialTime: TimeOfDay.fromDateTime(_start),
                            );
                            if (pickedTime == null ||
                                !mounted ||
                                !dialogContext.mounted) {
                              return;
                            }
                            setState(() {
                              _start = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute);
                              _startController.text =
                                  DateFormat('dd/MM/yyyy HH:mm').format(_start);
                            });
                          },
                        ),
                      ),
                      SizedBox(width: context.appSpacing.sm),
                      Expanded(
                        child: AppTextField(
                          controller: _endController,
                          label: 'Fin',
                          readOnly: true,
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: dialogContext,
                              initialDate: _end,
                              firstDate: DateTime.now()
                                  .subtract(const Duration(days: 365)),
                              lastDate: DateTime.now()
                                  .add(const Duration(days: 3650)),
                            );
                            if (pickedDate == null ||
                                !mounted ||
                                !dialogContext.mounted) {
                              return;
                            }
                            final pickedTime = await showTimePicker(
                              context: dialogContext,
                              initialTime: TimeOfDay.fromDateTime(_end),
                            );
                            if (pickedTime == null ||
                                !mounted ||
                                !dialogContext.mounted) {
                              return;
                            }
                            setState(() {
                              _end = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute);
                              _endController.text =
                                  DateFormat('dd/MM/yyyy HH:mm').format(_end);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.appSpacing.md),
                  od.OasisDropdown<EventType>(
                    value: _type,
                    label: 'Tipo',
                    items: EventType.values
                        .map((type) => DropdownMenuItem(
                            value: type, child: Text(type.name)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _type = value ?? EventType.personal),
                  ),
                  SizedBox(height: context.appSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Color',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  SizedBox(height: context.appSpacing.xs),
                  Wrap(
                    spacing: context.appSpacing.sm,
                    children: _palette.entries
                        .map(
                          (entry) => GestureDetector(
                            onTap: () =>
                                setState(() => _eventColor = entry.key),
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

  Future<void> _attemptCloseDialog(BuildContext dialogContext) async {
    final action = await showDialog<String>(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: const Text('¿Qué quieres hacer con los cambios?'),
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
      Navigator.pop(dialogContext);
      _clearForm();
    }
  }

  Future<void> _saveEvent(BuildContext dialogContext) async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    if (_editingEvent == null) {
      await ref.read(calendarControllerProvider.notifier).createEvent(
            title: title,
            startDateTime: _start,
            endDateTime: _end,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            color: _eventColor,
          );
    } else {
      await ref.read(calendarControllerProvider.notifier).updateEvent(
            id: _editingEvent!.id,
            title: title,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            startDateTime: _start,
            endDateTime: _end,
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            color: _eventColor,
          );
    }

    if (!mounted || !dialogContext.mounted) return;
    Navigator.pop(dialogContext);
    _clearForm();
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _locationController.clear();
    _startController.clear();
    _endController.clear();
    _start = DateTime.now();
    _end = DateTime.now().add(const Duration(hours: 1));
    _type = EventType.personal;
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

class _MonthDayTile extends StatefulWidget {
  const _MonthDayTile({
    required this.isToday,
    required this.isSelected,
    required this.dayNumber,
    required this.isCurrentMonth,
    required this.indicator,
    required this.indicatorColor,
    required this.typography,
    required this.semanticTextPrimary,
    required this.semanticTextSecondary,
    required this.onTap,
  });

  final bool isToday;
  final bool isSelected;
  final int dayNumber;
  final bool isCurrentMonth;
  final String indicator;
  final Color indicatorColor;
  final AppTypography typography;
  final Color semanticTextPrimary;
  final Color semanticTextSecondary;
  final VoidCallback onTap;

  @override
  State<_MonthDayTile> createState() => _MonthDayTileState();
}

class _MonthDayTileState extends State<_MonthDayTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dayTextColor = widget.isCurrentMonth
        ? widget.semanticTextPrimary
        : widget.semanticTextSecondary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: MotionSpec.micro,
        curve: MotionSpec.easeOut,
        child: OasisCard(
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(6),
          child: AnimatedContainer(
            duration: MotionSpec.selectionFade,
            curve: MotionSpec.easeOut,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: widget.isSelected
                  ? widget.indicatorColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              boxShadow: widget.isToday
                  ? [
                      BoxShadow(
                        color: widget.indicatorColor.withValues(alpha: 0.18),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : const [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.isToday
                        ? widget.indicatorColor.withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.dayNumber}',
                    style:
                        widget.typography.label.copyWith(color: dayTextColor),
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.indicator.isNotEmpty)
                  Text(
                    widget.indicator,
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.4,
                      color: widget.indicatorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
