import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'delta_to_html.dart';
import 'widget_helpers.dart';
import 'logger.dart';
import '../observation/domain.dart';
import '../classroom/domain.dart';
import '../student/domain.dart';

var _showPrintDialog_justPriting = false;

Future<void> showPrintDialog(
    BuildContext context, List<Observation> observations,
    {required Classroom classroom,
    required Student student,
    bool headers = true}) async {
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
    if (!info.canPrint || !info.canConvertHtml) {
      await showAlert(context, AppLocalizations.of(context)!.printNotSupported);
      return;
    }
    final html = observations
        .map((o) =>
            (headers
                ? '<p style="text-align: center; padding: 5px"><b>' +
                    '${student.familyName}, ${student.givenName} (${classroom.name}) | ${o.category.localizedName(AppLocalizations.of(context)!)}' +
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
