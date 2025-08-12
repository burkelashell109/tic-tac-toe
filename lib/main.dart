import 'package:flutter/material.dart';
import 'dart:async';

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

// Game state management
class GameState {
  List<String> board = List.filled(9, '');
  bool isPlayerTurn = true;
  bool playerGoesFirst = true;
  String gameStatus = '';
  int playerScore = 0;
  int computerScore = 0;
  int tiesScore = 0;
  bool isComputerThinking = false;
  int countdownSeconds = 0;
  bool isCountingDown = false;
  List<int>? winningCombination;
  bool showWinningLine = false;

  bool get isGameActive => gameStatus.isEmpty && !isCountingDown;
  bool get isPlayerWin => gameStatus.contains('You win');
  bool get isComputerWin => gameStatus.contains('Computer wins');
  bool get isDraw => gameStatus.contains('draw');
  
  void reset() {
    board = List.filled(9, '');
    gameStatus = '';
    isComputerThinking = false;
    isCountingDown = false;
    countdownSeconds = 0;
    winningCombination = null;
    showWinningLine = false;
  }
  
  void switchTurns() {
    isPlayerTurn = !isPlayerTurn;
  }
  
  void updateFirstPlayer() {
    playerGoesFirst = !playerGoesFirst;
    isPlayerTurn = playerGoesFirst;
  }
}

// Game logic and AI
class GameLogic {
  static const List<List<int>> _winningCombinations = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
    [0, 4, 8], [2, 4, 6], // diagonals
  ];

  static bool checkWinner(List<String> board) {
    for (List<int> combination in _winningCombinations) {
      if (board[combination[0]].isNotEmpty &&
          board[combination[0]] == board[combination[1]] &&
          board[combination[1]] == board[combination[2]]) {
        return true;
      }
    }
    return false;
  }

  static List<int>? getWinningCombination(List<String> board) {
    for (List<int> combination in _winningCombinations) {
      if (board[combination[0]].isNotEmpty &&
          board[combination[0]] == board[combination[1]] &&
          board[combination[1]] == board[combination[2]]) {
        return combination;
      }
    }
    return null;
  }

  static bool isBoardFull(List<String> board) {
    return board.every((cell) => cell.isNotEmpty);
  }

  static int getBestMove(List<String> board) {
    // 1. Try to win
    int? winMove = _findWinningMove(board, 'O');
    if (winMove != null) return winMove;
    
    // 2. Block player from winning
    int? blockMove = _findWinningMove(board, 'X');
    if (blockMove != null) return blockMove;
    
    // 3. Take center if available
    if (board[4].isEmpty) return 4;
    
    // 4. Take corners
    List<int> corners = [0, 2, 6, 8];
    for (int corner in corners) {
      if (board[corner].isEmpty) return corner;
    }
    
    // 5. Take any remaining space
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) return i;
    }
    
    return 0; // Fallback
  }

  static int? _findWinningMove(List<String> board, String player) {
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) {
        board[i] = player;
        if (checkWinner(board)) {
          board[i] = ''; // Reset
          return i;
        }
        board[i] = ''; // Reset
      }
    }
    return null;
  }
}

// UI Constants
class UIConstants {
  static const Duration computerThinkingDelay = Duration(milliseconds: 800);
  static const Duration countdownInterval = Duration(seconds: 1);
  static const Duration winningLineDelay = Duration(milliseconds: 400);
  static const int autoRestartSeconds = 3;
  static const double boardMaxSize = 300.0;
  static const double borderWidth = 2.0;
  static const double borderRadius = 8.0;
  static const double winningLineWidth = 4.0;
  
  static const Color playerColor = Colors.blue;
  static const Color computerColor = Colors.red;
}

// Custom painter for winning line
class WinningLinePainter extends CustomPainter {
  final List<int> winningCombination;
  final Color lineColor;

  WinningLinePainter(this.winningCombination, this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = UIConstants.winningLineWidth
      ..strokeCap = StrokeCap.round;

    final cellSize = size.width / 3;
    final halfCell = cellSize / 2;

    // Calculate positions of winning cells
    final positions = winningCombination.map((index) {
      final row = index ~/ 3;
      final col = index % 3;
      return Offset(
        col * cellSize + halfCell,
        row * cellSize + halfCell,
      );
    }).toList();

    // Draw line from first to last position
    canvas.drawLine(positions.first, positions.last, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  final GameState _gameState = GameState();
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_gameState.isPlayerTurn) {
        _makeComputerMove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildScoreDisplay(),
          _buildStatusDisplay(),
          _buildGameBoard(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Tic Tac Toe'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildScoreColumn('You', _gameState.playerScore, UIConstants.playerColor),
          _buildScoreColumn('Computer', _gameState.computerScore, UIConstants.computerColor),
          _buildScoreColumn('Ties', _gameState.tiesScore, Colors.black),
        ],
      ),
    );
  }

  Widget _buildScoreColumn(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: (Theme.of(context).textTheme.titleMedium?.fontSize ?? 16) * 2.0,
            color: label == 'Ties' ? Colors.black : null,
          ),
        ),
        Text(
          '$score',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: (Theme.of(context).textTheme.headlineLarge?.fontSize ?? 32) * 2.0,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDisplay() {
    return Container(
      padding: const EdgeInsets.only(top: 70, bottom: 20), // Moved down by 50px from original 20px
      child: Text(
        _getStatusText(),
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: (Theme.of(context).textTheme.headlineSmall?.fontSize ?? 24) * 1.5,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(),
        ),
      ),
    );
  }

  String _getStatusText() {
    if (_gameState.isCountingDown) {
      if (_gameState.gameStatus.isNotEmpty) {
        return '${_gameState.gameStatus}\nNext game in ${_gameState.countdownSeconds}...';
      }
      return 'Next game in ${_gameState.countdownSeconds}...';
    }
    
    if (_gameState.gameStatus.isNotEmpty) {
      return _gameState.gameStatus;
    }
    
    if (_gameState.isComputerThinking) {
      return 'Computer is thinking...';
    }
    
    return _gameState.isPlayerTurn ? "Your Turn" : "Computer's Turn";
  }

  Color? _getStatusColor() {
    if (_gameState.isPlayerWin) return UIConstants.playerColor;
    if (_gameState.isComputerWin) return UIConstants.computerColor;
    return null;
  }

  Widget _buildGameBoard() {
    return Expanded(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: UIConstants.boardMaxSize,
            maxHeight: UIConstants.boardMaxSize,
          ),
          child: Stack(
            children: [
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: 9,
                itemBuilder: (context, index) => _buildGameCell(index),
              ),
              if (_gameState.showWinningLine && _gameState.winningCombination != null)
                _buildWinningLine(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCell(int index) {
    return GestureDetector(
      onTap: () => _handleCellTap(index),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: UIConstants.borderWidth,
          ),
          borderRadius: BorderRadius.circular(UIConstants.borderRadius),
        ),
        child: Center(
          child: Text(
            _gameState.board[index],
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getCellColor(index),
            ),
          ),
        ),
      ),
    );
  }

  Color? _getCellColor(int index) {
    final cellValue = _gameState.board[index];
    if (cellValue == 'X') return UIConstants.playerColor;
    if (cellValue == 'O') return UIConstants.computerColor;
    return null;
  }

  Widget _buildWinningLine() {
    if (_gameState.winningCombination == null) return const SizedBox.shrink();
    
    final combination = _gameState.winningCombination!;
    final color = _gameState.isPlayerWin ? UIConstants.playerColor : UIConstants.computerColor;
    
    return CustomPaint(
      size: const Size(UIConstants.boardMaxSize, UIConstants.boardMaxSize),
      painter: WinningLinePainter(combination, color),
    );
  }

  // Game Logic Methods
  void _handleCellTap(int index) {
    if (!_canPlayerMove(index)) return;

    setState(() {
      _gameState.board[index] = 'X';
      
      if (GameLogic.checkWinner(_gameState.board)) {
        _handlePlayerWin();
      } else if (GameLogic.isBoardFull(_gameState.board)) {
        _handleDraw();
      } else {
        _switchToComputerTurn();
      }
    });

    if (_gameState.isGameActive && !_gameState.isPlayerTurn) {
      _makeComputerMove();
    }
  }

  bool _canPlayerMove(int index) {
    return _gameState.isGameActive &&
           _gameState.board[index].isEmpty &&
           _gameState.isPlayerTurn &&
           !_gameState.isComputerThinking;
  }

  void _handlePlayerWin() {
    _gameState.gameStatus = 'You win!';
    _gameState.playerScore++;
    _gameState.winningCombination = GameLogic.getWinningCombination(_gameState.board);
    _showWinningLineWithDelay();
    _startAutoRestart();
  }

  void _handleDraw() {
    _gameState.gameStatus = 'It\'s a draw!';
    _gameState.tiesScore++;
    _startAutoRestart();
  }

  void _showWinningLineWithDelay() async {
    await Future.delayed(UIConstants.winningLineDelay);
    if (mounted) {
      setState(() {
        _gameState.showWinningLine = true;
      });
    }
  }

  void _switchToComputerTurn() {
    _gameState.isPlayerTurn = false;
    _gameState.isComputerThinking = true;
  }

  Future<void> _makeComputerMove() async {
    await Future.delayed(UIConstants.computerThinkingDelay);
    
    if (!mounted || !_gameState.isGameActive) return;
    
    final computerMove = GameLogic.getBestMove(_gameState.board);
    
    setState(() {
      _gameState.isComputerThinking = false;
      _gameState.board[computerMove] = 'O';
      
      if (GameLogic.checkWinner(_gameState.board)) {
        _handleComputerWin();
      } else if (GameLogic.isBoardFull(_gameState.board)) {
        _handleDraw();
      } else {
        _gameState.isPlayerTurn = true;
      }
    });
  }

  void _handleComputerWin() {
    _gameState.gameStatus = 'Computer wins!';
    _gameState.computerScore++;
    _gameState.winningCombination = GameLogic.getWinningCombination(_gameState.board);
    _showWinningLineWithDelay();
    _startAutoRestart();
  }

  // Auto-restart Logic
  void _startAutoRestart() {
    setState(() {
      _gameState.isCountingDown = true;
      _gameState.countdownSeconds = UIConstants.autoRestartSeconds;
    });
    
    _startCountdownTimer();
  }
  
  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(UIConstants.countdownInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _gameState.countdownSeconds--;
      });
      
      if (_gameState.countdownSeconds <= 0) {
        timer.cancel();
        _resetGame();
      }
    });
  }

  void _resetGame() {
    if (!mounted) return;
    
    setState(() {
      final previousStatus = _gameState.gameStatus;
      _gameState.reset();
      _updateTurnOrder(previousStatus);
    });
    
    if (!_gameState.isPlayerTurn) {
      _makeComputerMove();
    }
  }

  void _updateTurnOrder(String previousStatus) {
    if (previousStatus.contains('win') || previousStatus.contains('draw')) {
      _gameState.updateFirstPlayer();
    }
  }
}
