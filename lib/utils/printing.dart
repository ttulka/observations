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

var _showPrintDialog_justPriting = false;

Future<void> showPrintDialog(BuildContext context, List<Observation> observations,
    {required Classroom classroom, required Student student, bool headers = true, bool htmlConvert = true}) async {
  if (_showPrintDialog_justPriting) {
    return;
  }
  _showPrintDialog_justPriting = true;
  Logger.debug('Printing starts...');
  try {
    final info = await Printing.info();
    if (!info.canPrint) Logger.error('!!! PRINTING NOT SUPPORTED');
    if (!info.directPrint) Logger.error('!!! DIRECT PRINTING NOT SUPPORTED');
    if (!info.canConvertHtml) Logger.error('!!! CONVERTING NOT SUPPORTED');
    if (!info.canPrint) {
      await showAlert(context, AppLocalizations.of(context)!.printNotSupported);
      return;
    }
    observations.sort((a, b) => a.category.priority.compareTo(b.category.priority));

    final Function composeHeader = (Student student, Classroom classroom, Category category) =>
        '${student.familyName}, ${student.givenName} (${classroom.name}): ${category.localizedName(AppLocalizations.of(context)!)}';

    if (!info.canConvertHtml || !htmlConvert) {
      final List<pw.Widget> pdf = [];
      final headerColor = PdfColor.fromHex('#666666');
      for (Observation o in observations) {
        if (o.content.length > 20) {
          pdf.add(pw.Header(
              text: composeHeader(student, classroom, o.category),
              padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              textStyle: pw.TextStyle(color: headerColor, decorationColor: headerColor)));
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

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) => doc.save());
      return;
    }

    final html = observations
        .where((o) => o.content.length > 20)
        .map((o) =>
            (headers
                ? '<p style="color: #666666; padding: 5px; padding-top: 20px"><b>' +
                    composeHeader(student, classroom, o.category) +
                    '</b></p><hr>'
                : '') +
            deltaToHtml(o.content))
        .join('<p></p>');

    final pdf = await Printing.convertHtml(
      format: PdfPageFormat.standard,
      html: '<html><body>$html</body></html>',
    ).timeout(const Duration(seconds: 5));

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) => pdf);
  } finally {
    _showPrintDialog_justPriting = false;
  }
}
