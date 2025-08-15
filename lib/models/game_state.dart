import '../constants/game_constants.dart';

/// Manages the state of a tic-tac-toe game
class GameState {
  List<String> board = List.filled(GameConstants.boardSize, GameConstants.emptyCell);
  bool isPlayerTurn = true;
  bool playerGoesFirst = true;
  String gameStatus = '';
  int playerScore = 0;
  int computerScore = 0;
  int tiesScore = 0;
  int countdownSeconds = 0;
  bool isCountingDown = false;
  List<int>? winningCombination;
  bool showWinningLine = false;
  
  // Animation states
  List<bool> cellAnimating = List.filled(GameConstants.boardSize, false);
  bool isAnimating = false;

  /// Whether the game is currently active and can accept moves
  bool get isGameActive => gameStatus.isEmpty && !isCountingDown && !isAnimating;
  
  /// Whether the player has won the current game
  bool get isPlayerWin => gameStatus.contains(UIConstants.playerWinMessage);
  
  /// Whether the computer has won the current game
  bool get isComputerWin => gameStatus.contains(UIConstants.computerWinMessage);
  
  /// Whether the current game is a draw
  bool get isDraw => gameStatus.contains(UIConstants.drawMessage);
  
  /// Resets the game state for a new game
  void reset() {
    board = List.filled(GameConstants.boardSize, GameConstants.emptyCell);
    gameStatus = '';
    isCountingDown = false;
    countdownSeconds = 0;
    winningCombination = null;
    showWinningLine = false;
    cellAnimating = List.filled(GameConstants.boardSize, false);
    isAnimating = false;
  }
  
  /// Switches the current turn between player and computer
  void switchTurns() {
    isPlayerTurn = !isPlayerTurn;
  }
  
  /// Updates who goes first for the next game
  void updateFirstPlayer() {
    playerGoesFirst = !playerGoesFirst;
    isPlayerTurn = playerGoesFirst;
  }
  
  /// Makes a move on the board
  void makeMove(int index, String symbol) {
    if (index >= 0 && index < board.length && board[index] == GameConstants.emptyCell) {
      board[index] = symbol;
    }
  }
  
  /// Checks if a cell is empty
  bool isCellEmpty(int index) {
    return index >= 0 && index < board.length && board[index] == GameConstants.emptyCell;
  }
}
