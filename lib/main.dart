import 'package:flutter/material.dart';
import 'dart:async';
// Uncomment the next line to see the icon generator
// import 'icon_generator.dart';

void main() {
  runApp(const TicTacToeApp());
  // Uncomment the next line to see the icon generator instead
  // runApp(const IconGeneratorApp());
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

// Helper class for minimax algorithm
class _MinimaxResult {
  final int move;
  final int score;
  
  _MinimaxResult(this.move, this.score);
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
    // Use minimax algorithm for perfect play
    return _minimax(board, 0, true, -1000, 1000).move;
  }

  // Minimax algorithm with alpha-beta pruning for perfect play
  static _MinimaxResult _minimax(List<String> board, int depth, bool isMaximizing, int alpha, int beta) {
    // Check for terminal states
    if (checkWinner(board)) {
      if (isMaximizing) {
        return _MinimaxResult(-1, -10 + depth); // Computer loses
      } else {
        return _MinimaxResult(-1, 10 - depth); // Computer wins
      }
    }
    
    if (isBoardFull(board)) {
      return _MinimaxResult(-1, 0); // Draw
    }
    
    if (isMaximizing) {
      // Computer's turn (maximizing)
      int maxEval = -1000;
      int bestMove = -1;
      
      for (int i = 0; i < 9; i++) {
        if (board[i].isEmpty) {
          board[i] = 'O';
          _MinimaxResult eval = _minimax(board, depth + 1, false, alpha, beta);
          board[i] = ''; // Undo move
          
          if (eval.score > maxEval) {
            maxEval = eval.score;
            bestMove = i;
          }
          
          alpha = alpha > eval.score ? alpha : eval.score;
          if (beta <= alpha) break; // Alpha-beta pruning
        }
      }
      
      return _MinimaxResult(bestMove, maxEval);
    } else {
      // Human's turn (minimizing)
      int minEval = 1000;
      int bestMove = -1;
      
      for (int i = 0; i < 9; i++) {
        if (board[i].isEmpty) {
          board[i] = 'X';
          _MinimaxResult eval = _minimax(board, depth + 1, true, alpha, beta);
          board[i] = ''; // Undo move
          
          if (eval.score < minEval) {
            minEval = eval.score;
            bestMove = i;
          }
          
          beta = beta < eval.score ? beta : eval.score;
          if (beta <= alpha) break; // Alpha-beta pruning
        }
      }
      
      return _MinimaxResult(bestMove, minEval);
    }
  }

  // Detect when we should avoid the specific losing pattern
  static bool _shouldAvoidLosingPattern(List<String> board) {
    int moveCount = board.where((cell) => cell.isNotEmpty).length;
    
    // Check on computer's second move (after computer 0, human 8, computer 1, human 2)
    if (moveCount == 4) {
      return (board[0] == 'O' && board[8] == 'X' && board[1] == 'O' && board[2] == 'X') ||
             (board[2] == 'O' && board[6] == 'X' && board[1] == 'O' && board[0] == 'X') ||
             (board[6] == 'O' && board[0] == 'X' && board[7] == 'O' && board[8] == 'X') ||
             (board[8] == 'O' && board[2] == 'X' && board[7] == 'O' && board[6] == 'X');
    }
    
    return false;
  }

  // Get a move that avoids the losing pattern
  static int? _getPatternAvoidanceMove(List<String> board) {
    // If we're in the dangerous pattern, DON'T play the edge that enables the fork
    // Instead, play center or a corner that blocks the fork
    
    if (board[0] == 'O' && board[8] == 'X' && board[1] == 'O' && board[2] == 'X') {
      // DON'T play 5 (right edge) - instead play center or corner
      if (board[4].isEmpty) return 4; // Center
      if (board[6].isEmpty) return 6; // Block the fork position directly
      if (board[3].isEmpty) return 3; // Left edge
      if (board[7].isEmpty) return 7; // Bottom edge
    }
    
    // Similar logic for other rotations
    if (board[2] == 'O' && board[6] == 'X' && board[1] == 'O' && board[0] == 'X') {
      if (board[4].isEmpty) return 4;
      if (board[8].isEmpty) return 8;
      if (board[5].isEmpty) return 5;
      if (board[7].isEmpty) return 7;
    }
    
    return null;
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

  // Find a move that creates a fork (two ways to win)
  static int? _findForkMove(List<String> board, String player) {
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) {
        board[i] = player;
        int winningMoves = 0;
        
        // Count how many ways we can win after this move
        for (int j = 0; j < 9; j++) {
          if (board[j].isEmpty) {
            board[j] = player;
            if (checkWinner(board)) {
              winningMoves++;
            }
            board[j] = ''; // Reset
          }
        }
        
        board[i] = ''; // Reset
        
        // If we have 2 or more ways to win, it's a fork
        if (winningMoves >= 2) {
          return i;
        }
      }
    }
    return null;
  }

  // Block opponent's fork by forcing them to defend
  static int? _blockOpponentFork(List<String> board) {
    String opponent = 'X';
    String computer = 'O';
    
    // First, find all moves where opponent could create a fork
    List<int> opponentForks = [];
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) {
        board[i] = opponent;
        int winningMoves = 0;
        
        for (int j = 0; j < 9; j++) {
          if (board[j].isEmpty) {
            board[j] = opponent;
            if (checkWinner(board)) {
              winningMoves++;
            }
            board[j] = ''; // Reset
          }
        }
        
        board[i] = ''; // Reset
        
        if (winningMoves >= 2) {
          opponentForks.add(i);
        }
      }
    }
    
    // Special case: Handle the specific pattern you mentioned
    // If computer has 0,1,5 and opponent has 8,2, block position 6
    if (_isSpecificTrapPattern(board)) {
      if (board[6].isEmpty) return 6;
      if (board[3].isEmpty) return 3;
      if (board[7].isEmpty) return 7;
    }
    
    // If opponent has multiple fork opportunities, create a two-in-a-row to force defense
    if (opponentForks.length > 1) {
      return _createForcingMove(board, computer);
    }
    
    // If opponent has one fork opportunity, block it
    if (opponentForks.length == 1) {
      return opponentForks[0];
    }
    
    return null;
  }

  // Detect the specific losing pattern
  static bool _isSpecificTrapPattern(List<String> board) {
    // Pattern: Computer has 0,1,5 and opponent has 8,2
    return (board[0] == 'O' && board[1] == 'O' && board[5] == 'O' &&
            board[8] == 'X' && board[2] == 'X') ||
           // Also check similar patterns
           (board[0] == 'O' && board[3] == 'O' && board[7] == 'O' &&
            board[8] == 'X' && board[6] == 'X');
  }

  // Create a move that forces opponent to defend, preventing their fork
  static int? _createForcingMove(List<String> board, String player) {
    for (int i = 0; i < 9; i++) {
      if (board[i].isEmpty) {
        board[i] = player;
        
        // Check if this creates a threat (two in a row)
        bool createsThreat = false;
        for (List<int> combination in _winningCombinations) {
          int playerCount = 0;
          int emptyCount = 0;
          
          for (int pos in combination) {
            if (board[pos] == player) playerCount++;
            if (board[pos].isEmpty) emptyCount++;
          }
          
          if (playerCount == 2 && emptyCount == 1) {
            createsThreat = true;
            break;
          }
        }
        
        board[i] = ''; // Reset
        
        if (createsThreat) {
          return i;
        }
      }
    }
    return null;
  }

  // Strategic move selection based on board state
  static int? _getStrategicMove(List<String> board) {
    // Count moves to determine game phase
    int moveCount = board.where((cell) => cell.isNotEmpty).length;
    
    // Check for dangerous patterns and respond defensively
    if (_needsDefensivePlay(board)) {
      return _getDefensiveMove(board);
    }
    
    // Opening moves (first 2 moves)
    if (moveCount <= 2) {
      return _getOpeningMove(board);
    }
    
    // Mid-game: prioritize corners, then center, then edges
    List<int> corners = [0, 2, 6, 8];
    List<int> edges = [1, 3, 5, 7];
    
    // Take center if available and strategic
    if (board[4].isEmpty && _isCenterGood(board)) {
      return 4;
    }
    
    // Take corners
    for (int corner in corners) {
      if (board[corner].isEmpty) return corner;
    }
    
    // Take edges as last resort
    for (int edge in edges) {
      if (board[edge].isEmpty) return edge;
    }
    
    return null;
  }

  // Check if we need to play defensively to avoid losing patterns
  static bool _needsDefensivePlay(List<String> board) {
    // Check if opponent is setting up the specific fork pattern
    int moveCount = board.where((cell) => cell.isNotEmpty).length;
    
    if (moveCount == 4) {
      // Look for patterns where opponent could fork next move
      return _isSpecificTrapPattern(board);
    }
    
    return false;
  }

  // Get a defensive move to prevent losing patterns
  static int? _getDefensiveMove(List<String> board) {
    // Block the fork positions
    if (board[6].isEmpty) return 6;
    if (board[3].isEmpty) return 3;
    if (board[7].isEmpty) return 7;
    if (board[4].isEmpty) return 4;
    
    return null;
  }

  // Smart opening moves based on opponent's first move
  static int? _getOpeningMove(List<String> board) {
    int moveCount = board.where((cell) => cell.isNotEmpty).length;
    
    // Computer's first move
    if (moveCount == 1) {
      // If opponent took center, take a corner
      if (board[4] == 'X') {
        return 0; // Take top-left corner
      }
      
      // If opponent took a corner, take center (OPTIMAL STRATEGY)
      if ([0, 2, 6, 8].any((i) => board[i] == 'X')) {
        return 4; // Take center - this is the strongest response
      }
      
      // If opponent took an edge, take center
      if ([1, 3, 5, 7].any((i) => board[i] == 'X')) {
        return 4; // Take center
      }
    }
    
    // Computer's second move - CRITICAL FIX
    if (moveCount == 3) {
      // If computer took corner 0 and human took opposite corner 8
      // DON'T play adjacent edges - play strategically
      if (board[0] == 'O' && board[8] == 'X') {
        // If human played 2, play center or corner 6 to maintain control
        if (board[2] == 'X') {
          if (board[4].isEmpty) return 4; // Center - much safer
          if (board[6].isEmpty) return 6; // Corner - maintains options
        }
        // If human played other moves, respond accordingly
        if (board[6] == 'X') {
          if (board[4].isEmpty) return 4;
          if (board[2].isEmpty) return 2;
        }
      }
      
      // Similar logic for other corner combinations
      if (board[2] == 'O' && board[6] == 'X') {
        if (board[0] == 'X') {
          if (board[4].isEmpty) return 4;
          if (board[8].isEmpty) return 8;
        }
      }
      
      // If computer took center first, play strong corners
      if (board[4] == 'O') {
        List<int> corners = [0, 2, 6, 8];
        for (int corner in corners) {
          if (board[corner].isEmpty) return corner;
        }
      }
    }
    
    return null;
  }

  // Determine if taking center is strategically good
  static bool _isCenterGood(List<String> board) {
    // If opponent has opposite corners, center might not be best
    if ((board[0] == 'X' && board[8] == 'X') || 
        (board[2] == 'X' && board[6] == 'X')) {
      return false;
    }
    return true;
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
    return SizedBox(
      height: 90, // Fixed height to prevent board movement
      child: Center(
        child: _buildStatusText(),
      ),
    );
  }

  Widget _buildStatusText() {
    final baseStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontSize: (Theme.of(context).textTheme.headlineSmall?.fontSize ?? 24) * 1.5,
      fontWeight: FontWeight.bold,
    );

    final countdownStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontSize: (Theme.of(context).textTheme.headlineSmall?.fontSize ?? 24) * 0.9,
      fontWeight: FontWeight.bold,
    );

    if (_gameState.isCountingDown && _gameState.gameStatus.isNotEmpty) {
      // Mixed color message: win message in color + countdown in black (smaller)
      Color winColor;
      if (_gameState.isPlayerWin) {
        winColor = UIConstants.playerColor;
      } else if (_gameState.isComputerWin) {
        winColor = UIConstants.computerColor;
      } else {
        winColor = Colors.black; // For draws
      }

      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: _gameState.gameStatus,
              style: baseStyle?.copyWith(color: winColor),
            ),
            TextSpan(
              text: '\nNext game in ${_gameState.countdownSeconds}...',
              style: countdownStyle?.copyWith(color: Colors.black),
            ),
          ],
        ),
      );
    }

    // Single color messages
    return Text(
      _getStatusText(),
      textAlign: TextAlign.center,
      style: baseStyle?.copyWith(
        color: _getStatusColor(),
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
    // Skip countdown with game status (handled by RichText in _buildStatusText)
    if (_gameState.isCountingDown && _gameState.gameStatus.isNotEmpty) {
      return null; // Not used for mixed color messages
    }
    
    // Simple countdown messages (black)
    if (_gameState.isCountingDown) return Colors.black;
    
    // Win messages (when not counting down)
    if (_gameState.isPlayerWin) return UIConstants.playerColor;
    if (_gameState.isComputerWin) return UIConstants.computerColor;
    
    // Turn and thinking messages
    if (_gameState.gameStatus.isEmpty && !_gameState.isCountingDown) {
      if (_gameState.isComputerThinking) return UIConstants.computerColor; // "Computer is thinking..." = red
      if (_gameState.isPlayerTurn) return UIConstants.playerColor; // "Your Turn" = blue
      return UIConstants.computerColor; // "Computer's Turn" = red
    }
    
    // Draw messages and other default cases
    return Colors.black;
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
    if (previousStatus.contains('You win')) {
      // Player won - Computer goes first next game
      _gameState.playerGoesFirst = false;
      _gameState.isPlayerTurn = false;
    } else if (previousStatus.contains('Computer wins')) {
      // Computer won - Player goes first next game
      _gameState.playerGoesFirst = true;
      _gameState.isPlayerTurn = true;
    } else if (previousStatus.contains('draw')) {
      // Tie - Other player goes first next game
      _gameState.playerGoesFirst = !_gameState.playerGoesFirst;
      _gameState.isPlayerTurn = _gameState.playerGoesFirst;
    }
  }
}
