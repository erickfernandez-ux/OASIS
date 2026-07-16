# OASIS

**Personal Operating System**

A Flutter application designed to help people organize their lives by reducing mental load.

## Features (Planned)

- Agenda
- Calendar
- Notes
- Mood Tracker
- Pomodoro
- Habits
- Medications
- Reminders
- Hydration

## Tech Stack

- **Frontend:** Flutter
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **Backend:** Supabase
- **Database:** PostgreSQL
- **Storage:** Supabase Storage

## Architecture

Clean Architecture with the following layers:

- `core/` — Shared infrastructure, theme, services
- `shared/` — Reusable widgets
- `features/` — Feature modules with data/domain/presentation layers

## Getting Started

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── core/
│   ├── config/         # App config, router
│   ├── constants/        # App constants, route constants
│   ├── errors/           # Exceptions
│   ├── theme/            # Design system tokens
│   │   ├── colors/       # Primitive, semantic, component colors
│   │   ├── typography/   # Inter font system
│   │   ├── spacing/      # Spacing tokens
│   │   ├── radius/       # Border radius tokens
│   │   ├── elevation/    # Shadow tokens
│   │   ├── animations/   # Animation tokens
│   │   └── icons/        # Centralized icon system
│   ├── utils/            # Extensions
│   └── services/         # Supabase service
├── shared/
│   └── widgets/          # Reusable UI components
└── features/
    ├── home/
    ├── agenda/
    ├── notes/
    ├── wellbeing/
    └── settings/
```

## Design System

The app uses a Japandi-inspired design system with:

- **Palette:** Nature-inspired colors (moss, clay, sand, stone)
- **Typography:** Inter with light weights and generous line height
- **Spacing:** Multiples of 4 (4, 8, 16, 24, 32, 48)
- **Radius:** Soft rounded corners (4, 8, 12, 16, 24, 32)
- **Elevation:** Diffuse, soft shadows
- **Animations:** Smooth curves (150ms, 250ms, 350ms)

## License

MIT
