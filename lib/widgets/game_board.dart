import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/animation_manager.dart';
import '../constants/game_constants.dart';
import 'celebration_effects.dart';

/// Widget that displays the tic-tac-toe game board
class GameBoard extends StatelessWidget {
  final GameState gameState;
  final AnimationManager animationManager;
  final Function(int) onCellTap;

  const GameBoard({
    super.key,
    required this.gameState,
    required this.animationManager,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: UIConstants.boardMaxSize,
            maxHeight: UIConstants.boardMaxSize,
          ),
          child: Stack(
            children: [
              _buildGrid(),
              if (gameState.showWinningLine && gameState.winningCombination != null)
                _buildWinningLine(),
              if (gameState.showWinningLine && gameState.winningCombination != null)
                _buildCelebrationEffects(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the main game grid
  Widget _buildGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: GameConstants.gridSize,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: GameConstants.boardSize,
      itemBuilder: (context, index) => _buildCell(index),
    );
  }

  /// Builds an individual cell
  Widget _buildCell(int index) {
    final isWinningCell = gameState.winningCombination?.contains(index) ?? false;
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        animationManager.scaleAnimations[index],
        animationManager.opacityAnimations[index],
        animationManager.flipAnimations[index],
        if (isWinningCell) animationManager.glowAnimation,
      ]),
      builder: (context, child) {
        // Calculate 3D flip rotation
        final flipProgress = animationManager.flipAnimations[index].value;
        final isFlipping = flipProgress > 0.0;
        final showBack = flipProgress > 0.5;
        final rotationY = flipProgress * math.pi;
        
        return GestureDetector(
          onTap: () => onCellTap(index),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Add perspective
              ..rotateY(rotationY),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                boxShadow: isWinningCell && gameState.showWinningLine
                    ? [
                        BoxShadow(
                          color: (gameState.board[index] == GameConstants.playerSymbol 
                              ? UIConstants.playerColor 
                              : UIConstants.computerColor).withOpacity(0.3 + animationManager.glowAnimation.value * 0.4),
                          blurRadius: 8 + animationManager.glowAnimation.value * 12,
                          spreadRadius: 2 + animationManager.glowAnimation.value * 3,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Transform.scale(
                  scale: animationManager.scaleAnimations[index].value,
                  child: Opacity(
                    opacity: animationManager.opacityAnimations[index].value,
                    child: showBack || !isFlipping
                        ? Text(
                            showBack ? '' : gameState.board[index], // Show blank when flipped to back
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 96,
                              fontWeight: FontWeight.bold,
                              color: gameState.board[index] == GameConstants.playerSymbol 
                                  ? UIConstants.playerColor 
                                  : UIConstants.computerColor,
                              height: 1.0, // Reduces line height to minimize baseline spacing
                              shadows: isWinningCell && gameState.showWinningLine
                                  ? [
                                      Shadow(
                                        color: (gameState.board[index] == GameConstants.playerSymbol 
                                            ? UIConstants.playerColor 
                                            : UIConstants.computerColor).withOpacity(0.5 + animationManager.glowAnimation.value * 0.5),
                                        blurRadius: 4 + animationManager.glowAnimation.value * 8,
                                      ),
                                    ]
                                  : null,
                            ),
                          )
                        : const SizedBox.shrink(), // Hide during flip transition
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the winning line overlay
  Widget _buildWinningLine() {
    if (gameState.winningCombination == null) return const SizedBox.shrink();

    return CustomPaint(
      size: const Size(UIConstants.boardMaxSize, UIConstants.boardMaxSize),
      painter: WinningLinePainter(
        winningCombination: gameState.winningCombination!,
        color: gameState.isPlayerWin ? UIConstants.playerColor : UIConstants.computerColor,
      ),
    );
  }
  
  /// Builds the celebration effects overlay
  Widget _buildCelebrationEffects() {
    if (gameState.winningCombination == null) return const SizedBox.shrink();
    
    final winningSymbol = gameState.isPlayerWin ? GameConstants.playerSymbol : GameConstants.computerSymbol;
    final symbolColor = gameState.isPlayerWin ? UIConstants.playerColor : UIConstants.computerColor;
    
    return CelebrationEffects(
      particleAnimation: animationManager.particleAnimation,
      winningPositions: gameState.winningCombination!,
      winningSymbol: winningSymbol,
      symbolColor: symbolColor,
    );
  }
}

/// Custom painter for the winning line
class WinningLinePainter extends CustomPainter {
  final List<int> winningCombination;
  final Color color;

  WinningLinePainter({
    required this.winningCombination,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = UIConstants.winLineWidth
      ..strokeCap = StrokeCap.round;

    final cellSize = size.width / GameConstants.gridSize;
    final startPos = _getCellCenter(winningCombination[0], cellSize);
    final endPos = _getCellCenter(winningCombination[2], cellSize);

    canvas.drawLine(startPos, endPos, paint);
  }

  /// Gets the center position of a cell
  Offset _getCellCenter(int index, double cellSize) {
    final row = index ~/ GameConstants.gridSize;
    final col = index % GameConstants.gridSize;
    return Offset(
      col * cellSize + cellSize / 2,
      row * cellSize + cellSize / 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
