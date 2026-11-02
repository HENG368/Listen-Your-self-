# Listen Your Self

Listen Your Self is a Flutter project for a music-focused app. The project
currently contains the initial Flutter setup and the app logo; the main
application screens are still being built.

## What I wrote to create the app

The project was started as a Flutter application named `listen_your_self`.
The initial setup includes:

- Flutter and Dart project configuration in [`pubspec.yaml`](./pubspec.yaml)
- Material Design support
- Cupertino icons through `cupertino_icons`
- Flutter lint rules through `flutter_lints`
- Android launcher icon generation through `flutter_launcher_icons`
- A custom music logo at [`assets/logomusic.png`](./assets/logomusic.png)
- A note to use a `LinearGradient` for mixing colors in the interface

The logo is configured as the Android launcher icon with a black adaptive
background:

```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/logomusic.png"
  adaptive_icon_background: "#000000"
  adaptive_icon_foreground: "assets/logomusic.png"
```

## Project structure

```text
listen_your_self/
├── assets/
│   └── logomusic.png
├── lib/
│   ├── MusicPanel.dart
│   ├── albumPage.dart
│   └── mainPage.dart
├── test/
├── android/
├── ios/
├── linux/
├── macos/
├── web/
└── windows/
```

The files in `lib/` are reserved for the music panel, album page, and main
page. They are currently empty, so no playback, navigation, or completed
screen behavior has been implemented yet.

## Requirements

- Flutter SDK
- Dart SDK compatible with `^3.13.5`

## Run the project

Install the dependencies and start the Flutter application:

```bash
flutter pub get
flutter run
```

To generate the configured Android launcher icon:

```bash
dart run flutter_launcher_icons
```

## Development notes

The planned visual direction includes mixing colors with Flutter's
`LinearGradient`. Add the application entry point and screen widgets under
`lib/` as the app is developed.
