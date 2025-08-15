import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/animation_manager.dart';
import '../constants/game_constants.dart';

/// Widget that displays the current game status
class StatusDisplay extends StatelessWidget {
  final GameState gameState;
  final AnimationManager animationManager;

  const StatusDisplay({
    super.key,
    required this.gameState,
    required this.animationManager,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationManager.backgroundColorAnimation,
      builder: (context, child) {
        return Container(
          height: 90, // Fixed height to prevent board movement
          decoration: BoxDecoration(
            color: animationManager.backgroundColorAnimation.value ?? Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: _buildStatusText(context),
          ),
        );
      },
    );
  }

  /// Builds the status text with appropriate styling
  Widget _buildStatusText(BuildContext context) {
    return AnimatedBuilder(
      animation: animationManager.statusColorAnimation,
      builder: (context, child) {
        final baseStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: (Theme.of(context).textTheme.headlineSmall?.fontSize ?? 24) * UIConstants.baseTextScale,
          fontWeight: FontWeight.bold,
        );

        final countdownStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: (Theme.of(context).textTheme.headlineSmall?.fontSize ?? 24) * UIConstants.countdownTextScale,
          fontWeight: FontWeight.bold,
        );

        if (gameState.isCountingDown && gameState.gameStatus.isNotEmpty) {
          // Mixed color message: win message in color + countdown in black (smaller)
          return _buildMixedColorText(baseStyle, countdownStyle);
        }

        // Single color messages
        return Text(
          _getStatusText(),
          textAlign: TextAlign.center,
          style: baseStyle?.copyWith(
            color: _getStatusColor(),
          ),
        );
      },
    );
  }

  /// Builds text with mixed colors for countdown messages
  Widget _buildMixedColorText(TextStyle? baseStyle, TextStyle? countdownStyle) {
    Color winColor;
    if (gameState.isPlayerWin) {
      winColor = UIConstants.playerColor;
    } else if (gameState.isComputerWin) {
      winColor = UIConstants.computerColor;
    } else {
      winColor = Colors.black; // For draws
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: gameState.gameStatus,
            style: baseStyle?.copyWith(color: winColor),
          ),
          TextSpan(
            text: '\nNext game in ${gameState.countdownSeconds}...',
            style: countdownStyle?.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }

  /// Gets the appropriate status text
  String _getStatusText() {
    if (gameState.isCountingDown) {
      if (gameState.gameStatus.isNotEmpty) {
        return '${gameState.gameStatus}\nNext game in ${gameState.countdownSeconds}...';
      }
      return 'Next game in ${gameState.countdownSeconds}...';
    }
    
    if (gameState.gameStatus.isNotEmpty) {
      return gameState.gameStatus;
    }
    
    return gameState.isPlayerTurn 
        ? UIConstants.playerTurnMessage 
        : UIConstants.computerTurnMessage;
  }

  /// Gets the appropriate status color
  Color? _getStatusColor() {
    // Skip countdown with game status (handled by RichText)
    if (gameState.isCountingDown && gameState.gameStatus.isNotEmpty) {
      return null; // Not used for mixed color messages
    }
    
    // Simple countdown messages (black)
    if (gameState.isCountingDown) return Colors.black;
    
    // Win messages (when not counting down)
    if (gameState.isPlayerWin) return UIConstants.playerColor;
    if (gameState.isComputerWin) return UIConstants.computerColor;
    
    // Turn messages - use animated color for active game
    if (gameState.gameStatus.isEmpty && !gameState.isCountingDown) {
      if (gameState.isPlayerTurn) {
        return animationManager.statusColorAnimation.value ?? UIConstants.playerColor;
      }
      return animationManager.statusColorAnimation.value ?? UIConstants.computerColor;
    }
    
    // Draw messages and other default cases
    return Colors.black;
  }
}
