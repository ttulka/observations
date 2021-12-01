import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:printing/printing.dart';
import 'delta_to_html.dart';
import 'widget_helpers.dart';
import 'observation_domain.dart';
import 'student_domain.dart';
import 'classroom_domain.dart';
import 'category_domain.dart';
import 'observation_service.dart';
import 'category_service.dart';
import 'observation_form.dart';

typedef SaveObservation = Function(Observation observation);

class ComposeObservationDialog extends StatelessWidget {
  ComposeObservationDialog({required this.student, required this.classroom, Key? key}) : super(key: key);

  final Student student;
  final Classroom classroom;

  final _observationService = ObservationService();
  final _categoryService = CategoryService();

  Future<void> saveObservation(Observation observation) => _observationService.save(observation);

  @override
  Widget build(BuildContext context) {
    return buildFutureWidget<ComposeObservationData>(
      future: _prepareData(),
      buildWidget: (data) {
        Observation? currentObservation = data.observations.isNotEmpty ? data.observations.first : null;
        return DefaultTabController(
          length: data.categories.length,
          child: Scaffold(
            appBar: AppBar(
              title: Text('${student.familyName}, ${student.givenName} (${classroom.name})'),
              bottom: TabBar(
                tabs: data.categories.map((c) => Tab(text: c.localizedName(AppLocalizations.of(context)!))).toList(),
                onTap: (index) => currentObservation = data.observations[index],
              ),
            ),
            body: ComposeObservationForm(
              onSaveObservation: (o) {
                currentObservation = o;
                saveObservation(o);
              },
              observations: data.observations,
            ),
            floatingActionButton: FloatingActionButton(
              tooltip: AppLocalizations.of(context)!.printHint,
              child: const Icon(Icons.print),
              backgroundColor: Colors.grey,
              onPressed: () => _printDialog(context, currentObservation),
            ),
          ),
        );
      },
    );
  }

  Future<void> _printDialog(BuildContext context, Observation? observation) async {
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
    final quill.Document d = quill.Document.fromJson(jsonDecode(observation.content));
    final html = '<html><body>' + _quillDeltaToHtml(d.toDelta()) + '</body></html>';
    const format = PdfPageFormat.standard;
    print('=== CONVERTING START ' + format.toString());
    final futureDoc = Printing.convertHtml(format: format, html: html);
    print('=== CONVERTING FUTURE END');
    futureDoc
      ..timeout(const Duration(seconds: 5))
      ..then((doc) => Printing.layoutPdf(onLayout: (PdfPageFormat format) => doc));

    // final doc = pw.Document();
    // doc.addPage(pw.Page(
    //     pageFormat: PdfPageFormat.a4,
    //     build: (pw.Context context) {
    //       return pw.Center(
    //         child: pw.Text('Hello World'),
    //       ); // Center
    //     }));
    // await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }

  static String _quillDeltaToHtml(quill.Delta delta) {
    final convertedValue = jsonEncode(delta.toJson());
    return deltaToHtml(convertedValue);
  }

  Future<ComposeObservationData> _prepareData() async {
    final currentObservations = await _observationService.listByStudent(student);
    final categories = _mergeCategories(await _categoryService.listAll(), currentObservations);
    final observations = _mergeObservations(categories, currentObservations, student.id);
    return ComposeObservationData(
      categories: categories,
      observations: observations,
    );
  }

  static List<Category> _mergeCategories(List<Category> categories, List<Observation> observations) {
    final List<Category> results = [];
    results.addAll(categories);
    observations
        .map((o) => o.category)
        .where((c) => categories.indexWhere((c_) => c_.id == c.id) == -1)
        .forEach((c) => results.add(c));
    return results;
  }

  static List<Observation> _mergeObservations(
      List<Category> categories, List<Observation> observations, String studentId) {
    return categories
        .map((c) => observations.firstWhere(
              (o) => o.category.id == c.id,
              orElse: () => Observation(
                id: const Uuid().v4(),
                category: c,
                studentId: studentId,
                updatedAt: DateTime.now(),
                content: c.template,
              ),
            ))
        .toList();
  }
}

class ComposeObservationData {
  ComposeObservationData({required this.categories, required this.observations});

  final List<Category> categories;
  final List<Observation> observations;
}

class ComposeObservationForm extends StatefulWidget {
  const ComposeObservationForm({required this.onSaveObservation, required this.observations, Key? key})
      : super(key: key);

  final SaveObservation onSaveObservation;
  final List<Observation> observations;

  @override
  ComposeObservationFormState createState() => ComposeObservationFormState();
}

class ComposeObservationFormState extends State<ComposeObservationForm> {
  @override
  Widget build(BuildContext context) {
    final form = ObservationForm(
      observations: widget.observations,
      onSave: widget.onSaveObservation,
    );
    return form.build(context, onFinish: () {
      Navigator.pop(context, true);
      form.dispose();
    });
  }
}
