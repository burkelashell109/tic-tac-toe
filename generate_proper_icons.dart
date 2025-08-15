import 'dart:io';
import 'package:image/image.dart' as img;

/// Proper icon generator using the image package to create valid PNG files
class ProperIconGenerator {
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

  /// Generate a proper PNG image using the image package
  static img.Image generateTicTacToeIcon(int size) {
    // Create a new image with blue background
    final image = img.Image(width: size, height: size);
    
    // Fill with blue background
    img.fill(image, color: img.ColorRgb8(33, 150, 243)); // Material Blue
    
    // Calculate grid parameters
    final third = size ~/ 3;
    final lineWidth = (size * 0.02).round().clamp(1, 10);
    
    // Draw white grid lines
    final white = img.ColorRgb8(255, 255, 255);
    
    // Vertical lines
    for (int x = third - lineWidth ~/ 2; x <= third + lineWidth ~/ 2; x++) {
      if (x >= 0 && x < size) {
        for (int y = size ~/ 10; y < size - size ~/ 10; y++) {
          if (y >= 0 && y < size) {
            image.setPixel(x, y, white);
          }
        }
      }
    }
    
    for (int x = (third * 2) - lineWidth ~/ 2; x <= (third * 2) + lineWidth ~/ 2; x++) {
      if (x >= 0 && x < size) {
        for (int y = size ~/ 10; y < size - size ~/ 10; y++) {
          if (y >= 0 && y < size) {
            image.setPixel(x, y, white);
          }
        }
      }
    }
    
    // Horizontal lines
    for (int y = third - lineWidth ~/ 2; y <= third + lineWidth ~/ 2; y++) {
      if (y >= 0 && y < size) {
        for (int x = size ~/ 10; x < size - size ~/ 10; x++) {
          if (x >= 0 && x < size) {
            image.setPixel(x, y, white);
          }
        }
      }
    }
    
    for (int y = (third * 2) - lineWidth ~/ 2; y <= (third * 2) + lineWidth ~/ 2; y++) {
      if (y >= 0 && y < size) {
        for (int x = size ~/ 10; x < size - size ~/ 10; x++) {
          if (x >= 0 && x < size) {
            image.setPixel(x, y, white);
          }
        }
      }
    }
    
    // Draw the strategic game pattern:
    // X | _ | X
    // _ | O | X  
    // O | _ | _
    
    // X in top-left (0,0)
    _drawX(image, 0, 0, third, white);
    
    // X in top-right (0,2)
    _drawX(image, 0, 2, third, white);
    
    // O in center (1,1)
    _drawO(image, 1, 1, third, img.ColorRgb8(255, 87, 34)); // Orange
    
    // X in middle-right (1,2)
    _drawX(image, 1, 2, third, white);
    
    // O in bottom-left (2,0)
    _drawO(image, 2, 0, third, img.ColorRgb8(255, 87, 34)); // Orange
    
    return image;
  }
  
  static void _drawX(img.Image image, int row, int col, int cellSize, img.Color color) {
    final left = col * cellSize + cellSize ~/ 5;
    final top = row * cellSize + cellSize ~/ 5;
    final right = left + cellSize * 3 ~/ 5;
    final bottom = top + cellSize * 3 ~/ 5;
    final lineWidth = (cellSize * 0.08).round().clamp(1, 10);
    
    // Draw diagonal lines for X
    for (int i = 0; i < (right - left); i++) {
      for (int w = -lineWidth ~/ 2; w <= lineWidth ~/ 2; w++) {
        // Main diagonal (\)
        final x1 = left + i;
        final y1 = top + i + w;
        if (x1 >= 0 && x1 < image.width && y1 >= 0 && y1 < image.height) {
          image.setPixel(x1, y1, color);
        }
        
        // Anti-diagonal (/)
        final x2 = left + i;
        final y2 = bottom - i + w;
        if (x2 >= 0 && x2 < image.width && y2 >= 0 && y2 < image.height) {
          image.setPixel(x2, y2, color);
        }
      }
    }
  }
  
  static void _drawO(img.Image image, int row, int col, int cellSize, img.Color color) {
    final centerX = col * cellSize + cellSize ~/ 2;
    final centerY = row * cellSize + cellSize ~/ 2;
    final radius = cellSize ~/ 4;
    final lineWidth = (cellSize * 0.06).round().clamp(1, 8);
    
    // Draw circle using Bresenham-like algorithm
    for (int angle = 0; angle < 360; angle += 1) {
      final radian = angle * 3.14159 / 180;
      for (int r = radius - lineWidth; r <= radius + lineWidth; r++) {
        final x = centerX + (r * cos(radian)).round();
        final y = centerY + (r * sin(radian)).round();
        if (x >= 0 && x < image.width && y >= 0 && y < image.height) {
          image.setPixel(x, y, color);
        }
      }
    }
  }
  
  static double cos(double x) {
    // Simple cosine approximation
    while (x > 3.14159 * 2) {
      x -= 3.14159 * 2;
    }
    while (x < 0) {
      x += 3.14159 * 2;
    }
    
    if (x <= 3.14159 / 2) {
      return 1 - (x * x) / 2 + (x * x * x * x) / 24;
    } else if (x <= 3.14159) {
      x = 3.14159 - x;
      return -(1 - (x * x) / 2 + (x * x * x * x) / 24);
    } else if (x <= 3.14159 * 3 / 2) {
      x = x - 3.14159;
      return -(1 - (x * x) / 2 + (x * x * x * x) / 24);
    } else {
      x = 3.14159 * 2 - x;
      return 1 - (x * x) / 2 + (x * x * x * x) / 24;
    }
  }
  
  static double sin(double x) {
    return cos(x - 3.14159 / 2);
  }

  /// Save Android icons
  static Future<void> saveAndroidIcons() async {
    print('🤖 Generating proper Android icons...');
    
    for (final entry in androidIconSizes.entries) {
      final folderName = entry.key;
      final size = entry.value;
      
      try {
        final icon = generateTicTacToeIcon(size);
        final directory = Directory('android/app/src/main/res/$folderName');
        
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        
        final file = File('${directory.path}/ic_launcher.png');
        await file.writeAsBytes(img.encodePng(icon));
        print('  ✅ Saved $folderName/ic_launcher.png (${size}x$size)');
      } catch (e) {
        print('  ⚠️  Could not save $folderName/ic_launcher.png: $e');
      }
    }
  }

  /// Save iOS icons
  static Future<void> saveIosIcons() async {
    print('🍎 Generating proper iOS icons...');
    
    try {
      final appIconDir = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
      if (!await appIconDir.exists()) {
        await appIconDir.create(recursive: true);
      }
      
      for (final entry in iosIconSizes.entries) {
        final iconName = entry.key;
        final size = entry.value;
        
        try {
          final icon = generateTicTacToeIcon(size);
          final file = File('${appIconDir.path}/$iconName.png');
          await file.writeAsBytes(img.encodePng(icon));
          print('  ✅ Saved AppIcon.appiconset/$iconName.png (${size}x$size)');
        } catch (e) {
          print('  ⚠️  Could not save $iconName.png: $e');
        }
      }
      
      // Create Contents.json for iOS
      await _createContentsJson(appIconDir);
      
    } catch (e) {
      print('  ⚠️  Error generating iOS icons: $e');
    }
  }

  /// Save Web icons
  static Future<void> saveWebIcons() async {
    print('🌐 Generating proper web icons...');
    
    try {
      // Create web/icons directory
      final iconsDir = Directory('web/icons');
      if (!await iconsDir.exists()) {
        await iconsDir.create(recursive: true);
      }
      
      for (final entry in webIconSizes.entries) {
        final iconName = entry.key;
        final size = entry.value;
        
        try {
          final icon = generateTicTacToeIcon(size);
          final file = iconName == 'favicon' 
              ? File('web/favicon.png')
              : File('${iconsDir.path}/$iconName.png');
          await file.writeAsBytes(img.encodePng(icon));
          
          final location = iconName == 'favicon' ? 'web/favicon.png' : 'web/icons/$iconName.png';
          print('  ✅ Saved $location (${size}x$size)');
        } catch (e) {
          print('  ⚠️  Could not save $iconName.png: $e');
        }
      }
      
    } catch (e) {
      print('  ⚠️  Error generating web icons: $e');
    }
  }

  static Future<void> _createContentsJson(Directory appIconDir) async {
    const contentsJson = '''
{
  "images" : [
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20",
      "filename" : "icon-20@2x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20",
      "filename" : "icon-20@3x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29",
      "filename" : "icon-29@2x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29",
      "filename" : "icon-29@3x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40",
      "filename" : "icon-40@2x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40",
      "filename" : "icon-40@3x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60",
      "filename" : "icon-60@2x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60",
      "filename" : "icon-60@3x.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20",
      "filename" : "icon-20.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20",
      "filename" : "icon-20@2x.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29",
      "filename" : "icon-29.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29",
      "filename" : "icon-29@2x.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40",
      "filename" : "icon-40.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40",
      "filename" : "icon-40@2x.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76",
      "filename" : "icon-76.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76",
      "filename" : "icon-76@2x.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5",
      "filename" : "icon-83.5@2x.png"
    },
    {
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024",
      "filename" : "icon-1024.png"
    }
  ],
  "info" : {
    "author" : "tic-tac-toe",
    "version" : 1
  }
}
''';

    try {
      final file = File('${appIconDir.path}/Contents.json');
      await file.writeAsString(contentsJson);
      print('  ✅ Created Contents.json for iOS');
    } catch (e) {
      print('  ⚠️  Could not create Contents.json: $e');
    }
  }

  /// Generate all platform icons
  static Future<void> generateAllIcons() async {
    print('🎯 Starting PROPER icon generation for all platforms...\n');
    
    try {
      await saveAndroidIcons();
      print('');
      
      await saveIosIcons();
      print('');
      
      await saveWebIcons();
      print('');
      
      print('🎉 PROPER icon generation completed!');
      print('\n📱 All platforms now have valid PNG files:');
      print('   Android: android/app/src/main/res/mipmap-*/ic_launcher.png');
      print('   iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/');
      print('   Web: web/icons/ and web/favicon.png');
      print('\n✅ These are now proper PNG bitmap files!');
      
    } catch (e) {
      print('❌ Error generating icons: $e');
    }
  }
}

/// Main function to run the proper icon generation
void main() async {
  await ProperIconGenerator.generateAllIcons();
}
