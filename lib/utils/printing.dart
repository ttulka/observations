import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'delta_to_html.dart';
import 'delta_to_pdf.dart';
import 'widget_helpers.dart';
import 'logger.dart';
import '../observation/domain.dart';
import '../category/domain.dart';
import '../classroom/domain.dart';
import '../student/domain.dart';

// share this flag for both dialogs as they must never appear simultaneously
var _showPrintDialog_justPriting = false;

Future<void> showPrintDialog(BuildContext context, List<Observation> observations,
    {required Classroom classroom, required Student student, bool printHeaders = true, bool htmlConvert = true}) async {
  if (_showPrintDialog_justPriting) {
    return;
  }
  Logger.debug('Printing starts...');
  try {
    _showPrintDialog_justPriting = true;

    final info = await Printing.info();
    if (!info.canPrint) {
      await showAlert(context, AppLocalizations.of(context)!.printNotSupported);
      return;
    }

    final pdf = await _toPdf(observations, student, classroom,
        context: context, htmlConvert: htmlConvert, printHeaders: printHeaders, info: info);

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) => pdf);
  } finally {
    _showPrintDialog_justPriting = false;
  }
}

Future<bool> showSaveDialog(BuildContext context, List<Observation> observations,
    {required Classroom classroom, required Student student, bool printHeaders = true, bool htmlConvert = true}) async {
  if (_showPrintDialog_justPriting) {
    return false;
  }
  Logger.debug('Saving starts...');
  try {
    _showPrintDialog_justPriting = true;

    String? outputFile = await FilePicker.platform.saveFile(
      //dialogTitle: 'Please select an output file:',
      fileName: _toFileNamePdf(student),
    );
    if (outputFile != null) {
      final info = await Printing.info();

      final pdf = await _toPdf(observations, student, classroom,
          context: context, htmlConvert: htmlConvert, printHeaders: printHeaders, info: info);

      await File(outputFile).writeAsBytes(pdf);
      return true;
    }
  } finally {
    _showPrintDialog_justPriting = false;
  }
  return false;
}

String _toFileNamePdf(Student student) =>
    '${student.familyName}_${student.givenName}.pdf'.replaceAll(RegExp(r'\s'), '_');

Future<Uint8List> _toPdf(List<Observation> observations, Student student, Classroom classroom,
    {required BuildContext context,
    required bool htmlConvert,
    required bool printHeaders,
    required PrintingInfo info}) async {
  if (!info.canPrint) Logger.error('!!! PRINTING NOT SUPPORTED');
  if (!info.directPrint) Logger.error('!!! DIRECT PRINTING NOT SUPPORTED');
  if (!info.canConvertHtml) Logger.error('!!! CONVERTING NOT SUPPORTED');

  observations.sort((a, b) => a.category.priority.compareTo(b.category.priority));

  if (!info.canConvertHtml || !htmlConvert) {
    final List<pw.Widget> pdf = [];
    final headerColor = PdfColor.fromHex('#666666');
    for (Observation o in observations) {
      if (o.content.length > 20) {
        if (printHeaders) {
          pdf.add(pw.Header(
              text: _composeHeader(student, classroom, o.category, context),
              padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              textStyle: pw.TextStyle(color: headerColor, decorationColor: headerColor)));
        }
        pdf.addAll(deltaToPdf(o.content));
      }
    }
    final doc = pw.Document(
        theme: pw.ThemeData.withFont(
            base: pw.Font.ttf(await rootBundle.load("assets/OpenSans-Regular.ttf")),
            bold: pw.Font.ttf(await rootBundle.load("assets/OpenSans-Bold.ttf")),
            italic: pw.Font.ttf(await rootBundle.load("assets/OpenSans-Italic.ttf")),
            boldItalic: pw.Font.ttf(await rootBundle.load("assets/OpenSans-BoldItalic.ttf"))));
    doc.addPage(pw.MultiPage(pageFormat: PdfPageFormat.a4, build: (pw.Context context) => pdf));

    return doc.save();
  }

  // converting to HTML first, then from HTML to PDF
  final html = observations
      .where((o) => o.content.length > 20)
      .map((o) =>
          (printHeaders
              ? '<p style="color: #666666; padding: 5px; padding-top: 20px"><b>' +
                  _composeHeader(student, classroom, o.category, context) +
                  '</b></p><hr>'
              : '') +
          deltaToHtml(o.content))
      .join('<p></p>');

  return await Printing.convertHtml(
    format: PdfPageFormat.standard,
    html: '<html><body>$html</body></html>',
  ).timeout(const Duration(seconds: 5));
}

String _composeHeader(Student student, Classroom classroom, Category category, BuildContext context) =>
    '${student.familyName}, ${student.givenName} (${classroom.name}): ${category.localizedName(AppLocalizations.of(context)!)}';
