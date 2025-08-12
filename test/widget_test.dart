// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tic_tac_toe/main.dart';

void main() {
  testWidgets('Tic Tac Toe game loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TicTacToeApp());

    // Verify that the app title is present.
    expect(find.text('Tic Tac Toe'), findsOneWidget);
    
    // Verify that initial turn indicator shows Your Turn
    expect(find.text('Your Turn'), findsOneWidget);
    
    // Verify that the score display is present
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Computer'), findsOneWidget);
    
    // Verify that there are game board cells (using Container widgets for grid cells)
    expect(find.byType(Container), findsAtLeast(9));
  });

  testWidgets('Tic Tac Toe game play test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TicTacToeApp());

    // Tap the first cell (top-left)
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();

    // Verify that X appeared in the cell and turn changed to Computer
    expect(find.text('X'), findsOneWidget);
    expect(find.text('Computer is thinking...'), findsOneWidget);
    
    // Wait for computer move and verify the computer played
    await tester.pumpAndSettle(const Duration(milliseconds: 1000));
    
    // Verify that O appeared and turn changed back to player
    expect(find.text('O'), findsOneWidget);
    expect(find.text('Your Turn'), findsOneWidget);
  });
}
