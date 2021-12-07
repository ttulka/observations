import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/models/documents/style.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'logger.dart';

final _deltaAstEncoder = _DeltaAstEncoder();
final _astPdfEncoder = _AstPdfEncoder();

List<pw.Widget> deltaToPdf(String delta) {
  final List<_Elem> astElements = _deltaAstEncoder.convert(delta);

  if (!kReleaseMode) _AstPdfEncoder._printIt(astElements);

  return _astPdfEncoder.convert(astElements);
}

class _AstPdfEncoder extends Converter<List<_Elem>, List<pw.Widget>> {
  final grayDark = PdfColor.fromHex('#333333');
  final grayLight = PdfColor.fromHex('#666666');
  final grayThy = PdfColor.fromHex('#dddddd');

  @override
  List<pw.Widget> convert(List<_Elem> input) {
    String previousKind = 'none';
    int itemCount = 0;

    return input.map((el) {
      if (previousKind != el.kind) {
        itemCount = 0;
      }
      if (el.attrs != null && (el.attrs!['list'] == 'ordered' || el.attrs!['code-block'] == true)) {
        el.attrs!['count'] = ++itemCount;
      }
      final widget = _blockToWidget(el, previousKind);
      previousKind = el.kind;
      return widget;
    }).toList();
  }

  List<pw.Widget> _childrenToWidget(List<_Elem> elems, _Elem parent) {
    if (elems.isNotEmpty) {
      int i = 0;
      return elems.map((el) => _spanToWidget(el, parent, i++)).toList();
    }
    return [pw.Paragraph(text: parent.text != null ? parent.text! : '')];
  }

  List<_Elem> _childrenBySpaces(List<_Elem> elems) {
    final List<_Elem> results = [];
    for (_Elem el in elems) {
      if (el.text != null) {
        el.text!.split(RegExp(' ')).map((t) => el.cloneWith(t)).forEach((e) => results.add(e));
      }
    }
    return results;
  }

  pw.Widget _spanToWidget(_Elem elem, _Elem parent, int i) {
    final String text = (elem.text ?? '').trim();

    pw.FontWeight? fontWeight;
    pw.FontStyle? fontStyle;
    PdfColor? fontColor;
    double? fontSize;
    pw.Font? fontFamily;
    final List<pw.TextDecoration> decorations = [];

    if (elem.attrs != null) {
      if (elem.attrs!['bold'] == true) {
        fontWeight = pw.FontWeight.bold;
      }
      if (elem.attrs!['italic'] == true) {
        fontStyle = pw.FontStyle.italic;
      }
      if (elem.attrs!['underline'] == true) {
        decorations.add(pw.TextDecoration.underline);
      }
      if (elem.attrs!['strike'] == true) {
        decorations.add(pw.TextDecoration.lineThrough);
      }
      if (elem.attrs!.containsKey('color')) {
        fontColor = PdfColor.fromHex(elem.attrs!['color']);
      }
    }

    if ('header' == parent.kind) {
      fontSize = 25.0 - (parent.attrs!['header'] * 3);
    } else if ('code-block' == parent.kind) {
      fontColor = grayLight;
      fontSize = 11;
      fontFamily = pw.Font.courier();
    } else if ('blockquote' == parent.kind) {
      fontColor = grayDark;
      fontStyle = pw.FontStyle.italic;
      fontSize = 12;
    }

    return pw.Text('$text ',
        overflow: pw.TextOverflow.span,
        style: pw.TextStyle(
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            fontSize: fontSize,
            font: fontFamily,
            color: fontColor,
            decoration: pw.TextDecoration.combine(decorations)));
  }

  pw.Widget _blockToWidget(_Elem elem, String previousKind) {
    final List<pw.Widget> children = elem.children.length > 1
        ? _childrenToWidget(_childrenBySpaces(elem.children), elem) // to enable wrapping by words, split by words
        : _childrenToWidget(elem.children, elem);
    final pw.Widget widget;
    switch (elem.kind) {
      case 'p':
      case 'div':
      case 'header':
        widget = pw.Container(
            child: children.length == 1 ? children.first : pw.Wrap(children: children),
            padding: const pw.EdgeInsets.symmetric(vertical: 4));
        break;
      case 'blockquote':
        widget = pw.Container(
            child: children.length == 1 ? children.first : pw.Wrap(children: children),
            padding: const pw.EdgeInsets.only(left: 12),
            decoration: pw.BoxDecoration(border: pw.Border(left: pw.BorderSide(color: grayThy, width: 8))));
        break;
      case 'list':
        final bullet = elem.attrs!.containsKey('count')
            ? pw.Text('${elem.attrs!['count']}.', style: const pw.TextStyle(fontSize: 11))
            : pw.Text('• ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.justify);
        widget = pw.Wrap(children: [
          pw.Container(
              child: bullet,
              width: 32,
              padding: const pw.EdgeInsets.only(right: 6),
              alignment: pw.Alignment.centerRight),
          ...children
        ]);
        break;
      case 'code-block':
        final bullet = pw.Text('${elem.attrs!['count']}',
            style: pw.TextStyle(font: pw.Font.courierOblique(), fontSize: 11, color: grayLight));
        final line = pw.Wrap(children: [
          pw.Container(
              child: bullet,
              width: 32,
              padding: const pw.EdgeInsets.only(right: 6),
              alignment: pw.Alignment.centerRight),
          ...children
        ]);
        widget = previousKind != 'code-block' ? pw.Column(children: [pw.Paragraph(text: ''), line]) : line;
        break;
      case 'indent':
        widget = pw.Container(
            padding: pw.EdgeInsets.only(left: 16.0 * elem.attrs!['indent']),
            child: children.length == 1 ? children.first : pw.Wrap(children: children));
        break;
      default:
        widget = children.length == 1 ? children.first : pw.Wrap(children: children);
        Logger.error('Cannot parse elem: $elem');
    }
    if ('code-block' == previousKind && elem.kind != previousKind) {
      return pw.Column(children: [pw.Paragraph(text: ''), widget]);
    }
    return widget;
  }

  static void _printIt(List<_Elem> elems, [int padding = 0]) {
    for (_Elem el in elems) {
      stdout.write(
          '\n${'  ' * padding}<${el.kind}${el.text != null ? ' "${el.text}"' : ''}${el.attrs != null ? ' ${el.attrs}' : ''}' +
              (el.children.isNotEmpty ? ', children: [' : ''));
      if (el.children.isNotEmpty) {
        _printIt(el.children, 2);
        stdout.write('\n${'  ' * padding}]');
      }
      stdout.write('>');
    }
  }
}

class _DeltaAstEncoder extends Converter<String, List<_Elem>> {
  static const lineFeedAsciiCode = 0x0A;

  late List<_Elem> stack;

  @override
  List<_Elem> convert(String input) {
    stack = [_Elem()];

    final inputJson = jsonDecode(input) as List<dynamic>?;
    if (inputJson is! List<dynamic>) {
      throw ArgumentError('Unexpected formatting of the input delta string.');
    }
    final delta = Delta.fromJson(inputJson);
    final iterator = DeltaIterator(delta);

    while (iterator.hasNext) {
      final operation = iterator.next();

      if (operation.data is String) {
        final operationData = operation.data as String;

        if (!operationData.contains('\n')) {
          _handleInline(operationData, operation.attributes);
        } else {
          _handleLine(operationData, operation.attributes);
        }
      }
      // else if (operation.data is Map<String, dynamic>) {
      //   _handleEmbed(operation.data as Map<String, dynamic>);
      // }
      else {
        throw ArgumentError('Unexpected formatting of the input delta string.');
      }
    }
    return stack;
  }

  void _handleInline(String text, Map<String, dynamic>? attributes) {
    final style = Style.fromJson(attributes);

    text = text.trimLeft();

    if (text.isNotEmpty) {
      if (style.attributes.isNotEmpty) {
        // Now open any new styles.
        for (final attribute in style.attributes.values) {
          if (attribute.scope == AttributeScope.BLOCK) {
            continue;
          }
        }
      }
      // Put a new child to the current elem.
      final Map<String, dynamic> attrs = {};
      style.attributes.values.forEach((a) => attrs[a.key] = a.value);
      stack.last.children.add(_Elem(kind: 'span', text: text, attrs: attrs));
    }
  }

  void _handleLine(String data, Map<String, dynamic>? attributes) {
    final span = StringBuffer();

    for (var i = 0; i < data.length; i++) {
      if (data.codeUnitAt(i) == lineFeedAsciiCode) {
        if (span.isNotEmpty) {
          // Write the span if it's not empty.
          _handleInline(span.toString(), attributes);
        }

        final lineBlock =
            Style.fromJson(attributes).attributes.values.singleWhereOrNull((a) => a.scope == AttributeScope.BLOCK);

        // Setup the current elem (kind) and put a new to the stack.
        stack.last.kind = lineBlock != null ? lineBlock.key : 'p';
        stack.last.attrs = attributes;
        stack.add(_Elem());

        span.clear();
      } else {
        span.writeCharCode(data.codeUnitAt(i));
      }
    }

    // Remaining span
    if (span.isNotEmpty) {
      _handleInline(span.toString(), attributes);
    }
  }
}

class _Elem {
  _Elem({this.kind = 'div', this.text, this.attrs});

  List<_Elem> children = [];

  String kind;
  String? text;
  Map<String, dynamic>? attrs;

  _Elem cloneWith(String text) {
    final el = _Elem(text: text, kind: kind, attrs: attrs);
    el.children = children;
    return el;
  }

  @override
  String toString() => '<$kind; ' + (text != null ? 'text: "$text"; ' : '') + 'attr: $attrs; children: $children>';
}
