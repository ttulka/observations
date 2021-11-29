import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new observations'),
        bottom: TabBar(
          tabs: categories.map((cat) => Tab(icon: const Icon(Icons.category), text: cat.name)).toList(),
        ),
      ),
      body: TabBarView(
        children: categories
            .map((cat) => AddObservationForm(
                onAddObservation: (Observation observation) {
                  onAddObservation(observation);
                  Navigator.pop(context, true);
                },
                category: cat))
            .toList(),
      ),
    );
  }
}

class AddObservationForm extends StatefulWidget {
  const AddObservationForm({required this.onAddObservation, required this.category, Key? key}) : super(key: key);

  final AddObservation onAddObservation;
  final Category category;

  @override
  AddObservationFormState createState() => AddObservationFormState();
}

class AddObservationFormState extends State<AddObservationForm> {
  final _formKey = GlobalKey<FormState>();

  final dateController = TextEditingController();
  late quill.QuillController templateController;

  @override
  void dispose() {
    dateController.dispose();
    templateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    templateController = quill.QuillController(
        document: quill.Document.fromJson(jsonDecode(widget.category.template)),
        selection: const TextSelection.collapsed(offset: 0));
  }

  @override
  Widget build(BuildContext context) {
    return ObservationForm(
        dateController: dateController,
        templateController: templateController,
        onSave: () {
          final content = jsonEncode(templateController.document.toDelta().toJson());
          final observation = Observation(
              id: const Uuid().v4(),
              category: widget.category,
              date: DateFormat('dd/MM/yyyy').parse(dateController.text),
              updatedAt: DateTime.now(),
              content: content);
          widget.onAddObservation(observation);
        }).build(context, _formKey);
  }
}
