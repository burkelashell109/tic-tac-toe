import 'dart:async';
import 'dart:math';
import '../constants/game_constants.dart';
import '../models/game_state.dart';
import '../services/game_logic.dart';

/// Controls the mini tic-tac-toe game for the splash screen
class SplashController {
  late GameState _state;
  Timer? _moveTimer;
  final Function(GameState) _onStateChanged;
  final Function() _onGameComplete;
  
  SplashController({
    required Function(GameState) onStateChanged,
    required Function() onGameComplete,
  }) : _onStateChanged = onStateChanged,
       _onGameComplete = onGameComplete {
    _initializeGame();
  }
  
  /// Initialize the mini-game
  void _initializeGame() {
    _state = GameState();
    _state.isPlayerTurn = true; // Start with X (player symbol)
    _onStateChanged(_state);
    
    // Start the game after a brief delay
    Timer(const Duration(milliseconds: 500), _startGame);
  }
  
  /// Start playing the mini-game automatically
  void _startGame() {
    _makeNextMove();
  }
  
  /// Make the next move in the mini-game
  void _makeNextMove() {
    if (!_state.isGameActive) {
      // Game is over, wait a moment then signal completion
      Timer(const Duration(milliseconds: 500), () {
        _onGameComplete();
      });
      return;
    }
    
    // Get available moves
    List<int> availableMoves = [];
    for (int i = 0; i < 9; i++) {
      if (_state.board[i] == GameConstants.emptyCell) {
        availableMoves.add(i);
      }
    }
    
    if (availableMoves.isEmpty) {
      _onGameComplete();
      return;
    }
    
    // Choose a random move (or sometimes make strategic moves for variety)
    int moveIndex;
    if (Random().nextBool() && availableMoves.length > 3) {
      // 50% chance to make a strategic move when board isn't too full
      moveIndex = _getStrategicMove(availableMoves);
    } else {
      // Random move
      moveIndex = availableMoves[Random().nextInt(availableMoves.length)];
    }
    
    // Make the move
    String currentSymbol = _state.isPlayerTurn ? GameConstants.playerSymbol : GameConstants.computerSymbol;
    _state.board[moveIndex] = currentSymbol;
    
    // Check for win or draw
    if (GameLogic.checkWinner(_state.board)) {
      _state.gameStatus = _state.isPlayerTurn ? UIConstants.playerWinMessage : UIConstants.computerWinMessage;
      _state.winningCombination = GameLogic.getWinningCombination(_state.board);
    } else if (GameLogic.isBoardFull(_state.board)) {
      _state.gameStatus = UIConstants.drawMessage;
    } else {
      // Switch turns
      _state.isPlayerTurn = !_state.isPlayerTurn;
    }
    
    _onStateChanged(_state);
    
    // Schedule next move
    if (_state.isGameActive) {
      _moveTimer = Timer(UIConstants.splashMoveDuration, _makeNextMove);
    } else {
      // Game finished, wait then complete
      Timer(const Duration(milliseconds: 500), () {
        _onGameComplete();
      });
    }
  }
  
  /// Get a strategic move (sometimes win, sometimes block, sometimes random)
  int _getStrategicMove(List<int> availableMoves) {
    String currentSymbol = _state.isPlayerTurn ? GameConstants.playerSymbol : GameConstants.computerSymbol;
    String opponentSymbol = _state.isPlayerTurn ? GameConstants.computerSymbol : GameConstants.playerSymbol;
    
    // 30% chance to try to win
    if (Random().nextDouble() < 0.3) {
      for (int move in availableMoves) {
        List<String> testBoard = List.from(_state.board);
        testBoard[move] = currentSymbol;
        if (GameLogic.checkWinner(testBoard)) {
          return move;
        }
      }
    }
    
    // 30% chance to try to block opponent
    if (Random().nextDouble() < 0.3) {
      for (int move in availableMoves) {
        List<String> testBoard = List.from(_state.board);
        testBoard[move] = opponentSymbol;
        if (GameLogic.checkWinner(testBoard)) {
          return move;
        }
      }
    }
    
    // Otherwise random move
    return availableMoves[Random().nextInt(availableMoves.length)];
  }
  
  /// Get current game state
  GameState get state => _state;
  
  /// Dispose resources
  void dispose() {
    _moveTimer?.cancel();
  }
}
