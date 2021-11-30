import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'domain.dart';

class ObservationForm {
  ObservationForm({required this.observations, required this.onSave});

  final List<Observation> observations;

  final Function(Observation) onSave;

  final Map<String, quill.QuillController> templateControllers = {};

  dispose() {
    templateControllers.values.forEach((c) => c.dispose());
  }

  Widget build(BuildContext context, Function onFinish) {
    return Column(children: [
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
            for (Observation o in observations) {
              final tc = templateControllers[o.id];
              if (tc != null) {
                final content = jsonEncode(tc.document.toDelta().toJson());
                final observation =
                    Observation(id: o.id, category: o.category, updatedAt: DateTime.now(), content: content);
                onSave(observation);
              }
            }
            onFinish();
          },
        ),
      ),
    ]);
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
