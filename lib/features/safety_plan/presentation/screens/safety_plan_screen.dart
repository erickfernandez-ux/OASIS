import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/design/design_system.dart';
import '../../../../core/theme/icons/app_icons.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../settings/domain/enums/canvas_motion_preference.dart';
import '../../domain/entities/safety_contact.dart';
import '../../domain/entities/safety_plan.dart';
import '../../domain/entities/safety_professional.dart';
import '../providers/safety_plan_controller.dart';

class SafetyPlanScreen extends ConsumerStatefulWidget {
  const SafetyPlanScreen({super.key});

  @override
  ConsumerState<SafetyPlanScreen> createState() => _SafetyPlanScreenState();
}

class _SafetyPlanScreenState extends ConsumerState<SafetyPlanScreen> {
  final _warningController = TextEditingController();
  final _actionController = TextEditingController();
  final _placeController = TextEditingController();
  final _reasonController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactRelationshipController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactMessageController = TextEditingController();
  final _professionalNameController = TextEditingController();
  final _professionalRoleController = TextEditingController();
  final _professionalPhoneController = TextEditingController();

  @override
  void dispose() {
    _warningController.dispose();
    _actionController.dispose();
    _placeController.dispose();
    _reasonController.dispose();
    _contactNameController.dispose();
    _contactRelationshipController.dispose();
    _contactPhoneController.dispose();
    _contactMessageController.dispose();
    _professionalNameController.dispose();
    _professionalRoleController.dispose();
    _professionalPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(safetyPlanControllerProvider);

    final crisisMode = state.valueOrNull?.crisisMode ?? false;

    return OasisScreenShell(
      title: 'Plan de seguridad',
      subtitle: 'Un espacio seguro para acompañarte cuando lo necesites.',
      accent: OasisSurfaces.safetyAccent,
      motionOverride: crisisMode ? CanvasMotionPreference.off : null,
      disableAnimations: crisisMode,
      appBarActions: [
        TextButton.icon(
          onPressed: () => _exitSafetyPlan(context),
          icon: const Icon(AppIcons.close),
          label: const Text('Salir'),
        ),
      ],
      floatingActionButton: EmergencyButton(
        tooltip: 'Plan de seguridad',
        isActive: crisisMode,
        onTap: () => ref
            .read(safetyPlanControllerProvider.notifier)
            .setCrisisMode(!crisisMode),
      ),
      child: state.when(
        data: (plan) => crisisMode
            ? _crisisWrapper(_buildCrisisContent(context, plan))
            : _buildFullContent(context, plan),
        loading: () => const Padding(
          padding: EdgeInsets.only(top: OasisSpacing.xl),
          child: Center(
            child: LoadingIndicator(type: LoadingType.breathingPaper),
          ),
        ),
        error: (error, _) => Padding(
          padding: const EdgeInsets.only(top: OasisSpacing.xl),
          child: Text(error.toString()),
        ),
      ),
    );
  }

  Widget _buildFullContent(BuildContext context, SafetyPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafetySection(
          title:
              'Paso 1 · ¿Cómo me doy cuenta de que estoy entrando en crisis?',
          subtitle: 'Señales tempranas para reconocer el momento a tiempo.',
          level: 3,
          child: _editableStringSection(
            items: plan.warningSigns,
            controller: _warningController,
            hint: 'Agregar señal',
            onAdd: () async {
              await ref
                  .read(safetyPlanControllerProvider.notifier)
                  .addWarningSign(_warningController.text);
              _warningController.clear();
            },
            onRemove: (index) => ref
                .read(safetyPlanControllerProvider.notifier)
                .removeWarningSign(index),
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        SafetySection(
          title: 'Paso 2 · ¿Qué puedo hacer por mí mismo?',
          subtitle:
              'Acciones concretas para bajar intensidad y recuperar aire.',
          child: _editableStringSection(
            items: plan.selfActions,
            controller: _actionController,
            hint: 'Agregar acción de autocuidado',
            onAdd: () async {
              await ref
                  .read(safetyPlanControllerProvider.notifier)
                  .addSelfAction(_actionController.text);
              _actionController.clear();
            },
            onRemove: (index) => ref
                .read(safetyPlanControllerProvider.notifier)
                .removeSelfAction(index),
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        SafetySection(
          title: 'Paso 3 · Lugares seguros',
          subtitle: 'Espacios donde tu cuerpo y mente pueden bajar la guardia.',
          child: _editableStringSection(
            items: plan.safePlaces,
            controller: _placeController,
            hint: 'Agregar lugar seguro',
            onAdd: () async {
              await ref
                  .read(safetyPlanControllerProvider.notifier)
                  .addSafePlace(_placeController.text);
              _placeController.clear();
            },
            onRemove: (index) => ref
                .read(safetyPlanControllerProvider.notifier)
                .removeSafePlace(index),
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        SafetySection(
          title: 'Paso 4 · Personas que puedo contactar',
          subtitle: 'Tu red de apoyo inmediata.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final contact in plan.contacts) ...[
                _contactTile(contact),
                const SizedBox(height: OasisSpacing.sm),
              ],
              OasisTextField(
                  controller: _contactNameController, hint: 'Nombre'),
              const SizedBox(height: OasisSpacing.sm),
              OasisTextField(
                  controller: _contactRelationshipController, hint: 'Relación'),
              const SizedBox(height: OasisSpacing.sm),
              OasisTextField(
                  controller: _contactPhoneController, hint: 'Teléfono'),
              const SizedBox(height: OasisSpacing.sm),
              OasisMultilineField(
                  controller: _contactMessageController,
                  hint: 'Mensaje rápido',
                  minLines: 2),
              const SizedBox(height: OasisSpacing.sm),
              OasisButton(
                label: 'Agregar contacto',
                leading: AppIcons.phone,
                onPressed: () async {
                  await ref
                      .read(safetyPlanControllerProvider.notifier)
                      .addContact(
                        name: _contactNameController.text,
                        relationship: _contactRelationshipController.text,
                        phone: _contactPhoneController.text,
                        message: _contactMessageController.text,
                      );
                  _contactNameController.clear();
                  _contactRelationshipController.clear();
                  _contactPhoneController.clear();
                  _contactMessageController.clear();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        SafetySection(
          title: 'Paso 5 · Profesionales',
          subtitle:
              'Apoyos clínicos y de emergencia preparados por adelantado.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final professional in plan.professionals) ...[
                _professionalTile(professional),
                const SizedBox(height: OasisSpacing.sm),
              ],
              OasisTextField(
                  controller: _professionalNameController, hint: 'Nombre'),
              const SizedBox(height: OasisSpacing.sm),
              OasisTextField(
                  controller: _professionalRoleController, hint: 'Rol'),
              const SizedBox(height: OasisSpacing.sm),
              OasisTextField(
                  controller: _professionalPhoneController, hint: 'Teléfono'),
              const SizedBox(height: OasisSpacing.sm),
              OasisButton(
                label: 'Agregar profesional',
                leading: AppIcons.support,
                onPressed: () async {
                  await ref
                      .read(safetyPlanControllerProvider.notifier)
                      .addProfessional(
                        name: _professionalNameController.text,
                        role: _professionalRoleController.text,
                        phone: _professionalPhoneController.text,
                      );
                  _professionalNameController.clear();
                  _professionalRoleController.clear();
                  _professionalPhoneController.clear();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        HopeCard(
          title: 'Paso 6 · Motivos para seguir',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final entry in plan.reasonsToStay.asMap().entries) ...[
                _stringTile(
                  entry.value,
                  onRemove: () => ref
                      .read(safetyPlanControllerProvider.notifier)
                      .removeReason(entry.key),
                ),
                const SizedBox(height: OasisSpacing.sm),
              ],
              ReflectionCard(
                title: 'Agregar un motivo',
                controller: _reasonController,
                hint: 'Escribe algo que te sostenga hoy...',
                minLines: 2,
              ),
              const SizedBox(height: OasisSpacing.sm),
              OasisButton(
                label: 'Guardar motivo',
                leading: AppIcons.hope,
                onPressed: () async {
                  await ref
                      .read(safetyPlanControllerProvider.notifier)
                      .addReason(_reasonController.text);
                  _reasonController.clear();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: OasisSpacing.xxxl),
      ],
    );
  }

  Widget _buildCrisisContent(BuildContext context, SafetyPlan plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SafetySection(
          title: 'Respirar',
          subtitle: 'Inhala 4 segundos y exhala 6 segundos durante 2 minutos.',
          level: 3,
          child: Row(
            children: [
              const Icon(AppIcons.breathing, size: 28),
              const SizedBox(width: OasisSpacing.sm),
              Expanded(
                child: Text(
                  'Pon una mano en el pecho y otra en el abdomen. Tu única tarea ahora es respirar.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        HopeCard(
          title: 'Mis motivos',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final reason in plan.reasonsToStay.take(5)) ...[
                Text('• $reason', style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: OasisSpacing.xs),
              ],
            ],
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        SafetySection(
          title: 'Mis contactos',
          subtitle: 'Llama o envía un mensaje breve.',
          child: Column(
            children: [
              for (final contact in plan.contacts.take(3)) ...[
                _contactTile(contact),
                const SizedBox(height: OasisSpacing.sm),
              ],
            ],
          ),
        ),
        const SizedBox(height: OasisSpacing.md),
        SafetySection(
          title: 'Mi plan',
          subtitle: 'Sigue estos pasos simples ahora.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  '1. Señales: ${plan.warningSigns.isNotEmpty ? plan.warningSigns.first : 'Respira y pide apoyo.'}'),
              const SizedBox(height: OasisSpacing.sm),
              Text(
                  '2. Acción: ${plan.selfActions.isNotEmpty ? plan.selfActions.first : 'Bebe agua y siéntate en un lugar seguro.'}'),
              const SizedBox(height: OasisSpacing.sm),
              Text(
                  '3. Lugar: ${plan.safePlaces.isNotEmpty ? plan.safePlaces.first : 'Busca un espacio silencioso.'}'),
            ],
          ),
        ),
        const SizedBox(height: OasisSpacing.xxxl),
      ],
    );
  }

  Widget _editableStringSection({
    required List<String> items,
    required TextEditingController controller,
    required String hint,
    required VoidCallback onAdd,
    required ValueChanged<int> onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in items.asMap().entries) ...[
          _stringTile(entry.value, onRemove: () => onRemove(entry.key)),
          const SizedBox(height: OasisSpacing.sm),
        ],
        Row(
          children: [
            Expanded(child: OasisTextField(controller: controller, hint: hint)),
            const SizedBox(width: OasisSpacing.sm),
            OasisButton(
                label: 'Agregar', leading: AppIcons.add, onPressed: onAdd),
          ],
        ),
      ],
    );
  }

  Widget _stringTile(String value, {required VoidCallback onRemove}) {
    return OasisGlassCard(
      padding: const EdgeInsets.all(OasisSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(value)),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(AppIcons.delete),
          ),
        ],
      ),
    );
  }

  Widget _contactTile(SafetyContact contact) {
    return OasisGlassCard(
      padding: const EdgeInsets.all(OasisSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${contact.name} · ${contact.relationship}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: () => ref
                    .read(safetyPlanControllerProvider.notifier)
                    .removeContact(contact.id),
                icon: const Icon(AppIcons.delete),
              ),
            ],
          ),
          Text(contact.phone),
          const SizedBox(height: OasisSpacing.xs),
          Text(contact.quickMessage),
        ],
      ),
    );
  }

  Widget _professionalTile(SafetyProfessional professional) {
    return OasisGlassCard(
      padding: const EdgeInsets.all(OasisSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(AppIcons.support),
          const SizedBox(width: OasisSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(professional.name,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: OasisSpacing.xs),
                Text('${professional.role} · ${professional.phone}'),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ref
                .read(safetyPlanControllerProvider.notifier)
                .removeProfessional(professional.id),
            icon: const Icon(AppIcons.delete),
          ),
        ],
      ),
    );
  }

  Widget _crisisWrapper(Widget child) {
    final theme = Theme.of(context);
    final highContrastTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        surface: const Color(0xFF231C1D),
        onSurface: const Color(0xFFFFF5EA),
        primary: const Color(0xFFF3D5B6),
        onPrimary: const Color(0xFF261B14),
      ),
      textTheme: theme.textTheme.apply(
        bodyColor: const Color(0xFFFFF5EA),
        displayColor: const Color(0xFFFFF5EA),
      ),
    );

    return Theme(
      data: highContrastTheme,
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1.18)),
        child: child,
      ),
    );
  }

  void _exitSafetyPlan(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(RouteConstants.home);
  }
}
