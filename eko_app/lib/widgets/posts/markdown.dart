import 'package:eko_app/providers/current_user_provider.dart';
import 'package:eko_app/utilities/constants.dart' as c;
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

enum MarkdownType { base, title }

const String _mathBlockPlaceholderPrefix = 'eko_math_blk_';
const String _mathInlinePlaceholderPattern = r'⟦m(\d+)⟧';

String _mathPhInline(int idx) => '\u27e6m$idx\u27e7';

String _mathPhBlock(int idx) => '${_mathBlockPlaceholderPrefix}$idx';

Future<void> _defaultTagPressed(
  String username,
  BuildContext context,
  WidgetRef ref,
) async {
  if (ref.watch(currentUserProvider).user.username == username) {
    context.go('/profile');
  } else {
    context.push('/users/$username');
  }
}

class _MathSeg {
  final String tex;
  final bool block;
  const _MathSeg(this.tex, this.block);
}

bool _dollarEscaped(String s, int i) {
  var n = 0;
  for (var k = i - 1; k >= 0 && s.codeUnitAt(k) == 0x5C; k--) {
    n++;
  }
  return n.isOdd;
}

int? _findCloseDoubleDollar(String s, int from) {
  var p = from;
  while (p + 1 < s.length) {
    if (s.codeUnitAt(p) == 0x24 && s.codeUnitAt(p + 1) == 0x24) {
      return p;
    }
    p++;
  }
  return null;
}

void _ensureBlankLine(StringBuffer out) {
  if (out.isNotEmpty) {
    final text = out.toString();
    if (!text.endsWith('\n\n')) {
      out.write(text.endsWith('\n') ? '\n' : '\n\n');
    }
  }
}

/// Masks $...$ inline and $$...$$ block math with placeholders
/// and returns the masked content plus captured segments.
({String masked, List<_MathSeg> pieces}) _maskMathSegments(String input) {
  final pieces = <_MathSeg>[];
  final out = StringBuffer();
  var i = 0;
  while (i < input.length) {
    if (!_dollarEscaped(input, i) &&
        i + 1 < input.length &&
        input.codeUnitAt(i) == 0x24 &&
        input.codeUnitAt(i + 1) == 0x24) {
      final close = _findCloseDoubleDollar(input, i + 2);
      if (close != null) {
        final tex = input.substring(i + 2, close).trim();
        final idx = pieces.length;
        pieces.add(_MathSeg(tex, true));
        _ensureBlankLine(out);
        out.write('${_mathPhBlock(idx)}\n\n');
        i = close + 2;
        continue;
      }
    }
    if (!_dollarEscaped(input, i) &&
        input.codeUnitAt(i) == 0x24 &&
        (i + 1 >= input.length || input.codeUnitAt(i + 1) != 0x24)) {
      final end = input.indexOf('\$', i + 1);
      if (end != -1) {
        final tex = input.substring(i + 1, end);
        if (tex.isNotEmpty && !tex.contains('\n')) {
          final idx = pieces.length;
          pieces.add(_MathSeg(tex, false));
          out.write(_mathPhInline(idx));
          i = end + 1;
          continue;
        }
      }
    }
    out.write(input.substring(i, i + 1));
    i++;
  }
  return (masked: out.toString(), pieces: pieces);
}

String _format(String content) {
  final RegExp mentionRegex = RegExp(r'(@[a-z0-9_]{3,24})');
  final RegExp tickerRegex = RegExp(r'(\$[A-Z]{2,5}\b)');

  return content
      .replaceAllMapped(mentionRegex, (match) {
        String y = match[0]!;
        return '[$y]($y)';
      })
      .replaceAllMapped(tickerRegex, (match) {
        String y = match[0]!;
        return '[$y](${c.finance}${y.substring(1)}/)';
      });
}

MarkdownStyleSheet getTheme(BuildContext context, MarkdownType type) {
  final theme = MarkdownStyleSheet.fromTheme(Theme.of(context));
  final plain = type == MarkdownType.base
      ? theme.p
      : theme.p?.copyWith(fontSize: 16);
  final base = theme.copyWith(
    blockSpacing: 0.0,
    p: plain,
    code: plain?.copyWith(fontFamily: 'MartianMono'),
    h1: theme.p?.copyWith(fontSize: 16),
    h2: plain,
    h3: plain,
    h4: plain,
    h5: plain,
    h6: plain,
  );
  if (type == MarkdownType.title) {
    return base.copyWith(h1: plain);
  }
  return base;
}

class _LatexBlockPlaceholderSyntax extends md.BlockSyntax {
  const _LatexBlockPlaceholderSyntax();

  static final RegExp _line = RegExp(
    '^\\s*${_mathBlockPlaceholderPrefix}(\\d+)\\s*\$',
  );

  @override
  RegExp get pattern => _line;

  @override
  md.Node? parse(md.BlockParser parser) {
    final m = _line.firstMatch(parser.current.content)!;
    parser.advance();
    return md.Element.text('eko_math_block', m.group(1)!);
  }
}

class _LegacyBracketBlockSyntax extends md.BlockSyntax {
  const _LegacyBracketBlockSyntax();

  static final RegExp _line = RegExp(r'^\s*[\u27e6]B(\d+)[\u27e7]\s*$');

  @override
  RegExp get pattern => _line;

  @override
  md.Node? parse(md.BlockParser parser) {
    final m = _line.firstMatch(parser.current.content)!;
    parser.advance();
    return md.Element.text('eko_math_block', m.group(1)!);
  }
}

class _LatexInlinePlaceholderSyntax extends md.InlineSyntax {
  _LatexInlinePlaceholderSyntax()
    : super(_mathInlinePlaceholderPattern, startCharacter: 0x27e6);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('eko_math_inline', match.group(1)!));
    return true;
  }
}

TextStyle _mathTextStyle(
  BuildContext context,
  TextStyle? preferredStyle, {
  double fontSizeFactor = 1,
}) {
  final theme = Theme.of(context);
  var t = preferredStyle ?? theme.textTheme.bodyMedium ?? const TextStyle();
  if (t.inherit) {
    t = DefaultTextStyle.of(context).style.merge(t);
  }
  if (t.color == null) {
    t = t.merge(TextStyle(color: theme.colorScheme.onSurface));
  }
  final fs = t.fontSize ?? theme.textTheme.bodyMedium?.fontSize ?? 16.0;
  return t.copyWith(fontSize: fs * fontSizeFactor);
}

Widget _mathBlockContent(
  BuildContext context,
  String tex,
  TextStyle? preferredStyle,
) {
  final style = _mathTextStyle(context, preferredStyle, fontSizeFactor: 1.08);
  return FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.center,
    child: Math.tex(
      tex,
      mathStyle: MathStyle.display,
      textStyle: style,
      onErrorFallback: (e) =>
          Text(tex, textAlign: TextAlign.center, style: style),
    ),
  );
}

Widget _mathInlineContent(
  BuildContext context,
  String tex,
  TextStyle? preferredStyle,
) {
  final style = _mathTextStyle(context, preferredStyle);
  return Math.tex(
    tex,
    mathStyle: MathStyle.text,
    textStyle: style,
    onErrorFallback: (e) => Text(tex, style: style),
  );
}

class _LatexBlockBuilder extends MarkdownElementBuilder {
  _LatexBlockBuilder(this.pieces);
  final List<_MathSeg> pieces;

  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final i = int.tryParse(element.textContent);
    if (i == null || i < 0 || i >= pieces.length || !pieces[i].block) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: _mathBlockContent(context, pieces[i].tex, preferredStyle),
      ),
    );
  }
}

class _LatexInlineBuilder extends MarkdownElementBuilder {
  _LatexInlineBuilder(this.pieces);
  final List<_MathSeg> pieces;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final i = int.tryParse(element.textContent);
    if (i == null || i < 0 || i >= pieces.length || pieces[i].block) {
      return const SizedBox.shrink();
    }
    return Text.rich(
      TextSpan(
        style: preferredStyle,
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: _mathInlineContent(context, pieces[i].tex, preferredStyle),
          ),
        ],
      ),
    );
  }
}

class MarkdownView extends ConsumerWidget {
  final String content;
  final MarkdownType type;
  const MarkdownView({
    super.key,
    required this.content,
    this.type = MarkdownType.base,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prep = _maskMathSegments(content);
    final data = _format(prep.masked);
    return MarkdownBody(
      key: ValueKey(data),
      onTapLink: (_, uri, __) {
        if (uri?.startsWith('@') ?? false) {
          _defaultTagPressed(uri!.substring(1), context, ref);
        } else if (uri != null) {
          try {
            final u = Uri.parse(uri);
            launchUrl(u, mode: LaunchMode.externalApplication);
          } finally {}
        }
      },
      imageBuilder: (_, __, ___) => SizedBox(),
      checkboxBuilder: (checked) {
        final colors = Theme.of(context).colorScheme;
        final borderColor = checked
            ? colors.onSurface
            : colors.onSurface.withAlpha(128);
        final fillColor = checked ? colors.onSurface : Colors.transparent;

        return Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 14, height: 14),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(width: 1.6, color: borderColor),
              ),
              child: checked
                  ? Center(
                      child: Icon(
                        Icons.check,
                        size: 12,
                        color: colors.onPrimary,
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
      blockSyntaxes: const [
        _LatexBlockPlaceholderSyntax(),
        _LegacyBracketBlockSyntax(),
      ],
      inlineSyntaxes: [_LatexInlinePlaceholderSyntax()],
      builders: {
        'eko_math_block': _LatexBlockBuilder(prep.pieces),
        'eko_math_inline': _LatexInlineBuilder(prep.pieces),
      },
      data: data,
      styleSheet: getTheme(context, type),
    );
  }
}
