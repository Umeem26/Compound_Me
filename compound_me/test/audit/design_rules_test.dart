// Static audit of the design rules (CLAUDE.md rules 1-3 and 02 §10) over
// the source: values come from lib/core/design, strings from l10n, and no
// gradients, emoji or placeholder comments anywhere.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A number that should have been a token: not 0, not part of a name.
final _looseNumber = RegExp(
  r'(?<![\w.$])(?:[1-9]\d*(?:\.\d+)?|0\.\d+)(?![\w])',
);

/// Token references carry digits (AppSpacing.space2).
final _tokenReference = RegExp(
  r'\bApp(?:Spacing|Sizes|Radius|Opacity|Scale|Durations)\.\w+',
);

/// Constructors whose arguments are layout values.
final _layoutConstructor = RegExp(
  r'\b(?:EdgeInsetsDirectional|EdgeInsets|SizedBox|BorderRadius|Radius|'
  r'Duration)\b[\w.]*\(',
);

final _namedLayoutValue = RegExp(
  r'\b(?:width|height|size|dimension|radius|elevation|thickness|'
  r'strokeWidth|blurRadius|spacing|runSpacing|borderWidth)\s*:\s*'
  r'(?:[1-9]\d*|0\.\d+)\b',
);

const _forbidden = {
  'Color(0x': 'a literal color',
  'Colors.': 'a Material color',
  'fontSize:': 'a literal text size',
};

/// Dart files of the app, as (path, lines) pairs.
List<(String, List<String>)> _sources({required bool outsideDesign}) {
  final files = <(String, List<String>)>[];
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final path = entity.path.replaceAll(r'\', '/');
    if (path.endsWith('.g.dart') || path.contains('l10n/app_localizations')) {
      continue;
    }
    if (outsideDesign && path.startsWith('lib/core/design/')) continue;
    files.add((path, entity.readAsLinesSync()));
  }
  return files;
}

bool _isComment(String line) => line.trimLeft().startsWith('//');

/// The text from [start] (an opening parenthesis) to its closing one.
String _balanced(String text, int start) {
  var depth = 0;
  for (var i = start; i < text.length; i++) {
    if (text[i] == '(') depth++;
    if (text[i] == ')') {
      depth--;
      if (depth == 0) return text.substring(start, i + 1);
    }
  }
  return text.substring(start);
}

void main() {
  group('outside lib/core/design', () {
    test('no literal colors or text sizes', () {
      final found = <String>[];
      for (final (path, lines) in _sources(outsideDesign: true)) {
        for (final (i, line) in lines.indexed) {
          if (_isComment(line)) continue;
          for (final entry in _forbidden.entries) {
            if (line.contains(entry.key)) {
              found.add('$path:${i + 1} ${entry.value}: ${line.trim()}');
            }
          }
        }
      }
      expect(found, isEmpty, reason: found.join('\n'));
    });

    test('no loose spacing, size, radius or duration numbers', () {
      // Layout values live in widgets; domain and data code has its own
      // constants (a 30-day retention is not a design duration).
      bool isUi(String path) =>
          path.contains('/presentation/') ||
          path == 'lib/app.dart' ||
          path.startsWith('lib/core/router/');
      final found = <String>[];
      for (final (path, lines) in _sources(outsideDesign: true)) {
        if (!isUi(path)) continue;
        final code = [
          for (final line in lines)
            if (_isComment(line)) '' else line,
        ].join('\n');
        for (final match in _layoutConstructor.allMatches(code)) {
          final call = _balanced(code, match.end - 1);
          final stripped = call.replaceAll(_tokenReference, '');
          if (_looseNumber.hasMatch(stripped)) {
            final line = code.substring(0, match.start).split('\n').length;
            found.add('$path:$line ${match.group(0)}…) $call');
          }
        }
        for (final (i, line) in lines.indexed) {
          if (_isComment(line)) continue;
          if (_namedLayoutValue.hasMatch(
            line.replaceAll(_tokenReference, ''),
          )) {
            found.add('$path:${i + 1} ${line.trim()}');
          }
        }
      }
      expect(found, isEmpty, reason: found.join('\n'));
    });
  });

  test('no gradients, shadows or blobs anywhere in the app code', () {
    final found = <String>[];
    for (final (path, lines) in _sources(outsideDesign: false)) {
      for (final (i, line) in lines.indexed) {
        if (_isComment(line)) continue;
        if (RegExp(r'Gradient|ImageFilter\.blur|BackdropFilter')
            .hasMatch(line)) {
          found.add('$path:${i + 1} ${line.trim()}');
        }
      }
    }
    expect(found, isEmpty, reason: found.join('\n'));
  });

  test('no emoji in code or translations', () {
    final emoji = RegExp(
      '[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B50}\u{2B06}\u{2B07}\u{FE0F}]',
      unicode: true,
    );
    final found = <String>[];
    final files = [
      for (final e in Directory('lib').listSync(recursive: true))
        if (e is File &&
            (e.path.endsWith('.dart') || e.path.endsWith('.arb')) &&
            !e.path.contains('app_localizations'))
          e,
    ];
    for (final file in files) {
      final text = file.readAsStringSync();
      for (final match in emoji.allMatches(text)) {
        found.add(
          '${file.path}: U+${match.group(0)!.runes.first.toRadixString(16)}',
        );
      }
    }
    expect(found, isEmpty, reason: found.join('\n'));
  });

  test('no placeholder comments, "coming soon" copy or dummy data', () {
    final words = RegExp(
      'PERBAIKAN|AJAIB|SULTAN|segera hadir|coming soon|lorem ipsum|dummy',
      caseSensitive: false,
    );
    final found = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File ||
          !(entity.path.endsWith('.dart') || entity.path.endsWith('.arb'))) {
        continue;
      }
      for (final (i, line) in entity.readAsLinesSync().indexed) {
        if (words.hasMatch(line)) found.add('${entity.path}:${i + 1} $line');
      }
    }
    expect(found, isEmpty, reason: found.join('\n'));
  });

  test('every translation key exists in both languages', () {
    Set<String> keys(String file) => {
      for (final line in File('lib/core/l10n/$file').readAsLinesSync())
        if (RegExp('^  "[A-Za-z0-9]+":').hasMatch(line))
          RegExp('^  "([A-Za-z0-9]+)":').firstMatch(line)!.group(1)!,
    };
    final id = keys('app_id.arb');
    final en = keys('app_en.arb');
    expect(id.difference(en), isEmpty, reason: 'missing in app_en.arb');
    expect(en.difference(id), isEmpty, reason: 'missing in app_id.arb');
  });
}
