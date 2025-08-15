import 'package:flutter/material.dart';
import '../constants/game_constants.dart';
import '../models/game_state.dart';
import '../services/splash_controller.dart';

/// Splash screen with animated mini tic-tac-toe game
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  
  const SplashScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late SplashController _splashController;
  late AnimationController _transitionController;
  late Animation<double> _scaleAnimation;
  GameState? _gameState;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    
    _transitionController = AnimationController(
      duration: UIConstants.splashTransitionDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));
    
    _splashController = SplashController(
      onStateChanged: (state) {
        if (mounted) {
          setState(() {
            _gameState = state;
          });
        }
      },
      onGameComplete: _startTransition,
    );
  }

  void _startTransition() {
    if (!mounted || _isTransitioning) return;
    
    setState(() {
      _isTransitioning = true;
    });
    
    _transitionController.forward().then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _splashController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    'Tic-Tac-Toe',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Mini game board
                  _buildMiniBoard(),
                  
                  const SizedBox(height: 40),
                  
                  // Loading text
                  if (!_isTransitioning)
                    Text(
                      'Loading...',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniBoard() {
    if (_gameState == null) {
      return _buildEmptyBoard();
    }
    
    return Container(
      width: UIConstants.splashBoardSize,
      height: UIConstants.splashBoardSize,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (int row = 0; row < 3; row++)
            Expanded(
              child: Row(
                children: [
                  for (int col = 0; col < 3; col++)
                    Expanded(
                      child: _buildMiniCell(row * 3 + col),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyBoard() {
    return Container(
      width: UIConstants.splashBoardSize,
      height: UIConstants.splashBoardSize,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (int row = 0; row < 3; row++)
            Expanded(
              child: Row(
                children: [
                  for (int col = 0; col < 3; col++)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniCell(int index) {
    final symbol = _gameState!.board[index];
    final isWinningCell = _gameState!.winningCombination?.contains(index) ?? false;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 1.5),
        color: isWinningCell ? Colors.yellow.shade200 : null,
      ),
      child: Center(
        child: symbol.isNotEmpty
            ? AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  symbol,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: symbol == GameConstants.playerSymbol
                        ? UIConstants.playerColor
                        : UIConstants.computerColor,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
