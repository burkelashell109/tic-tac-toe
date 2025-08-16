import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom painter for the tic-tac-toe app icon
class TicTacToeIconPainter extends CustomPainter {
  final Color backgroundColor;
  final Color gridColor;
  final Color xColor;
  final Color oColor;

  TicTacToeIconPainter({
    this.backgroundColor = const Color(0xFF2196F3),
    this.gridColor = Colors.white,
    this.xColor = Colors.white,
    this.oColor = const Color(0xFFFF5722),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Background with rounded corners
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.15),
    );
    canvas.drawRRect(backgroundRect, backgroundPaint);

    // Grid lines
    paint.color = gridColor;
    paint.strokeWidth = size.width * 0.02;

    final third = size.width / 3;
    
    // Vertical lines
    canvas.drawLine(
      Offset(third, size.height * 0.1),
      Offset(third, size.height * 0.9),
      paint,
    );
    canvas.drawLine(
      Offset(third * 2, size.height * 0.1),
      Offset(third * 2, size.height * 0.9),
      paint,
    );

    // Horizontal lines
    canvas.drawLine(
      Offset(size.width * 0.1, third),
      Offset(size.width * 0.9, third),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.1, third * 2),
      Offset(size.width * 0.9, third * 2),
      paint,
    );

    // X's and O's
    paint.strokeWidth = size.width * 0.04;

    // Draw X in top-left (0,0)
    paint.color = xColor;
    _drawX(canvas, 0, 0, third, paint);

    // Draw O in top-center (0,1)
    paint.color = oColor;
    _drawO(canvas, 0, 1, third, paint);

    // Draw X in center (1,1)
    paint.color = xColor;
    _drawX(canvas, 1, 1, third, paint);

    // Draw O in bottom-left (2,0)
    paint.color = oColor;
    _drawO(canvas, 2, 0, third, paint);

    // Draw X in bottom-right (2,2)
    paint.color = xColor;
    _drawX(canvas, 2, 2, third, paint);
  }

  void _drawX(Canvas canvas, int row, int col, double cellSize, Paint paint) {
    final left = col * cellSize + cellSize * 0.2;
    final top = row * cellSize + cellSize * 0.2;
    final right = left + cellSize * 0.6;
    final bottom = top + cellSize * 0.6;

    canvas.drawLine(Offset(left, top), Offset(right, bottom), paint);
    canvas.drawLine(Offset(right, top), Offset(left, bottom), paint);
  }

  void _drawO(Canvas canvas, int row, int col, double cellSize, Paint paint) {
    final centerX = col * cellSize + cellSize / 2;
    final centerY = row * cellSize + cellSize / 2;
    final radius = cellSize * 0.25;

    canvas.drawCircle(Offset(centerX, centerY), radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A utility class to generate and save app icons to proper platform folders
class IconSaver {
  static const Map<String, int> androidIconSizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  static const Map<String, int> iosIconSizes = {
    'icon-20': 20,
    'icon-20@2x': 40,
    'icon-20@3x': 60,
    'icon-29': 29,
    'icon-29@2x': 58,
    'icon-29@3x': 87,
    'icon-40': 40,
    'icon-40@2x': 80,
    'icon-40@3x': 120,
    'icon-60@2x': 120,
    'icon-60@3x': 180,
    'icon-76': 76,
    'icon-76@2x': 152,
    'icon-83.5@2x': 167,
    'icon-1024': 1024,
  };

  static const Map<String, int> webIconSizes = {
    'Icon-192': 192,
    'Icon-512': 512,
    'favicon': 32,
  };

  /// Generate PNG data from the TicTacToeIconPainter
  static Future<Uint8List> generateIconPng(int size) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Create the painter with proper colors
    final painter = TicTacToeIconPainter(
      backgroundColor: const Color(0xFF2196F3),
      gridColor: Colors.white,
      xColor: Colors.white,
      oColor: const Color(0xFFFF5722),
    );
    
    // Paint the icon
    painter.paint(canvas, Size(size.toDouble(), size.toDouble()));
    
    // Convert to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  /// Save icons for Android platform
  static Future<void> saveAndroidIcons() async {
    print('Generating Android icons...');
    
    for (final entry in androidIconSizes.entries) {
      final folderName = entry.key;
      final size = entry.value;
      
      final iconData = await generateIconPng(size);
      final directory = Directory('android/app/src/main/res/$folderName');
      
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      
      final file = File('${directory.path}/ic_launcher.png');
      await file.writeAsBytes(iconData);
      print('✅ Saved $folderName/ic_launcher.png (${size}x$size)');
    }
  }

  /// Save icons for iOS platform
  static Future<void> saveIosIcons() async {
    print('Generating iOS icons...');
    
    // Create the AppIcon.appiconset directory
    final appIconDir = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
    if (!await appIconDir.exists()) {
      await appIconDir.create(recursive: true);
    }
    
    // Generate icons
    for (final entry in iosIconSizes.entries) {
      final iconName = entry.key;
      final size = entry.value;
      
      final iconData = await generateIconPng(size);
      final file = File('${appIconDir.path}/$iconName.png');
      await file.writeAsBytes(iconData);
      print('✅ Saved AppIcon.appiconset/$iconName.png (${size}x$size)');
    }
    
    // Create Contents.json for iOS
    await _createIosContentsJson(appIconDir);
  }

  /// Save icons for Web platform
  static Future<void> saveWebIcons() async {
    print('Generating Web icons...');
    
    // Ensure icons directory exists
    final iconsDir = Directory('web/icons');
    if (!await iconsDir.exists()) {
      await iconsDir.create(recursive: true);
    }
    
    for (final entry in webIconSizes.entries) {
      final iconName = entry.key;
      final size = entry.value;
      
      final iconData = await generateIconPng(size);
      
      String fileName;
      if (iconName == 'favicon') {
        fileName = 'web/favicon.png';
      } else {
        fileName = 'web/icons/$iconName.png';
      }
      
      final file = File(fileName);
      await file.writeAsBytes(iconData);
      print('✅ Saved $fileName (${size}x$size)');
    }
  }

  /// Create Contents.json for iOS AppIcon.appiconset
  static Future<void> _createIosContentsJson(Directory appIconDir) async {
    const contentsJson = '''
{
  "images": [
    {
      "filename": "icon-20@2x.png",
      "idiom": "iphone",
      "scale": "2x",
      "size": "20x20"
    },
    {
      "filename": "icon-20@3x.png",
      "idiom": "iphone",
      "scale": "3x",
      "size": "20x20"
    },
    {
      "filename": "icon-29@2x.png",
      "idiom": "iphone",
      "scale": "2x",
      "size": "29x29"
    },
    {
      "filename": "icon-29@3x.png",
      "idiom": "iphone",
      "scale": "3x",
      "size": "29x29"
    },
    {
      "filename": "icon-40@2x.png",
      "idiom": "iphone",
      "scale": "2x",
      "size": "40x40"
    },
    {
      "filename": "icon-40@3x.png",
      "idiom": "iphone",
      "scale": "3x",
      "size": "40x40"
    },
    {
      "filename": "icon-60@2x.png",
      "idiom": "iphone",
      "scale": "2x",
      "size": "60x60"
    },
    {
      "filename": "icon-60@3x.png",
      "idiom": "iphone",
      "scale": "3x",
      "size": "60x60"
    },
    {
      "filename": "icon-20.png",
      "idiom": "ipad",
      "scale": "1x",
      "size": "20x20"
    },
    {
      "filename": "icon-20@2x.png",
      "idiom": "ipad",
      "scale": "2x",
      "size": "20x20"
    },
    {
      "filename": "icon-29.png",
      "idiom": "ipad",
      "scale": "1x",
      "size": "29x29"
    },
    {
      "filename": "icon-29@2x.png",
      "idiom": "ipad",
      "scale": "2x",
      "size": "29x29"
    },
    {
      "filename": "icon-40.png",
      "idiom": "ipad",
      "scale": "1x",
      "size": "40x40"
    },
    {
      "filename": "icon-40@2x.png",
      "idiom": "ipad",
      "scale": "2x",
      "size": "40x40"
    },
    {
      "filename": "icon-76.png",
      "idiom": "ipad",
      "scale": "1x",
      "size": "76x76"
    },
    {
      "filename": "icon-76@2x.png",
      "idiom": "ipad",
      "scale": "2x",
      "size": "76x76"
    },
    {
      "filename": "icon-83.5@2x.png",
      "idiom": "ipad",
      "scale": "2x",
      "size": "83.5x83.5"
    },
    {
      "filename": "icon-1024.png",
      "idiom": "ios-marketing",
      "scale": "1x",
      "size": "1024x1024"
    }
  ],
  "info": {
    "author": "xcode",
    "version": 1
  }
}''';

    final contentsFile = File('${appIconDir.path}/Contents.json');
    await contentsFile.writeAsString(contentsJson);
    print('✅ Created Contents.json for iOS');
  }

  /// Generate all platform icons
  static Future<void> generateAllIcons() async {
    print('🎯 Starting icon generation for all platforms...\n');
    
    try {
      await saveAndroidIcons();
      print('');
      
      await saveIosIcons();
      print('');
      
      await saveWebIcons();
      print('');
      
      print('🎉 All icons generated successfully!');
      print('\n📱 Platform-specific locations:');
      print('   Android: android/app/src/main/res/mipmap-*/ic_launcher.png');
      print('   iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/');
      print('   Web: web/icons/ and web/favicon.png');
      
    } catch (e) {
      print('❌ Error generating icons: $e');
    }
  }
}

/// Main function to run the icon generation
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IconSaver.generateAllIcons();
  exit(0);
}
