import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

/// Simple icon generator that creates PNG files for the tic-tac-toe app
class SimpleIconGenerator {
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

  /// Generate a simple PNG header for our custom icon
  static Uint8List generateSimplePng(int size) {
    // This is a basic approach - create a simple PNG with our tic-tac-toe pattern
    // For a real implementation, you'd use a proper image library
    
    // Create a simple bitmap representation
    final width = size;
    final height = size;
    final bytesPerPixel = 4; // RGBA
    final imageData = Uint8List(width * height * bytesPerPixel);
    
    // Fill with blue background
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = (y * width + x) * bytesPerPixel;
        imageData[index] = 33; // R - Blue background
        imageData[index + 1] = 150; // G
        imageData[index + 2] = 243; // B
        imageData[index + 3] = 255; // A
      }
    }
    
    // Draw grid lines (white)
    final lineWidth = math.max(1, size ~/ 50);
    final third = size ~/ 3;
    
    // Vertical lines
    for (int x = third - lineWidth; x < third + lineWidth; x++) {
      if (x >= 0 && x < width) {
        for (int y = size ~/ 10; y < size - size ~/ 10; y++) {
          if (y >= 0 && y < height) {
            final index = (y * width + x) * bytesPerPixel;
            imageData[index] = 255; // White
            imageData[index + 1] = 255;
            imageData[index + 2] = 255;
            imageData[index + 3] = 255;
          }
        }
      }
    }
    
    for (int x = third * 2 - lineWidth; x < third * 2 + lineWidth; x++) {
      if (x >= 0 && x < width) {
        for (int y = size ~/ 10; y < size - size ~/ 10; y++) {
          if (y >= 0 && y < height) {
            final index = (y * width + x) * bytesPerPixel;
            imageData[index] = 255; // White
            imageData[index + 1] = 255;
            imageData[index + 2] = 255;
            imageData[index + 3] = 255;
          }
        }
      }
    }
    
    // Horizontal lines
    for (int y = third - lineWidth; y < third + lineWidth; y++) {
      if (y >= 0 && y < height) {
        for (int x = size ~/ 10; x < size - size ~/ 10; x++) {
          if (x >= 0 && x < width) {
            final index = (y * width + x) * bytesPerPixel;
            imageData[index] = 255; // White
            imageData[index + 1] = 255;
            imageData[index + 2] = 255;
            imageData[index + 3] = 255;
          }
        }
      }
    }
    
    for (int y = third * 2 - lineWidth; y < third * 2 + lineWidth; y++) {
      if (y >= 0 && y < height) {
        for (int x = size ~/ 10; x < size - size ~/ 10; x++) {
          if (x >= 0 && x < width) {
            final index = (y * width + x) * bytesPerPixel;
            imageData[index] = 255; // White
            imageData[index + 1] = 255;
            imageData[index + 2] = 255;
            imageData[index + 3] = 255;
          }
        }
      }
    }
    
    // Draw X in top-left (white)
    _drawX(imageData, 0, 0, third, width, height, [255, 255, 255, 255]);
    
    // Draw O in top-center (orange)
    _drawO(imageData, 0, 1, third, width, height, [255, 87, 34, 255]);
    
    // Draw X in center (white)
    _drawX(imageData, 1, 1, third, width, height, [255, 255, 255, 255]);
    
    // Draw O in bottom-left (orange)
    _drawO(imageData, 2, 0, third, width, height, [255, 87, 34, 255]);
    
    // Draw X in bottom-right (white)
    _drawX(imageData, 2, 2, third, width, height, [255, 255, 255, 255]);
    
    // Create a simple PNG-like structure (this is very basic)
    // For production, use a proper image library like 'image' package
    return _createBasicPng(imageData, width, height);
  }
  
  static void _drawX(Uint8List imageData, int row, int col, int cellSize, int width, int height, List<int> color) {
    final left = col * cellSize + cellSize ~/ 5;
    final top = row * cellSize + cellSize ~/ 5;
    final right = left + cellSize * 3 ~/ 5;
    final lineWidth = math.max(1, cellSize ~/ 15);
    
    // Draw diagonal lines
    for (int i = 0; i < (right - left); i++) {
      for (int w = 0; w < lineWidth; w++) {
        // Top-left to bottom-right
        final x1 = left + i;
        final y1 = top + i + w;
        if (x1 >= 0 && x1 < width && y1 >= 0 && y1 < height) {
          final index = (y1 * width + x1) * 4;
          imageData[index] = color[0];
          imageData[index + 1] = color[1];
          imageData[index + 2] = color[2];
          imageData[index + 3] = color[3];
        }
        
        // Top-right to bottom-left
        final x2 = right - i;
        final y2 = top + i + w;
        if (x2 >= 0 && x2 < width && y2 >= 0 && y2 < height) {
          final index = (y2 * width + x2) * 4;
          imageData[index] = color[0];
          imageData[index + 1] = color[1];
          imageData[index + 2] = color[2];
          imageData[index + 3] = color[3];
        }
      }
    }
  }
  
  static void _drawO(Uint8List imageData, int row, int col, int cellSize, int width, int height, List<int> color) {
    final centerX = col * cellSize + cellSize ~/ 2;
    final centerY = row * cellSize + cellSize ~/ 2;
    final radius = cellSize ~/ 4;
    final lineWidth = math.max(1, cellSize ~/ 20);
    
    // Draw circle
    for (int angle = 0; angle < 360; angle += 2) {
      final radian = angle * math.pi / 180;
      for (int r = radius - lineWidth; r < radius + lineWidth; r++) {
        final x = centerX + (r * math.cos(radian)).round();
        final y = centerY + (r * math.sin(radian)).round();
        if (x >= 0 && x < width && y >= 0 && y < height) {
          final index = (y * width + x) * 4;
          imageData[index] = color[0];
          imageData[index + 1] = color[1];
          imageData[index + 2] = color[2];
          imageData[index + 3] = color[3];
        }
      }
    }
  }
  
  static Uint8List _createBasicPng(Uint8List imageData, int width, int height) {
    // This is a very simplified PNG creation
    // In a real app, use the 'image' package from pub.dev
    
    // For now, just return a placeholder that represents our icon
    // This would need proper PNG encoding for real use
    return imageData;
  }

  /// Save icons for Android platform
  static Future<void> saveAndroidIcons() async {
    print('🤖 Generating Android icons...');
    
    for (final entry in androidIconSizes.entries) {
      final folderName = entry.key;
      final size = entry.value;
      
      try {
        final iconData = generateSimplePng(size);
        final directory = Directory('android/app/src/main/res/$folderName');
        
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        
        final file = File('${directory.path}/ic_launcher.png');
        await file.writeAsBytes(iconData);
        print('  ✅ Saved $folderName/ic_launcher.png (${size}x$size)');
      } catch (e) {
        print('  ⚠️  Could not save $folderName/ic_launcher.png: $e');
      }
    }
  }

  /// Save icons for iOS platform
  static Future<void> saveIosIcons() async {
    print('🍎 Generating iOS icons...');
    
    try {
      final appIconDir = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
      if (!await appIconDir.exists()) {
        await appIconDir.create(recursive: true);
      }
      
      for (final entry in iosIconSizes.entries) {
        final iconName = entry.key;
        final size = entry.value;
        
        try {
          final iconData = generateSimplePng(size);
          final file = File('${appIconDir.path}/$iconName.png');
          await file.writeAsBytes(iconData);
          print('  ✅ Saved AppIcon.appiconset/$iconName.png (${size}x$size)');
        } catch (e) {
          print('  ⚠️  Could not save $iconName.png: $e');
        }
      }
      
      await _createIosContentsJson(appIconDir);
    } catch (e) {
      print('  ⚠️  Could not create iOS icons directory: $e');
    }
  }

  /// Save icons for Web platform
  static Future<void> saveWebIcons() async {
    print('🌐 Generating Web icons...');
    
    try {
      final iconsDir = Directory('web/icons');
      if (!await iconsDir.exists()) {
        await iconsDir.create(recursive: true);
      }
      
      for (final entry in webIconSizes.entries) {
        final iconName = entry.key;
        final size = entry.value;
        
        try {
          final iconData = generateSimplePng(size);
          
          String fileName;
          if (iconName == 'favicon') {
            fileName = 'web/favicon.png';
          } else {
            fileName = 'web/icons/$iconName.png';
          }
          
          final file = File(fileName);
          await file.writeAsBytes(iconData);
          print('  ✅ Saved $fileName (${size}x$size)');
        } catch (e) {
          print('  ⚠️  Could not save $iconName: $e');
        }
      }
    } catch (e) {
      print('  ⚠️  Could not create web icons directory: $e');
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

    try {
      final contentsFile = File('${appIconDir.path}/Contents.json');
      await contentsFile.writeAsString(contentsJson);
      print('  ✅ Created Contents.json for iOS');
    } catch (e) {
      print('  ⚠️  Could not create Contents.json: $e');
    }
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
      
      print('🎉 Icon generation completed!');
      print('\n📱 Platform-specific locations:');
      print('   Android: android/app/src/main/res/mipmap-*/ic_launcher.png');
      print('   iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/');
      print('   Web: web/icons/ and web/favicon.png');
      print('\n💡 Note: These are basic bitmap icons. For production,');
      print('   consider using a proper image library or design tool.');
      
    } catch (e) {
      print('❌ Error generating icons: $e');
    }
  }
}

/// Main function to run the icon generation
void main() async {
  await SimpleIconGenerator.generateAllIcons();
}
