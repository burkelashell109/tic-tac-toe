import 'package:flutter/material.dart';
import 'widgets/app_icon.dart';

void main() {
  runApp(const IconGeneratorApp());
}

class IconGeneratorApp extends StatelessWidget {
  const IconGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe Icon Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const IconGeneratorScreen(),
    );
  }
}

class IconGeneratorScreen extends StatelessWidget {
  const IconGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tic Tac Toe App Icon'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'App Icon Preview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            // Large preview (512x512)
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const TicTacToeAppIcon(size: 200),
            ),
            
            const SizedBox(height: 40),
            
            // Different sizes row
            const Text(
              'Different Sizes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const TicTacToeAppIcon(size: 48),
                    ),
                    const SizedBox(height: 8),
                    const Text('48x48'),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const TicTacToeAppIcon(size: 72),
                    ),
                    const SizedBox(height: 8),
                    const Text('72x72'),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const TicTacToeAppIcon(size: 96),
                    ),
                    const SizedBox(height: 8),
                    const Text('96x96'),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'This icon shows a tic-tac-toe board with X\'s and O\'s in a classic game position. '
                'The blue background represents your app\'s primary color theme.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
