import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:printing/printing.dart';
import '../utils/delta_to_html.dart';
import '../utils/widget_helpers.dart';
import 'domain.dart';
import '../student/domain.dart';
import '../classroom/domain.dart';
import 'service.dart';
import 'form.dart';

typedef SaveObservation = Function(Observation observation);

class ComposeObservationDialog extends StatelessWidget {
  ComposeObservationDialog({required this.student, required this.classroom, Key? key}) : super(key: key);

  final Student student;
  final Classroom classroom;

  final _observationService = ObservationService();

  Future<bool> saveObservation(Observation observation) => _observationService.save(observation);

  @override
  Widget build(BuildContext context) {
    final autosave = _observationService.autosaveActive();
    final headers = _observationService.headersActive();
    return buildFutureWidget<List<Observation>>(
      future: _observationService.prepareAllByStudent(student),
      buildWidget: (observations) {
        final categories = observations.map((o) => o.category).toList();
        Observation? currentObservation = observations.isNotEmpty ? observations.first : null;
        return DefaultTabController(
          length: categories.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text('${student.familyName}, ${student.givenName} (${classroom.name})'),
              bottom: TabBar(
                tabs: categories.map((c) => Tab(text: c.localizedName(AppLocalizations.of(context)!))).toList(),
                onTap: (index) => currentObservation = observations[index],
              ),
            ),
            body: ComposeObservationForm(
              observations: observations,
              onSaveObservation: (o) {
                currentObservation = o;
                saveObservation(o);
              },
              obtainAutosave: autosave,
            ),
            floatingActionButton: FloatingActionButton(
              tooltip: AppLocalizations.of(context)!.printHint,
              child: const Icon(Icons.print),
              backgroundColor: Colors.grey,
              onPressed: () => _printDialog(context, currentObservation, headers),
            ),
          ),
        );
      },
    );
  }

  Future<void> _printDialog(BuildContext context, Observation? observation, Future<bool> obtainHeaders) async {
    if (observation == null) {
      return;
    }
    final info = await Printing.info();
    if (!info.canPrint) print('=== PRINTING NOT SUPPORTED');
    if (!info.directPrint) print('=== DIRECT PRINTING NOT SUPPORTED');
    if (!info.canConvertHtml) print('=== CONVERTING NOT SUPPORTED');
    if (!info.canPrint || !info.canConvertHtml) {
      await showAlert(context, AppLocalizations.of(context)!.printNotSupported);
      return;
    }
    _toPdf(observation.content, student, classroom, await obtainHeaders)
        .timeout(const Duration(seconds: 5))
        .then((doc) => Printing.layoutPdf(onLayout: (PdfPageFormat format) => doc));
  }

  static Future<Uint8List> _toPdf(String jsonContent, Student student, Classroom classroom, bool headers) async {
    final quill.Document d =
        jsonContent.isNotEmpty ? quill.Document.fromJson(jsonDecode(jsonContent)) : quill.Document();
    final html = _quillDeltaToHtml(d.toDelta());
    final header = headers
        ? '<p style="border: 2px solid grey; text-align: center; padding: 5px">${student.familyName}, ${student.givenName} (${classroom.name})</p>'
        : '';
    return Printing.convertHtml(
      format: PdfPageFormat.standard,
      html: '<html><body>$header$html</body></html>',
    );
  }

  static String _quillDeltaToHtml(quill.Delta delta) {
    final convertedValue = jsonEncode(delta.toJson());
    return deltaToHtml(convertedValue);
  }
}

class ComposeObservationForm extends StatefulWidget {
  const ComposeObservationForm(
      {required this.onSaveObservation, required this.observations, required this.obtainAutosave, Key? key})
      : super(key: key);

  final SaveObservation onSaveObservation;
  final List<Observation> observations;
  final Future<bool> obtainAutosave;

  @override
  ComposeObservationFormState createState() => ComposeObservationFormState();
}

class ComposeObservationFormState extends State<ComposeObservationForm> {
  @override
  Widget build(BuildContext context) {
    return buildFutureWidget<bool>(
      future: widget.obtainAutosave,
      buildWidget: (autosave) {
        final form = ObservationForm(
          observations: widget.observations,
          onSave: widget.onSaveObservation,
          autosave: autosave,
        );
        return form.build(context, onFinish: () {
          Navigator.pop(context, true);
          form.dispose();
        });
      },
    );
  }
}
