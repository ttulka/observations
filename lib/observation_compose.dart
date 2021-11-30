import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'domain.dart';
import 'service.dart';
import 'observation_form.dart';

typedef SaveObservation = Function(Observation observation);

class ComposeObservationDialog extends StatelessWidget {
  ComposeObservationDialog({required this.student, required this.classroom, Key? key}) : super(key: key);

  final Student student;
  final Classroom classroom;

  final _observationService = ObservationService();
  final _categoryService = CategoryService();

  void saveObservation(Observation observation) {
    _observationService.save(observation);
  }

  @override
  Widget build(BuildContext context) {
    final currentObservations = _observationService.listByStudent(student);
    final categories = _mergeCategories(_categoryService.listAll(), currentObservations);
    final observations = _mergeObservations(categories, currentObservations);
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${student.familyName}, ${student.givenName} (${classroom.name})'),
          bottom: TabBar(
            tabs: categories.map((c) => Tab(text: c.name)).toList(),
          ),
        ),
        body: ComposeObservationForm(onSaveObservation: saveObservation, observations: observations),
      ),
    );
  }

  static List<Category> _mergeCategories(List<Category> categories, List<Observation> observations) {
    final List<Category> results = [];
    results.addAll(categories);
    observations.map((o) => o.category).where((c) => !categories.contains(c)).forEach((c) => results.add(c));
    return results;
  }

  static List<Observation> _mergeObservations(List<Category> categories, List<Observation> observations) {
    return categories
        .map((c) => observations.firstWhere(
              (o) => o.category.id == c.id,
              orElse: () =>
                  Observation(id: const Uuid().v4(), category: c, updatedAt: DateTime.now(), content: c.template),
            ))
        .toList();
  }
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
    return ObservationForm(
      observations: widget.observations,
      onSave: widget.onSaveObservation,
    ).build(context, () => Navigator.pop(context, true));
  }
}
