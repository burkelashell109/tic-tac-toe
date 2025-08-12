# Tic-Tac-Toe Flutter Project Instructions

<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

## Project Overview
This is a Flutter project for a classic tic-tac-toe game with the following features:
- Clean, modern UI design
- Player vs Player gameplay
- Game state management
- Win/draw detection
- Game reset functionality

## Code Style Guidelines
- Use Flutter best practices and Material Design principles
- Implement proper state management (setState for simple cases, or Provider/Riverpod for complex state)
- Write clean, readable code with proper documentation
- Use meaningful variable and function names
- Follow Dart naming conventions (camelCase for variables/functions, PascalCase for classes)

## Project Structure
- `lib/main.dart` - App entry point and main game UI
- `lib/models/` - Game models and data structures
- `lib/widgets/` - Reusable UI components
- `lib/utils/` - Utility functions and game logic
- `lib/screens/` - Different game screens (if needed)

## Game Requirements
- 3x3 grid layout
- Two players: X and O
- Turn-based gameplay
- Win condition detection (rows, columns, diagonals)
- Draw condition detection
- Score tracking
- Reset game functionality
- Responsive design for different screen sizes

## Technical Notes
- Use StatefulWidget for game state management
- Implement clean separation between UI and game logic
- Add proper error handling and edge cases
- Consider adding animations for better UX
- Ensure accessibility features are included
