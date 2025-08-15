import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/animation_manager.dart';
import '../constants/game_constants.dart';

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
    return AnimatedBuilder(
      animation: Listenable.merge([
        animationManager.scaleAnimations[index],
        animationManager.opacityAnimations[index],
      ]),
      builder: (context, child) {
        return GestureDetector(
          onTap: () => onCellTap(index),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Transform.scale(
                scale: animationManager.scaleAnimations[index].value,
                child: Opacity(
                  opacity: animationManager.opacityAnimations[index].value,
                  child: Text(
                    gameState.board[index],
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: gameState.board[index] == GameConstants.playerSymbol 
                          ? UIConstants.playerColor 
                          : UIConstants.computerColor,
                    ),
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
