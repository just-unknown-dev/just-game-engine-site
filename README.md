# Just Game Engine Site

Official website for [Just Game Engine](https://github.com/just-unknown-dev/just-game-engine) — a comprehensive 2D game engine built for Flutter.

**Live site:** [engine.justunknown.com](https://engine.justunknown.com)

## Features

- **Home** — Overview, feature highlights, and Flame comparison
- **Features** — Detailed breakdown of all 11 engine subsystems
- **Docs** — API documentation and getting started guide
- **Examples** — Interactive code examples
- **Roadmap** — Development timeline and planned features

## Tech Stack

- Flutter Web
- Firebase Hosting
- Firebase Remote Config
- Auto Route (navigation)
- Google Fonts

## Getting Started

### Prerequisites

- Flutter SDK 3.11.0+
- Firebase CLI

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/just-unknown-dev/just-game-engine-site.git
   cd just_game_engine_site
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure environment variables:
   ```bash
   cp .env.example .env
   ```
   Fill in your Firebase configuration values in `.env`.

4. Run the development server:
   ```bash
   flutter run -d chrome
   ```

## Deployment

Build and deploy to Firebase Hosting:

```bash
flutter build web --release
firebase deploy --only hosting
```

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
└── app/
    ├── core/
    │   ├── constants/      # Engine data (subsystems, examples, roadmap)
    │   ├── services/       # Remote config
    │   ├── theme/          # Colors, text styles, theme
    │   ├── utils/          # Responsive utilities
    │   └── widgets/        # Shared widgets (navbar, footer, scaffold)
    ├── modules/
    │   ├── home/
    │   ├── features/
    │   ├── docs/
    │   ├── examples/
    │   └── roadmap/
    └── routes/             # Auto Route configuration
```

## Links

- [Just Game Engine (pub.dev)](https://pub.dev/packages/just_game_engine)
- [GitHub](https://github.com/just-unknown-dev/just-game-engine)
- [Discord](https://discord.gg/AaAZayn3)
- [justunknown.com](https://justunknown.com)