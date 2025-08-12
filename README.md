# Tic Tac Toe

A classic tic-tac-toe game built with Flutter, featuring a clean modern UI and player vs player gameplay.

## Features

- 🎮 **Player vs Player** - Two players take turns (X and O)
- 🏆 **Score Tracking** - Keeps track of wins for both players
- 🎯 **Win Detection** - Automatically detects wins, draws, and game over states
- 🔄 **Game Reset** - Easy "New Game" button to start fresh
- 📱 **Responsive Design** - Works on different screen sizes
- 🎨 **Modern UI** - Clean Material Design 3 interface

## How to Play

1. Two players take turns placing their symbols (X and O) on a 3x3 grid
2. The first player to get three of their symbols in a row (horizontally, vertically, or diagonally) wins
3. If all squares are filled without a winner, the game is a draw
4. Use the "New Game" button to reset the board and start again

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- A code editor (VS Code, Android Studio, etc.)

### Running the App

1. Clone or download this project
2. Open a terminal in the project directory
3. Get dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Building for Release

To build for Android:
```bash
flutter build apk
```

To build for iOS:
```bash
flutter build ios
```

## Project Structure

```
lib/
├── main.dart           # Main app entry point and game logic
└── ...
```

## Technical Details

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Built-in StatefulWidget
- **UI**: Material Design 3
- **Target Platforms**: Android, iOS, Web, Desktop

## Game Logic

The game implements classic tic-tac-toe rules:
- 3x3 grid with 9 playable squares
- Players alternate turns
- Win conditions: 3 in a row (horizontal, vertical, or diagonal)
- Draw condition: All squares filled with no winner

## Contributing

Feel free to fork this project and submit pull requests for improvements!

## License

This project is open source and available under the MIT License.
