import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../constants/game_constants.dart';

/// Widget that displays the game scores
class ScoreDisplay extends StatelessWidget {
  final GameState gameState;

  const ScoreDisplay({
    super.key,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildScoreColumn(
            context,
            'You (X)',
            gameState.playerScore,
            UIConstants.playerColor,
          ),
          _buildScoreColumn(
            context,
            'Ties',
            gameState.tiesScore,
            Colors.black,
          ),
          _buildScoreColumn(
            context,
            'Computer (O)',
            gameState.computerScore,
            UIConstants.computerColor,
          ),
        ],
      ),
    );
  }

  /// Builds a score column for a player
  Widget _buildScoreColumn(
    BuildContext context,
    String label,
    int score,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: (Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) * UIConstants.scoreTextScale,
            color: label == 'Ties' ? Colors.black : null,
          ),
        ),
        Text(
          '$score',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: (Theme.of(context).textTheme.headlineLarge?.fontSize ?? 32) * UIConstants.scoreTextScale,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
