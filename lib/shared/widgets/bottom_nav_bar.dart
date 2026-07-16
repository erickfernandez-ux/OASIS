import 'package:flutter/material.dart';
import '../../core/theme/icons/app_icons.dart';
import '../../core/theme/theme_extensions.dart';

/// Bottom navigation bar with 5 main destinations.
/// Labels always visible for accessibility.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: colors.component.navBarBackground,
      selectedItemColor: colors.component.navBarSelected,
      unselectedItemColor: colors.component.navBarUnselected,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      elevation: 0,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(AppIcons.home),
          activeIcon: Icon(AppIcons.homeFilled),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.agenda),
          activeIcon: Icon(AppIcons.agendaFilled),
          label: 'Agenda',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.journal),
          activeIcon: Icon(AppIcons.journalFilled),
          label: 'Diario',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.wellbeing),
          activeIcon: Icon(AppIcons.wellbeingFilled),
          label: 'Bienestar',
        ),
        BottomNavigationBarItem(
          icon: Icon(AppIcons.settings),
          activeIcon: Icon(AppIcons.settingsFilled),
          label: 'Ajustes',
        ),
      ],
    );
  }
}
