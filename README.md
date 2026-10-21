# Just Game Engine Site

Official website for [Just Game Engine](https://github.com/just-unknown-dev/just-game-engine): a Flutter game engine, its [level editor](https://github.com/just-unknown-dev/just-game-engine-editor) and the [`just` CLI](https://github.com/just-unknown-dev/just-game-engine-cli).

**Live site:** [engine.justunknown.com](https://engine.justunknown.com)

## Features

- **Home** (`/`): the 2.0 preview, showcase screenshots, the toolkit, what's new, subsystems and getting started
- **Features** (`/features`): every engine area, filterable by category
- **Editor** (`/editor`): tour, features, setup and shortcuts for `just_game_engine_editor`
- **CLI** (`/cli`): the `just` commands, how they keep a project safe, flags and exit codes
- **Docs** (`/docs/<page>`): 29 guide pages written for 2.0, with search and an "On this page" outline
- **Roadmap** (`/roadmap`): shipped, in-progress and next work, built from the changelogs
- Light and dark themes; the choice is saved per visitor

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
    │   ├── constants/      # Site content: versions and links, features, roadmap
    │   │   └── docs/       # One file per docs group, plus the index
    │   ├── services/       # Remote config
    │   ├── theme/          # Palettes (light/dark), text styles, theme cubit
    │   ├── utils/          # Responsive helpers, link opening
    │   └── widgets/        # Nav bar, footer, cards, code blocks, Markdown view
    ├── modules/
    │   ├── home/
    │   ├── features/
    │   ├── editor/
    │   ├── cli/
    │   ├── docs/
    │   └── roadmap/
    └── routes/             # Auto Route configuration (run build_runner after edits)
```

## Updating content

- **Versions and links**: `lib/app/core/constants/site.dart`. Every page reads them from there.
- **Docs**: `lib/app/core/constants/docs/`. Each page is a `DocPage` whose body uses the small Markdown subset documented in `doc_models.dart`. Add a page to its group's list; `docs_index.dart` orders the groups, and `test/app/core/constants/docs_index_test.dart` checks that every internal link points at a real page.
- **Features and roadmap**: `features_data.dart` and `roadmap_data.dart` in the same folder.
- **Screenshots**: `assets/screenshots/`, as WebP (about 1600 px wide).
- **Routes**: after changing `lib/app/routes/app_router.dart`, run `dart run build_runner build --delete-conflicting-outputs`.

## Links

- [Just Game Engine (pub.dev)](https://pub.dev/packages/just_game_engine)
- [GitHub](https://github.com/just-unknown-dev/just-game-engine)
- [Discord](https://discord.gg/VXFxVj4Y)
- [justunknown.com](https://justunknown.com)