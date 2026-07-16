import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/agenda/presentation/screens/agenda_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/notes/domain/entities/note.dart';
import '../../features/notes/presentation/screens/notes_editor_screen.dart';
import '../../features/notes/presentation/screens/notes_screen.dart';
import '../../features/journal/presentation/screens/journal_screen.dart';
import '../../features/safety_plan/presentation/screens/safety_plan_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/rituals/presentation/screens/rituals_screen.dart';
import '../../features/wellbeing/presentation/screens/wellbeing_screen.dart';
import '../../core/design/animations/motion_spec.dart';
import '../../core/design/transitions/oasis_page_transition.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../constants/route_constants.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GlobalKey<NavigatorState> _shellNavigatorHomeKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellHome');
final GlobalKey<NavigatorState> _shellNavigatorAgendaKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellAgenda');
final GlobalKey<NavigatorState> _shellNavigatorJournalKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellJournal');
final GlobalKey<NavigatorState> _shellNavigatorWellbeingKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellWellbeing');
final GlobalKey<NavigatorState> _shellNavigatorSettingsKey =
    GlobalKey<NavigatorState>(debugLabel: 'shellSettings');

/// Global router provider for Riverpod access.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteConstants.home,
    routes: [
      GoRoute(
        path: RouteConstants.notes,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const NotesScreen(),
          transitionDuration: MotionSpec.page,
          reverseTransitionDuration: MotionSpec.pageReverse,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return OasisPageTransition.build(
                context, animation, secondaryAnimation, child);
          },
        ),
        routes: [
          GoRoute(
            path: 'editor',
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: NoteEditorScreen(note: state.extra as Note?),
              transitionDuration: MotionSpec.page,
              reverseTransitionDuration: MotionSpec.pageReverse,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return OasisPageTransition.build(
                    context, animation, secondaryAnimation, child);
              },
            ),
          ),
        ],
      ),
      GoRoute(
        path: RouteConstants.safetyPlan,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SafetyPlanScreen(),
          transitionDuration: MotionSpec.page,
          reverseTransitionDuration: MotionSpec.pageReverse,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return OasisPageTransition.build(
                context, animation, secondaryAnimation, child);
          },
        ),
      ),
      GoRoute(
        path: RouteConstants.rituals,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const RitualsScreen(),
          transitionDuration: MotionSpec.page,
          reverseTransitionDuration: MotionSpec.pageReverse,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return OasisPageTransition.build(
                context, animation, secondaryAnimation, child);
          },
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: RouteConstants.home,
                pageBuilder: (context, state) => CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: const HomeScreen(),
                  transitionDuration: MotionSpec.page,
                  reverseTransitionDuration: MotionSpec.pageReverse,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return OasisPageTransition.build(
                        context, animation, secondaryAnimation, child);
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAgendaKey,
            routes: [
              GoRoute(
                path: RouteConstants.agenda,
                pageBuilder: (context, state) => CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: const AgendaScreen(),
                  transitionDuration: MotionSpec.page,
                  reverseTransitionDuration: MotionSpec.pageReverse,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return OasisPageTransition.build(
                        context, animation, secondaryAnimation, child);
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorJournalKey,
            routes: [
              GoRoute(
                path: RouteConstants.journal,
                pageBuilder: (context, state) => CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: const JournalScreen(),
                  transitionDuration: MotionSpec.page,
                  reverseTransitionDuration: MotionSpec.pageReverse,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return OasisPageTransition.build(
                        context, animation, secondaryAnimation, child);
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorWellbeingKey,
            routes: [
              GoRoute(
                path: RouteConstants.wellbeing,
                pageBuilder: (context, state) => CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: const WellbeingScreen(),
                  transitionDuration: MotionSpec.page,
                  reverseTransitionDuration: MotionSpec.pageReverse,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return OasisPageTransition.build(
                        context, animation, secondaryAnimation, child);
                  },
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: RouteConstants.settings,
                pageBuilder: (context, state) => CustomTransitionPage<void>(
                  key: state.pageKey,
                  child: const SettingsScreen(),
                  transitionDuration: MotionSpec.page,
                  reverseTransitionDuration: MotionSpec.pageReverse,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return OasisPageTransition.build(
                        context, animation, secondaryAnimation, child);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
