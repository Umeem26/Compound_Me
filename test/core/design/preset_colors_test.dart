import 'package:compound_me/core/database/seed.dart';
import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.2 contrast ratio between two opaque colors.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('preset icon contrast (WCAG 1.4.11, at least 3:1)', () {
    final themes = {
      Brightness.light: AppColors.light,
      Brightness.dark: AppColors.dark,
    };

    for (final MapEntry(key: brightness, value: colors) in themes.entries) {
      for (final preset in AppPresetColor.values) {
        test('${preset.key} in ${brightness.name} theme', () {
          final icon = preset.foreground(brightness);
          // A badge sits on a card (surface) or directly on the screen (bg).
          for (final base in [colors.surface, colors.bg]) {
            final tint = Color.alphaBlend(preset.background(brightness), base);
            expect(
              _contrast(icon, tint),
              greaterThanOrEqualTo(3),
              reason: '${preset.key} on $base',
            );
          }
        });
      }
    }
  });

  test('stored keys resolve to their preset, unknown keys to teal', () {
    for (final preset in AppPresetColor.values) {
      expect(AppPresetColor.fromKey(preset.key), preset);
    }
    expect(AppPresetColor.fromKey('missing'), AppPresetColor.teal);
  });

  test('neighbouring default categories never share a color (S-42)', () {
    for (final kind in CategoryKind.values) {
      final colors = [
        for (final c in defaultCategories)
          if (c.kind == kind) c.colorKey,
      ];
      for (var i = 1; i < colors.length; i++) {
        expect(
          colors[i],
          isNot(colors[i - 1]),
          reason: '${kind.name} #$i repeats the color above it',
        );
      }
    }
  });
}
