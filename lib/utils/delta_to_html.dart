import 'dart:convert';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/models/documents/style.dart';
import 'logger.dart';

final _encoder = DeltaHtmlEncoder();

String deltaToHtml(String delta) {
  return _encoder.convert(delta);
}

class DeltaHtmlEncoder extends Converter<String, String> {
  static const lineFeedAsciiCode = 0x0A;

  late StringBuffer htmlBuffer;
  late StringBuffer lineBuffer;

  Attribute? currentBlockStyle;
  late Style currentInlineStyle;
  late List<String> currentBlockLines;

  bool currentUl = false;
  bool currentOl = false;

  @override
  String convert(String input) {
    htmlBuffer = StringBuffer();
    lineBuffer = StringBuffer();

    currentInlineStyle = Style();
    currentBlockLines = <String>[];

    currentUl = false;
    currentOl = false;

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
          _handleInline(lineBuffer, operationData, operation.attributes);
        } else {
          _handleLine(operationData, operation.attributes);
        }
      } else if (operation.data is Map<String, dynamic>) {
        _handleEmbed(operation.data as Map<String, dynamic>);
      } else {
        throw ArgumentError('Unexpected formatting of the input delta string.');
      }
    }

    _handleBlock(currentBlockStyle); // Close the last block

    return _cleanUp(htmlBuffer.toString());
  }

  String _cleanUp(String html) {
    return html
        .replaceAll(RegExp(r'\n+'), '\n')
        .replaceAll(RegExp(r'[ ]+'), ' ')
        .replaceAll(RegExp(r'<p>\n'), '<p>')
        .replaceAll(RegExp(r'\n</p>'), '</p>');
  }

  void _handleInline(
    StringBuffer buffer,
    String text,
    Map<String, dynamic>? attributes,
  ) {
    final style = Style.fromJson(attributes);

    // First close any current styles if needed
    final markedForRemoval = <Attribute>[];
    // Close the styles in reverse order, e.g. **_ for _**Test**_.
    for (final value in currentInlineStyle.attributes.values.toList().reversed) {
      if (value.scope == AttributeScope.BLOCK) {
        continue;
      }
      if (style.containsKey(value.key)) {
        continue;
      }

      final padding = _trimRight(buffer);
      _writeAttribute(buffer, value, close: true);
      if (padding.isNotEmpty) {
        buffer.write(padding);
      }
      markedForRemoval.add(value);
    }

    // Make sure to remove all attributes that are marked for removal.
    for (final value in markedForRemoval) {
      currentInlineStyle.attributes.removeWhere((_, v) => v == value);
    }

    // Now open any new styles.
    for (final attribute in style.attributes.values) {
      if (attribute.scope == AttributeScope.BLOCK) {
        continue;
      }
      if (currentInlineStyle.containsKey(attribute.key)) {
        continue;
      }
      final originalText = text;
      text = text.trimLeft();
      final padding = ' ' * (originalText.length - text.length);
      if (padding.isNotEmpty) {
        buffer.write(padding);
      }
      _writeAttribute(buffer, attribute);
    }

    // Write the text itself
    buffer.write(text);
    currentInlineStyle = style;
  }

  void _handleLine(String data, Map<String, dynamic>? attributes) {
    final span = StringBuffer();

    for (var i = 0; i < data.length; i++) {
      if (data.codeUnitAt(i) == lineFeedAsciiCode) {
        if (span.isNotEmpty) {
          // Write the span if it's not empty.
          _handleInline(lineBuffer, span.toString(), attributes);
        }
        // Close any open inline styles.
        _handleInline(lineBuffer, '', null);

        final lineBlock =
            Style.fromJson(attributes).attributes.values.singleWhereOrNull((a) => a.scope == AttributeScope.BLOCK);

        if (lineBlock == currentBlockStyle) {
          currentBlockLines.add(lineBuffer.toString());
        } else {
          _handleBlock(currentBlockStyle);
          currentBlockLines
            ..clear()
            ..add(lineBuffer.toString());

          currentBlockStyle = lineBlock;
        }
        lineBuffer.clear();

        span.clear();
      } else {
        span.writeCharCode(data.codeUnitAt(i));
      }
    }

    // Remaining span
    if (span.isNotEmpty) {
      _handleInline(lineBuffer, span.toString(), attributes);
    }
  }

  void _handleEmbed(Map<String, dynamic> data) {
    final embed = BlockEmbed(data.keys.first, data.values.first as String);

    if (embed.type == 'image') {
      _writeEmbedTag(lineBuffer, embed);
      _writeEmbedTag(lineBuffer, embed, close: true);
    } else if (embed.type == 'divider') {
      _writeEmbedTag(lineBuffer, embed);
      _writeEmbedTag(lineBuffer, embed, close: true);
    }
  }

  void _handleBlock(Attribute? blockStyle) {
    if (currentBlockLines.isEmpty) {
      return; // Empty block
    }

    // If there was a block before this one, add empty line between the blocks
    if (htmlBuffer.isNotEmpty) {
      htmlBuffer.writeln('');
    }

    if (blockStyle != Attribute.ul && currentUl) {
      currentUl = false;
      htmlBuffer.writeln('</ul>');
    } else if (blockStyle != Attribute.ol && currentOl) {
      currentOl = false;
      htmlBuffer.writeln('</ol>');
    }

    if (blockStyle == null) {
      htmlBuffer.write(currentBlockLines.map((l) => '<p>$l</p>').join('\n'));
    } else if (blockStyle == Attribute.codeBlock) {
      _writeAttribute(htmlBuffer, blockStyle);
      htmlBuffer.write(currentBlockLines.join('\n'));
      _writeAttribute(htmlBuffer, blockStyle, close: true);
      htmlBuffer.writeln();
    } else {
      // Dealing with lists or a quote.
      for (final line in currentBlockLines) {
        _writeBlockTag(htmlBuffer, blockStyle);
        htmlBuffer.write(line);
        _writeBlockTag(htmlBuffer, blockStyle, close: true);
        htmlBuffer.writeln();
      }
    }
  }

  String _trimRight(StringBuffer buffer) {
    final text = buffer.toString();
    if (!text.endsWith(' ')) {
      return '';
    }

    final result = text.trimRight();
    buffer
      ..clear()
      ..write(result);
    return ' ' * (text.length - result.length);
  }

  void _writeAttribute(
    StringBuffer buffer,
    Attribute attribute, {
    bool close = false,
  }) {
    if (attribute.key == Attribute.bold.key) {
      buffer.write(!close ? '<strong>' : '</strong>');
    } else if (attribute.key == Attribute.italic.key) {
      buffer.write(!close ? '<em>' : '</em>');
    } else if (attribute.key == Attribute.underline.key) {
      buffer.write(!close ? '<u>' : '</u>');
    } else if (attribute.key == Attribute.strikeThrough.key) {
      buffer.write(!close ? '<s>' : '</s>');
    } else if (attribute.key == Attribute.link.key) {
      buffer.write(!close ? '<a href="${attribute.value}">' : '</a>');
    } else if (attribute.key == Attribute.inlineCode.key) {
      buffer.write(!close ? '<code>' : '</code>');
    } else if (attribute.key == Attribute.codeBlock.key) {
      buffer.write(!close ? '<pre><code>\n' : '\n</code></pre>');
    } else if (attribute.key == Attribute.color.key) {
      buffer.write(!close ? '<span style="color: ${attribute.value}">' : '</span>');
    } else if (attribute.key == Attribute.background.key) {
      buffer.write(!close ? '<span style="background-color: ${attribute.value}; display: inline-block">' : '</span>');
    } else {
      buffer.write(!close ? '<span>' : '</span>');
      Logger.info('Cannot handle attribute: $attribute');
    }
  }

  void _writeBlockTag(
    StringBuffer buffer,
    Attribute block, {
    bool close = false,
  }) {
    if (block.key == Attribute.blockQuote.key) {
      buffer.write(!close ? '<blockquote>' : '</blockquote>');
    } else if (block.key == Attribute.ul.key) {
      if (!close && !currentUl) {
        currentUl = true;
        buffer.writeln('<ul>');
      }
      buffer.write(!close ? ' <li>' : '</li>');
    } else if (block.key == Attribute.ol.key) {
      if (!close && !currentOl) {
        currentOl = true;
        buffer.writeln('<ol>');
      }
      buffer.write(!close ? ' <li>' : '</li>');
    } else if (block.key == Attribute.h1.key && block.value == 1) {
      buffer.write(!close ? '<h1>' : '</h1>');
    } else if (block.key == Attribute.h2.key && block.value == 2) {
      buffer.write(!close ? '<h2>' : '</h2>');
    } else if (block.key == Attribute.h3.key && block.value == 3) {
      buffer.write(!close ? '<h3>' : '</h3>');
    } else if (block.key == Attribute.checked.key) {
      buffer.write(!close ? '<p><input type="checkbox" checked> ' : '</p>');
    } else if (block.key == Attribute.unchecked.key) {
      buffer.write(!close ? '<p><input type="checkbox"> ' : '</p>');
    } else if (block.key == Attribute.indent.key) {
      buffer.write(!close ? '<p>' + ('&nbsp; &nbsp; ' * block.value) : '</p>');
    } else {
      buffer.write(!close ? '<div>' : '</div>');
      Logger.info('Cannot handle block: $block');
    }
  }

  void _writeEmbedTag(
    StringBuffer buffer,
    BlockEmbed embed, {
    bool close = false,
  }) {
    if (embed.type == 'image') {
      if (close) {
        buffer.write('<img src="${embed.data}">');
      }
    } else if (embed.type == 'divider' && close) {
      buffer.write('\n<hr>\n');
    }
  }
}
