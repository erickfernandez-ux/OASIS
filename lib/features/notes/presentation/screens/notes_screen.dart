import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/icons/app_icons.dart';
import '../../../../core/theme/spacing/app_spacing.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../core/theme/typography/app_typography.dart';
import '../../../../core/design/design_system.dart';
import '../../../../core/design/design_system.dart' as od;
import '../../../../shared/providers/app_launch_intents.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/section_title.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_controller.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _searchController = TextEditingController();
  bool _launchIntentHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _launchIntentHandled) return;
      final intent = ref.read(appLaunchIntentProvider);
      if (intent == AppLaunchIntent.openNotesNewNote) {
        _launchIntentHandled = true;
        ref.read(appLaunchIntentProvider.notifier).state = null;
        _openEditor(context, null);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final spacing = context.appSpacing;
    final typography = context.appTypography;
    final notesState = ref.watch(notesControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva nota'),
      ),
      body: notesState.when(
        data: (state) =>
            _buildContent(context, state, colors, spacing, typography),
        loading: () => _buildNotesScaffoldState(
          const Center(
            child: LoadingIndicator(type: LoadingType.breathingPaper),
          ),
        ),
        error: (error, _) => _buildNotesScaffoldState(
          Center(child: Text(error.toString())),
        ),
      ),
    );
  }

  Widget _buildNotesScaffoldState(Widget child) {
    return OasisWatercolorBackground(
      accent: OasisSurfaces.notesAccent,
      backgroundAssetOverride: 'assets/backgrounds/papel.webp',
      child: SafeArea(child: child),
    );
  }

  Widget _buildContent(
    BuildContext context,
    NotesState state,
    AppColors colors,
    AppSpacing spacing,
    AppTypography typography,
  ) {
    final notes = state.filteredNotes;

    return OasisWatercolorBackground(
      accent: OasisSurfaces.notesAccent,
      backgroundAssetOverride: 'assets/backgrounds/papel.webp',
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    spacing.lg, spacing.lg, spacing.lg, spacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Volver',
                          onPressed: () => _closeNotes(context),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const Expanded(
                          child: Hero(
                            tag: OasisHeroTags.notesHeader,
                            child: SectionTitle(
                              title: 'Notas',
                              subtitle: 'Captura ideas con calma y claridad.',
                              showDivider: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.xs),
                    TextButton.icon(
                      onPressed: () => _closeNotes(context),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Cerrar y regresar'),
                    ),
                    SizedBox(height: spacing.sm),
                    od.OasisSearchField(
                      controller: _searchController,
                      hint: 'Buscar notas',
                      onChanged: (value) => ref
                          .read(notesControllerProvider.notifier)
                          .updateSearchQuery(value),
                    ),
                    SizedBox(height: spacing.sm),
                    Wrap(
                      spacing: spacing.sm,
                      children: [
                        od.OasisFilterChip(
                          label: 'Más recientes',
                          selected: state.sortBy == NotesSort.newest,
                          onTap: () => ref
                              .read(notesControllerProvider.notifier)
                              .updateSort(NotesSort.newest),
                        ),
                        od.OasisFilterChip(
                          label: 'Favoritas',
                          selected: state.sortBy == NotesSort.favorites,
                          onTap: () => ref
                              .read(notesControllerProvider.notifier)
                              .updateSort(NotesSort.favorites),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (notes.isEmpty)
              const SliverFillRemaining(
                child: OasisEmptyState(
                  icon: AppIcons.notes,
                  title: 'Las ideas llegarán.',
                  description: 'Aquí tendrán un lugar.',
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final note = notes[index];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                          spacing.lg, 0, spacing.lg, spacing.sm),
                      child: OasisStagger(
                        index: index,
                        child: Hero(
                          tag: OasisHeroTags.noteCard(note.id),
                          child: Material(
                            type: MaterialType.transparency,
                            child: OasisCard(
                              onTap: () => _openEditor(context, note),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                note.title
                                                            ?.trim()
                                                            .isNotEmpty ==
                                                        true
                                                    ? note.title!
                                                    : 'Sin título',
                                                style: typography.title.copyWith(
                                                    color: colors
                                                        .semantic.textPrimary),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (note.isFavorite)
                                              Icon(Icons.star_rounded,
                                                  color: colors.semantic.warning,
                                                  size: 18),
                                          ],
                                        ),
                                        SizedBox(height: spacing.xs),
                                        Text(
                                          _excerpt(note.content),
                                          style: typography.body.copyWith(
                                              color: colors
                                                  .semantic.textSecondary),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: spacing.sm),
                                        Text(
                                          DateFormat('d MMM, yyyy', 'es')
                                              .format(note.updatedAt),
                                          style: typography.caption.copyWith(
                                              color: colors
                                                  .semantic.textDisabled),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: spacing.sm),
                                  Column(
                                    children: [
                                      IconButton(
                                        onPressed: () => ref
                                            .read(notesControllerProvider
                                                .notifier)
                                            .toggleFavorite(note.id),
                                        icon: Icon(
                                            note.isFavorite
                                                ? Icons.star_rounded
                                                : Icons.star_border_rounded,
                                            color: note.isFavorite
                                                ? colors.semantic.warning
                                                : colors
                                                    .semantic.textSecondary),
                                      ),
                                      IconButton(
                                        onPressed: () => ref
                                            .read(notesControllerProvider
                                                .notifier)
                                            .deleteNote(note.id),
                                        icon: Icon(AppIcons.delete,
                                            color: colors
                                                .semantic.textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: notes.length,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _closeNotes(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go(RouteConstants.home);
  }

  String _excerpt(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      return 'Sin contenido';
    }
    if (trimmed.length <= 120) {
      return trimmed;
    }
    return '${trimmed.substring(0, 117)}...';
  }

  void _openEditor(BuildContext context, Note? note) {
    context.push(RouteConstants.notesEditor, extra: note);
  }
}
