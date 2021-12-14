import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../utils/widget_helpers.dart';
import 'domain.dart';

class ObservationForm {
  ObservationForm({required this.observations, required this.onSave, required this.autosave});

  final List<Observation> observations;

  final Function(Observation) onSave;

  final bool autosave;

  final Map<String, quill.QuillController> templateControllers = {};

  void dispose() {
    templateControllers.values.forEach((c) => c.dispose());
  }

  Widget build(BuildContext context, {required Function onFinish}) {
    return Column(children: [
      Expanded(
        child: TabBarView(
          children: observations.map((o) {
            final doc = o.content.isNotEmpty ? quill.Document.fromJson(jsonDecode(o.content)) : quill.Document();
            final tc = quill.QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
            templateControllers[o.id] = tc;

            if (autosave) {
              _initAutosave(tc, o);
            }
            return buildRichTextEditor(tc);
          }).toList(),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: ElevatedButton(
          onPressed: () async {
            for (Observation o in observations) {
              final tc = templateControllers[o.id];
              if (tc != null) {
                await onSave(_prepareToSave(o, tc.document.toDelta()));
              }
            }
            await onFinish();
          },
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
          child: Text(AppLocalizations.of(context)!.formSave, style: const TextStyle(fontSize: 22.0)),
        ),
      ),
    ]);
  }

  /// Watch the changes in the document and save automatically (autosave)
  void _initAutosave(quill.QuillController controller, Observation observation) {
    Timer timer = Timer(const Duration(), () {});
    var lastDelta = controller.document.toDelta();
    controller.addListener(() {
      if (timer.isActive) timer.cancel(); // reschedule the saving future
      timer = Timer(const Duration(seconds: 1), () async {
        final delta = controller.document.toDelta(); // any change to save?
        if (delta != lastDelta) {
          lastDelta = delta;
          await onSave(_prepareToSave(observation, delta));
        }
      });
    });
  }

  static Observation _prepareToSave(Observation observation, quill.Delta delta) {
    final content = jsonEncode(delta.toJson());
    return Observation(
      id: observation.id,
      category: observation.category,
      studentId: observation.studentId,
      updatedAt: DateTime.now(),
      content: content,
    );
  }
}
