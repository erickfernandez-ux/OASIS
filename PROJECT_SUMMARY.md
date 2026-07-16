# OASIS Project - Sprint 1 & 2 Complete

## Quick Start

1. Extract the ZIP file
2. Open the `oasis` folder in VS Code
3. Run `flutter pub get` in terminal
4. Run `flutter run` to start the app

## Project Structure

```
oasis/
├── pubspec.yaml              # Dependencies (Riverpod, GoRouter, Supabase, Google Fonts)
├── lib/
│   ├── main.dart             # Entry point with Supabase init + Riverpod
│   ├── core/
│   │   ├── config/           # App config, GoRouter with StatefulShellRoute
│   │   ├── constants/        # App constants, route constants
│   │   ├── errors/           # ServerException, CacheException
│   │   ├── services/         # SupabaseService wrapper
│   │   ├── theme/            # Complete Design System
│   │   │   ├── colors/       # Primitive, Semantic, Component, AppColors
│   │   │   ├── typography/   # Inter font system (Display, Headline, Title, Body, Label, Caption)
│   │   │   ├── spacing/      # xs(4), sm(8), md(16), lg(24), xl(32), xxl(48)
│   │   │   ├── radius/       # 4, 8, 12, 16, 24, 32 (pill)
│   │   │   ├── elevation/    # Card, Elevated, Modal, Dropdown shadows
│   │   │   ├── animations/   # Fast(150ms), Normal(250ms), Slow(350ms) + curves
│   │   │   ├── icons/        # Centralized icon system with semantic sizes
│   │   │   ├── app_theme.dart # Light/Dark/HighContrast themes
│   │   │   └── theme_extensions.dart # BuildContext helpers
│   │   └── utils/            # Extension utilities
│   ├── shared/
│   │   └── widgets/          # 16 reusable components
│   │       ├── primary_button.dart
│   │       ├── secondary_button.dart
│   │       ├── app_card.dart
│   │       ├── app_text_field.dart
│   │       ├── search_field.dart
│   │       ├── app_fab.dart
│   │       ├── bottom_nav_bar.dart
│   │       ├── top_app_bar.dart
│   │       ├── section_title.dart
│   │       ├── empty_state.dart
│   │       ├── app_divider.dart
│   │       ├── tag_chip.dart
│   │       ├── status_chip.dart
│   │       ├── loading_indicator.dart
│   │       └── app_scaffold.dart
│   └── features/
│       ├── home/
│       ├── agenda/
│       ├── notes/
│       ├── wellbeing/
│       └── settings/
│           ├── data/         # .gitkeep
│           ├── domain/       # .gitkeep
│           └── presentation/
│               ├── screens/  # Empty screen
│               └── widgets/  # .gitkeep
├── assets/
│   ├── fonts/
│   ├── icons/
│   └── images/
└── test/
    ├── unit/
    └── widget/
```

## Architecture Decisions

- **Clean Architecture**: data/domain/presentation layers per feature
- **ThemeExtension**: All design tokens integrated into Flutter's ThemeData
- **StatefulShellRoute**: Preserves tab state when switching between 5 screens
- **No hardcoded values**: Everything comes from the Design System

## Design System Tokens

| Category | Tokens |
|----------|--------|
| Colors | Primary, Secondary, Accent, Success, Warning, Error, Info, Background, Surface, Outline, Divider, TextPrimary, TextSecondary, TextDisabled |
| Typography | DisplayLarge, DisplayMedium, Headline, Title, Body, Label, Caption |
| Spacing | xs(4), sm(8), md(16), lg(24), xl(32), xxl(48) |
| Radius | small(4), medium(8), large(12), xl(16), xxl(24), pill(32) |
| Elevation | card, elevated, modal, dropdown |
| Animations | fast(150ms), normal(250ms), slow(350ms) |
| Icons | All centralized with semantic sizes |

## Dependencies

| Package | Purpose |
|---------|---------|
| flutter_riverpod | State management |
| go_router | Declarative navigation |
| supabase_flutter | Backend (Auth, DB, Storage, Realtime) |
| google_fonts | Inter font loading |
| intl | Internationalization |

## Next Steps (Sprint 3)

1. Implement Auth flow with Supabase
2. Create first feature models (Agenda or Notes)
3. Add form validation system
4. Implement theme switching (light/dark/manual)
5. Add golden tests for components
