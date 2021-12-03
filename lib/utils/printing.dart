import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'delta_to_html.dart';
import 'widget_helpers.dart';
import '../observation/domain.dart';
import '../classroom/domain.dart';
import '../student/domain.dart';

Future<void> showPrintDialog(BuildContext context, List<Observation> observations,
    {required Classroom classroom, required Student student, bool headers = true}) async {
  print('=== Printing starts...');
  final info = await Printing.info();
  if (!info.canPrint) print('=== PRINTING NOT SUPPORTED');
  if (!info.directPrint) print('=== DIRECT PRINTING NOT SUPPORTED');
  if (!info.canConvertHtml) print('=== CONVERTING NOT SUPPORTED');
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

  Printing.layoutPdf(onLayout: (PdfPageFormat format) => pdf);
}
