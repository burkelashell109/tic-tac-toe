import '../constants/game_constants.dart';

/// Helper class for minimax algorithm results
class MinimaxResult {
  final int move;
  final int score;
  
  const MinimaxResult(this.move, this.score);
}

/// Contains all game logic for tic-tac-toe
class GameLogic {
  /// Checks if there's a winner on the board
  static bool checkWinner(List<String> board) {
    return getWinningCombination(board) != null;
  }
  
  /// Gets the winning combination if there is one
  static List<int>? getWinningCombination(List<String> board) {
    for (final combination in GameConstants.winningCombinations) {
      final String first = board[combination[0]];
      if (first != GameConstants.emptyCell &&
          first == board[combination[1]] &&
          first == board[combination[2]]) {
        return combination;
      }
    }
    return null;
  }
  
  /// Checks if the board is full
  static bool isBoardFull(List<String> board) {
    return !board.contains(GameConstants.emptyCell);
  }
  
  /// Gets the best move for the computer using minimax algorithm
  static int getBestMove(List<String> board) {
    int bestMove = -1;
    int bestScore = -1000;
    
    for (int i = 0; i < board.length; i++) {
      if (board[i] == GameConstants.emptyCell) {
        board[i] = GameConstants.computerSymbol;
        int score = _minimax(board, 0, false, -1000, 1000).score;
        board[i] = GameConstants.emptyCell;
        
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    
    return bestMove;
  }
  
  /// Minimax algorithm with alpha-beta pruning
  static MinimaxResult _minimax(List<String> board, int depth, bool isMaximizing, int alpha, int beta) {
    // Terminal states
    if (checkWinner(board)) {
      final winner = _getWinner(board);
      if (winner == GameConstants.computerSymbol) {
        return MinimaxResult(-1, GameConstants.winScore - depth);
      } else {
        return MinimaxResult(-1, GameConstants.loseScore + depth);
      }
    }
    
    if (isBoardFull(board)) {
      return const MinimaxResult(-1, GameConstants.drawScore);
    }
    
    if (isMaximizing) {
      int maxScore = -1000;
      int bestMove = -1;
      
      for (int i = 0; i < board.length; i++) {
        if (board[i] == GameConstants.emptyCell) {
          board[i] = GameConstants.computerSymbol;
          int score = _minimax(board, depth + 1, false, alpha, beta).score;
          board[i] = GameConstants.emptyCell;
          
          if (score > maxScore) {
            maxScore = score;
            bestMove = i;
          }
          
          alpha = alpha > score ? alpha : score;
          if (beta <= alpha) break; // Alpha-beta pruning
        }
      }
      
      return MinimaxResult(bestMove, maxScore);
    } else {
      int minScore = 1000;
      int bestMove = -1;
      
      for (int i = 0; i < board.length; i++) {
        if (board[i] == GameConstants.emptyCell) {
          board[i] = GameConstants.playerSymbol;
          int score = _minimax(board, depth + 1, true, alpha, beta).score;
          board[i] = GameConstants.emptyCell;
          
          if (score < minScore) {
            minScore = score;
            bestMove = i;
          }
          
          beta = beta < score ? beta : score;
          if (beta <= alpha) break; // Alpha-beta pruning
        }
      }
      
      return MinimaxResult(bestMove, minScore);
    }
  }
  
  /// Gets the winner symbol from the board
  static String? _getWinner(List<String> board) {
    final winningCombo = getWinningCombination(board);
    if (winningCombo != null) {
      return board[winningCombo[0]];
    }
    return null;
  }
}
