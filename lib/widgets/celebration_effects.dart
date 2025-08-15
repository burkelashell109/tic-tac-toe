import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/game_constants.dart';

/// Widget that renders win celebration particle effects
class CelebrationEffects extends StatelessWidget {
  final Animation<double> particleAnimation;
  final List<int> winningPositions;
  final String winningSymbol;
  final Color symbolColor;

  const CelebrationEffects({
    super.key,
    required this.particleAnimation,
    required this.winningPositions,
    required this.winningSymbol,
    required this.symbolColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(UIConstants.boardMaxSize, UIConstants.boardMaxSize),
          painter: ParticlePainter(
            progress: particleAnimation.value,
            winningPositions: winningPositions,
            winningSymbol: winningSymbol,
            symbolColor: symbolColor,
          ),
        );
      },
    );
  }
}

/// Custom painter for particle burst effect
class ParticlePainter extends CustomPainter {
  final double progress;
  final List<int> winningPositions;
  final String winningSymbol;
  final Color symbolColor;
  final List<ParticleData> particles = [];

  ParticlePainter({
    required this.progress,
    required this.winningPositions,
    required this.winningSymbol,
    required this.symbolColor,
  }) {
    _generateParticles();
  }

  void _generateParticles() {
    const int particlesPerPosition = 8;
    const double cellSize = UIConstants.boardMaxSize / GameConstants.gridSize;
    
    for (int position in winningPositions) {
      final row = position ~/ GameConstants.gridSize;
      final col = position % GameConstants.gridSize;
      final centerX = (col + 0.5) * cellSize;
      final centerY = (row + 0.5) * cellSize;
      
      for (int i = 0; i < particlesPerPosition; i++) {
        final angle = (i / particlesPerPosition) * 2 * math.pi;
        final velocity = 50.0 + math.Random().nextDouble() * 30.0; // Random velocity
        final size = 8.0 + math.Random().nextDouble() * 6.0; // Random size
        
        particles.add(ParticleData(
          startX: centerX,
          startY: centerY,
          velocityX: math.cos(angle) * velocity,
          velocityY: math.sin(angle) * velocity,
          size: size,
          rotation: math.Random().nextDouble() * 2 * math.pi,
          rotationSpeed: (math.Random().nextDouble() - 0.5) * 10,
        ));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0) return;
    
    final paint = Paint()
      ..color = symbolColor
      ..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      final currentX = particle.startX + particle.velocityX * progress;
      final currentY = particle.startY + particle.velocityY * progress;
      final currentRotation = particle.rotation + particle.rotationSpeed * progress;
      
      // Fade out particles over time
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      paint.color = symbolColor.withOpacity(opacity);
      
      // Save canvas state
      canvas.save();
      
      // Move to particle position and rotate
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation);
      
      // Draw the symbol
      final textPainter = TextPainter(
        text: TextSpan(
          text: winningSymbol,
          style: TextStyle(
            fontSize: particle.size,
            fontWeight: FontWeight.bold,
            color: paint.color,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      
      // Restore canvas state
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

/// Data class for individual particles
class ParticleData {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double size;
  final double rotation;
  final double rotationSpeed;

  ParticleData({
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}
