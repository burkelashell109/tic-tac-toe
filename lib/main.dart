import 'package:flutter/material.dart';
import 'services/game_controller.dart';
import 'services/animation_manager.dart';
import 'widgets/game_board.dart';
import 'widgets/status_display.dart';
import 'widgets/score_display.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TicTacToeGame(),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> with TickerProviderStateMixin {
  late GameController _gameController;
  late AnimationManager _animationManager;

  @override
  void initState() {
    super.initState();
    _animationManager = AnimationManager();
    _animationManager.initialize(this);
    
    _gameController = GameController();
    _gameController.initialize(_animationManager, () => setState(() {}));
  }

  @override
  void dispose() {
    _gameController.dispose();
    _animationManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          ScoreDisplay(gameState: _gameController.state),
          StatusDisplay(
            gameState: _gameController.state,
            animationManager: _animationManager,
          ),
          GameBoard(
            gameState: _gameController.state,
            animationManager: _animationManager,
            onCellTap: _gameController.handlePlayerMove,
          ),
        ],
      ),
    );
  }
}