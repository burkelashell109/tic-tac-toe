import 'package:flutter/material.dart';

/// UI-related constants for the tic-tac-toe game
class UIConstants {
  // Colors
  static const Color playerColor = Colors.blue;
  static const Color computerColor = Colors.red;
  
  // Dimensions
  static const double boardMaxSize = 350.0;
  static const double cellPadding = 8.0;
  static const double winLineWidth = 8.0;
  
  // Timing
  static const Duration computerThinkingDelay = Duration(milliseconds: 500);
  static const Duration winningLineDelay = Duration(milliseconds: 500);
  static const Duration countdownInterval = Duration(seconds: 1);
  static const int autoRestartSeconds = 3;
  
  // Animation
  static const Duration cellAnimationDuration = Duration(milliseconds: 400);
  static const Duration turnTransitionDuration = Duration(milliseconds: 500);
  static const Duration pulseAnimationDuration = Duration(seconds: 2);
  static const Duration celebrationGlowDuration = Duration(milliseconds: 1500);
  static const Duration celebrationParticleDuration = Duration(milliseconds: 2000);
  
  // Text scaling
  static const double baseTextScale = 1.5;
  static const double countdownTextScale = 0.9;
  static const double scoreTextScale = 2.0;
  static const double scoreLabelTextScale = 1.0;
  
  // Status messages
  static const String playerTurnMessage = "Your Turn";
  static const String computerTurnMessage = "Computer's Turn";
  static const String playerWinMessage = 'You win!';
  static const String computerWinMessage = 'Computer wins!';
  static const String drawMessage = 'It\'s a draw!';
}

/// Game logic constants
class GameConstants {
  // Players
  static const String playerSymbol = 'X';
  static const String computerSymbol = 'O';
  static const String emptyCell = '';
  
  // Board
  static const int boardSize = 9;
  static const int gridSize = 3;
  
  // Winning combinations
  static const List<List<int>> winningCombinations = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
    [0, 4, 8], [2, 4, 6], // Diagonals
  ];
  
  // Minimax scores
  static const int winScore = 10;
  static const int loseScore = -10;
  static const int drawScore = 0;
}
