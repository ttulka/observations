import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import '../utils/widget_helpers.dart';
import 'domain.dart';

class MeetingForm {
  MeetingForm(
      {required this.meeting,
      required this.onSave,
      required this.autosave,
      required this.atController,
      required this.subjectController,
      required this.contentController});

  static final _dateFormat = DateFormat.yMd();

  final Meeting meeting;

  final Function(Meeting) onSave;

  final bool autosave;

  final TextEditingController atController;
  final TextEditingController subjectController;
  final quill.QuillController contentController;

  Widget build(BuildContext context, GlobalKey<FormState> formKey) {
    _initAutosave();
    return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              _newDateField(context, AppLocalizations.of(context)!.meetingAt, atController, true, 50),
              _newTextField(context, AppLocalizations.of(context)!.meetingSubject, subjectController, false, 50),
              Expanded(child: buildRichTextEditor(contentController)),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final result = await onSave(_prepareToSave(meeting, contentController.document.toDelta()));
                    Navigator.pop(context, result);
                  }
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                child: Text(AppLocalizations.of(context)!.formSave, style: const TextStyle(fontSize: 22.0)),
              ),
            ],
          ),
        ));
  }

  /// Watch the changes in the document and save automatically (autosave)
  void _initAutosave() {
    Timer timer = Timer(const Duration(), () {});
    var lastDelta = contentController.document.toDelta();
    final onTriggered = (bool checkDelta) {
      if (timer.isActive) timer.cancel(); // reschedule the saving future
      timer = Timer(const Duration(seconds: 1), () async {
        if (!checkDelta) {
          return await onSave(_prepareToSave(meeting, lastDelta));
        }
        final delta = contentController.document.toDelta(); // any change to save?
        if (delta != lastDelta) {
          lastDelta = delta;
          await onSave(_prepareToSave(meeting, delta));
        }
      });
    };
    contentController.addListener(() => onTriggered(true));
    atController.addListener(() => onTriggered(false));
    subjectController.addListener(() => onTriggered(false));
  }

  Meeting _prepareToSave(Meeting meeting, quill.Delta delta) {
    final content = jsonEncode(delta.toJson());
    return Meeting(
      id: meeting.id,
      at: _dateFormat.parse(atController.text),
      subject: subjectController.text,
      studentId: meeting.studentId,
      content: content,
    );
  }

  static Widget _newDateField(
          BuildContext context, String label, TextEditingController controller, bool required, int maxLength) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: TextFormField(
          onTap: () async {
            final initDate = _dateFormat.parse(controller.text);
            final picked = await showDatePicker(
              context: context,
              initialDate: initDate,
              firstDate: DateTime(initDate.year - 1),
              lastDate: DateTime(DateTime.now().year + 10),
            );
            if (picked != null) {
              controller.text = _dateFormat.format(picked);
            }
          },
          controller: controller,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: label,
          ),
          validator: (value) {
            if (required && (value == null || value.isEmpty)) {
              return AppLocalizations.of(context)!.formRequired;
            }
            if (value != null) {
              try {
                _dateFormat.parse(value);
              } catch (e) {
                return AppLocalizations.of(context)!.formInvalid;
              }
            }
            return null;
          },
          maxLength: maxLength,
        ),
      );

  static Widget _newTextField(
          BuildContext context, String label, TextEditingController controller, bool required, int maxLength,
          {RegExp? filter}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: label,
          ),
          validator: (value) {
            if (required && (value == null || value.isEmpty)) {
              return AppLocalizations.of(context)!.formRequired;
            }
            if (filter != null && value != null && !filter.hasMatch(value)) {
              return AppLocalizations.of(context)!.formInvalid;
            }
            return null;
          },
          maxLength: maxLength,
        ),
      );
}
