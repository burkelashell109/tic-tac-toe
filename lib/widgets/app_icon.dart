import 'package:flutter/material.dart';

class TicTacToeAppIcon extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color gridColor;
  final Color xColor;
  final Color oColor;

  const TicTacToeAppIcon({
    super.key,
    this.size = 512,
    this.backgroundColor = const Color(0xFF2196F3), // Blue background
    this.gridColor = Colors.white,
    this.xColor = Colors.white,
    this.oColor = const Color(0xFFFF5722), // Orange/red for O
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.2), // Rounded corners
      ),
      child: CustomPaint(
        painter: TicTacToeIconPainter(
          gridColor: gridColor,
          xColor: xColor,
          oColor: oColor,
        ),
      ),
    );
  }
}

class TicTacToeIconPainter extends CustomPainter {
  final Color gridColor;
  final Color xColor;
  final Color oColor;

  TicTacToeIconPainter({
    required this.gridColor,
    required this.xColor,
    required this.oColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double gridSize = size.width * 0.7; // 70% of the container
    final double gridOffset = (size.width - gridSize) / 2;
    final double cellSize = gridSize / 3;
    final double strokeWidth = size.width * 0.02;

    // Paint for grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw grid lines
    // Vertical lines
    for (int i = 1; i < 3; i++) {
      final double x = gridOffset + (i * cellSize);
      canvas.drawLine(
        Offset(x, gridOffset),
        Offset(x, gridOffset + gridSize),
        gridPaint,
      );
    }

    // Horizontal lines
    for (int i = 1; i < 3; i++) {
      final double y = gridOffset + (i * cellSize);
      canvas.drawLine(
        Offset(gridOffset, y),
        Offset(gridOffset + gridSize, y),
        gridPaint,
      );
    }

    // Draw X and O symbols
    // Pattern: X in (0,0), O in (1,1), X in (2,0), O in (0,2)
    //  X |   | X
    // ---|---|---
    //    | O |  
    // ---|---|---
    //  O |   |  
    
    final double symbolSize = cellSize * 0.6;
    final double symbolStrokeWidth = size.width * 0.025;
    
    // Paint for X
    final xPaint = Paint()
      ..color = xColor
      ..strokeWidth = symbolStrokeWidth
      ..strokeCap = StrokeCap.round;

    // Paint for O
    final oPaint = Paint()
      ..color = oColor
      ..strokeWidth = symbolStrokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw X at (0,0)
    _drawX(canvas, xPaint, gridOffset + cellSize * 0.5, gridOffset + cellSize * 0.5, symbolSize);
    
    // Draw O at (1,1)
    _drawO(canvas, oPaint, gridOffset + cellSize * 1.5, gridOffset + cellSize * 1.5, symbolSize);
    
    // Draw X at (2,0)
    _drawX(canvas, xPaint, gridOffset + cellSize * 2.5, gridOffset + cellSize * 0.5, symbolSize);
    
    // Draw O at (0,2)
    _drawO(canvas, oPaint, gridOffset + cellSize * 0.5, gridOffset + cellSize * 2.5, symbolSize);
  }

  void _drawX(Canvas canvas, Paint paint, double centerX, double centerY, double size) {
    final double halfSize = size / 2;
    
    // Draw first diagonal line (\)
    canvas.drawLine(
      Offset(centerX - halfSize, centerY - halfSize),
      Offset(centerX + halfSize, centerY + halfSize),
      paint,
    );
    
    // Draw second diagonal line (/)
    canvas.drawLine(
      Offset(centerX + halfSize, centerY - halfSize),
      Offset(centerX - halfSize, centerY + halfSize),
      paint,
    );
  }

  void _drawO(Canvas canvas, Paint paint, double centerX, double centerY, double size) {
    final double radius = size / 2;
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
