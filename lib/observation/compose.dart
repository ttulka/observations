import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/widget_helpers.dart';
import '../utils/printing.dart';
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
              onPressed: () async {
                if (currentObservation != null) {
                  await showPrintDialog(context, [currentObservation!],
                      classroom: classroom, student: student, headers: await headers);
                }
              },
            ),
          ),
        );
      },
    );
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
