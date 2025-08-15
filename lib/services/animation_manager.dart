import 'package:flutter/material.dart';
import '../constants/game_constants.dart';

/// Manages all animations for the tic-tac-toe game
class AnimationManager {
  late List<AnimationController> _cellControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _opacityAnimations;
  
  // Turn transition animations
  late AnimationController _colorTransitionController;
  late AnimationController _pulseController;
  late AnimationController _backgroundController;
  late Animation<Color?> _statusColorAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _backgroundColorAnimation;
  
  // Win celebration animations
  late AnimationController _celebrationGlowController;
  late AnimationController _celebrationParticleController;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;
  
  // Board reset animations
  late List<AnimationController> _resetFlipControllers;
  late List<Animation<double>> _resetFlipAnimations;
  
  /// Initializes all animation controllers
  void initialize(TickerProvider vsync) {
    // Cell animations
    _cellControllers = List.generate(GameConstants.boardSize, (index) => AnimationController(
      duration: UIConstants.cellAnimationDuration,
      vsync: vsync,
    ));
    
    _scaleAnimations = _cellControllers.map((controller) => Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    ))).toList();
    
    _opacityAnimations = _cellControllers.map((controller) => Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ))).toList();
    
    // Turn transition animations
    _colorTransitionController = AnimationController(
      duration: UIConstants.turnTransitionDuration,
      vsync: vsync,
    );
    
    _pulseController = AnimationController(
      duration: UIConstants.pulseAnimationDuration,
      vsync: vsync,
    )..repeat(reverse: true);
    
    _backgroundController = AnimationController(
      duration: UIConstants.turnTransitionDuration,
      vsync: vsync,
    );
    
    // Color animations with muted tones
    _statusColorAnimation = ColorTween(
      begin: UIConstants.playerColor.withOpacity(0.7),
      end: UIConstants.computerColor.withOpacity(0.7),
    ).animate(CurvedAnimation(
      parent: _colorTransitionController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _backgroundColorAnimation = ColorTween(
      begin: UIConstants.playerColor.withOpacity(0.02),
      end: UIConstants.computerColor.withOpacity(0.02),
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
    
    // Win celebration animations
    _celebrationGlowController = AnimationController(
      duration: UIConstants.celebrationGlowDuration,
      vsync: vsync,
    );
    
    _celebrationParticleController = AnimationController(
      duration: UIConstants.celebrationParticleDuration,
      vsync: vsync,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationGlowController,
      curve: Curves.easeInOut,
    ));
    
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationParticleController,
      curve: Curves.easeOut,
    ));
    
    // Board reset flip animations
    _resetFlipControllers = List.generate(GameConstants.boardSize, (index) => AnimationController(
      duration: UIConstants.resetFlipDuration,
      vsync: vsync,
    ));
    
    _resetFlipAnimations = _resetFlipControllers.map((controller) => Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ))).toList();
  }
  
  /// Disposes all animation controllers
  void dispose() {
    for (var controller in _cellControllers) {
      controller.dispose();
    }
    for (var controller in _resetFlipControllers) {
      controller.dispose();
    }
    _colorTransitionController.dispose();
    _pulseController.dispose();
    _backgroundController.dispose();
    _celebrationGlowController.dispose();
    _celebrationParticleController.dispose();
  }
  
  /// Animates a cell placement
  Future<void> animateSymbolPlacement(int index) async {
    await _cellControllers[index].forward();
  }
  
  /// Animates turn transition
  void animateTurnTransition(bool isPlayerTurn) {
    if (isPlayerTurn) {
      _colorTransitionController.reverse();
      _backgroundController.reverse();
    } else {
      _colorTransitionController.forward();
      _backgroundController.forward();
    }
  }
  
  /// Resets all cell animations
  void resetCellAnimations() {
    for (var controller in _cellControllers) {
      controller.reset();
    }
  }
  
  /// Starts the win celebration animations
  Future<void> startWinCelebration() async {
    // Start glow animation (pulsing effect)
    _celebrationGlowController.repeat(reverse: true);
    
    // Start particle animation after a short delay
    await Future.delayed(const Duration(milliseconds: 300));
    await _celebrationParticleController.forward();
  }
  
  /// Stops the win celebration animations
  void stopWinCelebration() {
    _celebrationGlowController.stop();
    _celebrationGlowController.reset();
    _celebrationParticleController.reset();
  }
  
  /// Animates board reset with 3D flip effect in sequence
  Future<void> animateBoardReset(List<int>? winningPositions) async {
    // First, flip winning cells if there are any
    if (winningPositions != null && winningPositions.isNotEmpty) {
      for (int i = 0; i < winningPositions.length; i++) {
        final position = winningPositions[i];
        _resetFlipControllers[position].forward();
        if (i < winningPositions.length - 1) {
          await Future.delayed(UIConstants.resetSequenceDelay);
        }
      }
      await Future.delayed(UIConstants.resetSequenceDelay);
    }
    
    // Then flip remaining cells row by row
    final remainingPositions = <int>[];
    for (int i = 0; i < GameConstants.boardSize; i++) {
      if (winningPositions == null || !winningPositions.contains(i)) {
        remainingPositions.add(i);
      }
    }
    
    // Group by rows and flip row by row
    for (int row = 0; row < GameConstants.gridSize; row++) {
      final rowPositions = remainingPositions.where((pos) => pos ~/ GameConstants.gridSize == row).toList();
      
      // Flip all cells in current row simultaneously
      for (final position in rowPositions) {
        _resetFlipControllers[position].forward();
      }
      
      if (row < GameConstants.gridSize - 1 && rowPositions.isNotEmpty) {
        await Future.delayed(UIConstants.resetSequenceDelay);
      }
    }
  }
  
  /// Resets all flip animations
  void resetFlipAnimations() {
    for (var controller in _resetFlipControllers) {
      controller.reset();
    }
  }
  
  // Getters for animations
  List<Animation<double>> get scaleAnimations => _scaleAnimations;
  List<Animation<double>> get opacityAnimations => _opacityAnimations;
  Animation<Color?> get statusColorAnimation => _statusColorAnimation;
  Animation<double> get pulseAnimation => _pulseAnimation;
  Animation<Color?> get backgroundColorAnimation => _backgroundColorAnimation;
  Animation<double> get glowAnimation => _glowAnimation;
  Animation<double> get particleAnimation => _particleAnimation;
  List<Animation<double>> get flipAnimations => _resetFlipAnimations;
}
