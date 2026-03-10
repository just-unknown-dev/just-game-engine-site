import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_game_engine_site/app/core/theme/app_colors.dart';
import 'package:just_game_engine_site/app/core/widgets/section_header.dart';
import 'package:just_game_engine_site/app/core/widgets/code_block.dart';

void main() {
  group('SectionHeader', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SectionHeader(title: 'Test Title')),
        ),
      );
      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('renders optional subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionHeader(title: 'T', subtitle: 'Sub text'),
          ),
        ),
      );
      expect(find.text('Sub text'), findsOneWidget);
    });
  });

  group('CodeBlock', () {
    testWidgets('renders as RichText with code', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CodeBlock(code: 'void main() {}')),
        ),
      );
      // CodeBlock renders code via RichText with TextSpans
      expect(find.byType(RichText), findsWidgets);
    });

    testWidgets('shows copy button via InkWell with Icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CodeBlock(code: 'print("hello");')),
        ),
      );
      expect(find.byType(InkWell), findsWidgets);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });
  });

  group('AppColors', () {
    test('accent is coral red (#F5746F)', () {
      expect(AppColors.accent, const Color(0xFFF5746F));
    });

    test('bgDark is defined', () {
      expect(AppColors.bgDark, isA<Color>());
    });

    test('surface color is defined', () {
      expect(AppColors.surface, isA<Color>());
    });

    test('textPrimary is defined', () {
      expect(AppColors.textPrimary, isA<Color>());
    });

    test('codeBg is defined', () {
      expect(AppColors.codeBg, isA<Color>());
    });

    test('border is defined', () {
      expect(AppColors.border, isA<Color>());
    });
  });
}
