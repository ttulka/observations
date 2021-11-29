import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'domain.dart';

class ObservationForm {
  ObservationForm({required this.intialDate, required this.observations, required this.onSave});

  final DateTime intialDate;
  final List<Observation> observations;

  final Function(Observation) onSave;

  final dateController = TextEditingController();
  final Map<String, quill.QuillController> templateControllers = {};

  dispose() {
    dateController.dispose();
    templateControllers.values.forEach((c) => c.dispose());
  }

  Widget build(BuildContext context, Function onFinish) {
    final formKey = GlobalKey<FormState>();
    dateController.text = DateFormat('dd/MM/yyyy').format(intialDate);
    return Column(children: [
      Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _newDateField(context, 'Date (dd/mm/yyyy)', dateController, true, 50),
            ],
          ),
        ),
      ),
      Expanded(
        child: TabBarView(
          children: observations.map((o) {
            final tc = quill.QuillController(
                document: quill.Document.fromJson(jsonDecode(o.content)),
                selection: const TextSelection.collapsed(offset: 0));
            templateControllers[o.id] = tc;
            return _newTextAreaField(tc, 1000);
          }).toList(),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ElevatedButton(
          child: const Text('Save'),
          onPressed: () {
            if (!formKey.currentState!.validate()) {
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('Some observation is invalid. Please check all tabs.')));
              return;
            }
            final date = DateFormat('dd/MM/yyyy').parse(dateController.text);
            for (Observation o in observations) {
              final tc = templateControllers[o.id];
              if (tc != null) {
                final content = jsonEncode(tc.document.toDelta().toJson());
                final observation = Observation(
                    id: o.id, category: o.category, date: date, updatedAt: DateTime.now(), content: content);
                onSave(observation);
              }
            }
            onFinish();
          },
        ),
      ),
    ]);
  }

  Widget _newDateField(
      BuildContext context, String label, TextEditingController controller, bool required, int maxLength) {
    final filter = RegExp(r"\d\d/\d\d/\d\d\d\d");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: TextFormField(
        onTap: () => _selectDate(context, DateTime.now()),
        controller: controller,
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: label,
        ),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Required';
          }
          if (value != null && !filter.hasMatch(value)) {
            return 'Invalid value';
          }
          return null;
        },
        maxLength: maxLength,
      ),
    );
  }

  _selectDate(BuildContext context, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(initialDate.year - 1, initialDate.month),
        lastDate: initialDate);
    if (picked != null) {
      var date = DateFormat('dd/MM/yyyy').format(picked);
      dateController.text = date;
    }
  }

  Widget _newTextAreaField(quill.QuillController controller, int maxLength) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          quill.QuillToolbar.basic(controller: controller, showImageButton: false, showVideoButton: false),
          Expanded(
            child: Container(
              child: quill.QuillEditor.basic(
                controller: controller,
                readOnly: false, // true for view only mode
              ),
            ),
          )
        ],
      ),
    );
  }
}
