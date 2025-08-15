import 'dart:async';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../services/game_logic.dart';
import '../services/animation_manager.dart';
import '../constants/game_constants.dart';

/// Controls the game flow and state management
class GameController {
  final GameState _state = GameState();
  Timer? _countdownTimer;
  late AnimationManager _animationManager;
  late Function() _onStateChanged; // Callback to notify UI of state changes
  
  GameState get state => _state;
  AnimationManager get animationManager => _animationManager;
  
  /// Initializes the game controller
  void initialize(AnimationManager animationManager, Function() onStateChanged) {
    _animationManager = animationManager;
    _onStateChanged = onStateChanged;
    
    // Trigger initial turn animation after the first frame
    Future.delayed(Duration.zero, () {
      _animationManager.animateTurnTransition(_state.isPlayerTurn);
      if (!_state.isPlayerTurn) {
        makeComputerMove();
      }
    });
  }
  
  /// Disposes resources
  void dispose() {
    _countdownTimer?.cancel();
  }
  
  /// Handles player move at the specified index
  Future<void> handlePlayerMove(int index) async {
    if (!_canPlayerMove(index)) return;

    // Make the move and trigger haptic feedback
    _state.makeMove(index, GameConstants.playerSymbol);
    HapticFeedback.lightImpact();
    _onStateChanged();
    
    // Animate the placement
    await _animationManager.animateSymbolPlacement(index);
    
    // Check game state after animation completes
    if (GameLogic.checkWinner(_state.board)) {
      _handlePlayerWin();
    } else if (GameLogic.isBoardFull(_state.board)) {
      _handleDraw();
    } else {
      _switchToComputerTurn();
      if (_state.isGameActive && !_state.isPlayerTurn) {
        makeComputerMove();
      }
    }
  }
  
  /// Makes a computer move
  Future<void> makeComputerMove() async {
    await Future.delayed(UIConstants.computerThinkingDelay);
    
    if (!_state.isGameActive) return;
    
    final computerMove = GameLogic.getBestMove(_state.board);
    
    _state.makeMove(computerMove, GameConstants.computerSymbol);
    _onStateChanged();
    
    // Animate the computer's move
    await _animationManager.animateSymbolPlacement(computerMove);
    
    // Check game state after animation completes
    if (GameLogic.checkWinner(_state.board)) {
      _handleComputerWin();
    } else if (GameLogic.isBoardFull(_state.board)) {
      _handleDraw();
    } else {
      _state.isPlayerTurn = true;
      _animationManager.animateTurnTransition(_state.isPlayerTurn);
      _onStateChanged();
    }
  }
  
  /// Checks if player can make a move at the specified index
  bool _canPlayerMove(int index) {
    return _state.isGameActive &&
           _state.isCellEmpty(index) &&
           _state.isPlayerTurn;
  }
  
  /// Handles player win
  void _handlePlayerWin() {
    _state.gameStatus = UIConstants.playerWinMessage;
    _state.playerScore++;
    _state.winningCombination = GameLogic.getWinningCombination(_state.board);
    _showWinningLineWithDelay();
    _startAutoRestart();
  }
  
  /// Handles computer win
  void _handleComputerWin() {
    _state.gameStatus = UIConstants.computerWinMessage;
    _state.computerScore++;
    _state.winningCombination = GameLogic.getWinningCombination(_state.board);
    _showWinningLineWithDelay();
    _startAutoRestart();
  }
  
  /// Handles draw
  void _handleDraw() {
    _state.gameStatus = UIConstants.drawMessage;
    _state.tiesScore++;
    _startAutoRestart();
  }
  
  /// Shows winning line after a delay
  Future<void> _showWinningLineWithDelay() async {
    await Future.delayed(UIConstants.winningLineDelay);
    _state.showWinningLine = true;
    _onStateChanged();
    
    // Start celebration animations after winning line appears
    await _animationManager.startWinCelebration();
  }
  
  /// Switches to computer turn
  void _switchToComputerTurn() {
    _state.isPlayerTurn = false;
    _animationManager.animateTurnTransition(_state.isPlayerTurn);
    _onStateChanged();
  }
  
  /// Starts the auto-restart countdown
  void _startAutoRestart() {
    _state.isCountingDown = true;
    _state.countdownSeconds = UIConstants.autoRestartSeconds;
    _onStateChanged();
    
    _startCountdownTimer();
  }
  
  /// Starts the countdown timer
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(UIConstants.countdownInterval, (timer) {
      _state.countdownSeconds--;
      _onStateChanged();
      
      if (_state.countdownSeconds <= 0) {
        timer.cancel();
        resetGame();
      }
    });
  }
  
  /// Resets the game for a new round
  void resetGame() {
    final previousStatus = _state.gameStatus;
    _state.reset();
    _updateTurnOrder(previousStatus);
    
    // Reset all animations
    _animationManager.resetCellAnimations();
    _animationManager.stopWinCelebration();
    
    // Animate turn transition for new game
    _animationManager.animateTurnTransition(_state.isPlayerTurn);
    _onStateChanged();
    
    if (!_state.isPlayerTurn) {
      makeComputerMove();
    }
  }
  
  /// Updates turn order based on previous game result
  void _updateTurnOrder(String previousStatus) {
    if (previousStatus.contains(UIConstants.playerWinMessage)) {
      // Player won - Computer goes first next game
      _state.playerGoesFirst = false;
      _state.isPlayerTurn = false;
    } else if (previousStatus.contains(UIConstants.computerWinMessage)) {
      // Computer won - Player goes first next game
      _state.playerGoesFirst = true;
      _state.isPlayerTurn = true;
    } else {
      // Draw - Alternate who goes first
      _state.updateFirstPlayer();
    }
  }
}
