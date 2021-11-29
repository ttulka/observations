import 'package:flutter/material.dart';
import 'package:observations/service.dart';
import 'package:uuid/uuid.dart';
import 'observation_form.dart';
import 'domain.dart';

typedef AddObservation = Function(Observation observation);

class AddObservationDialog extends StatelessWidget {
  AddObservationDialog({required this.onAddObservation, Key? key}) : super(key: key);

  final AddObservation onAddObservation;

  final CategoryService _categoryService = CategoryService();

  @override
  Widget build(BuildContext context) {
    final categories = _categoryService.listAll();
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add new observations'),
          bottom: TabBar(
            tabs: categories.map((cat) => Tab(text: cat.name)).toList(),
          ),
        ),
        body: AddObservationForm(onAddObservation: onAddObservation, categories: categories),
      ),
    );
  }
}

class AddObservationForm extends StatefulWidget {
  const AddObservationForm({required this.onAddObservation, required this.categories, Key? key}) : super(key: key);

  final AddObservation onAddObservation;
  final List<Category> categories;

  @override
  AddObservationFormState createState() => AddObservationFormState();
}

class AddObservationFormState extends State<AddObservationForm> {
  @override
  Widget build(BuildContext context) {
    return ObservationForm(
      intialDate: DateTime.now(),
      observations: widget.categories
          .map((c) => Observation(
                id: const Uuid().v4(),
                category: c,
                date: DateTime.now(),
                updatedAt: DateTime.now(),
                content: c.template,
              ))
          .toList(),
      onSave: widget.onAddObservation,
    ).build(context, () => Navigator.pop(context, true));
  }
}
