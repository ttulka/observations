import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../utils/widget_helpers.dart';
import '../property/service.dart';

class TemplateMeetingDialog extends StatelessWidget {
  TemplateMeetingDialog({Key? key}) : super(key: key);

  final _service = PropertyService();

  @override
  Widget build(BuildContext context) => buildFutureWidget<String>(
      future: _service.meetingTemplate(),
      buildWidget: (template) => Scaffold(
            appBar: AppBar(
              title: Center(child: Text(AppLocalizations.of(context)!.templateMeetingTitle)),
            ),
            body: TemplateMeetingForm(
              template: template,
              onSave: (template) async {
                final result = await _service.saveMeetingTemplate(template);
                if (result) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.editSuccess)));
                }
              },
            ),
          ));
}

class TemplateMeetingForm extends StatefulWidget {
  const TemplateMeetingForm({required this.template, required this.onSave, Key? key}) : super(key: key);

  final String template;
  final Function(String) onSave;

  @override
  TemplateMeetingFormState createState() => TemplateMeetingFormState();
}

class TemplateMeetingFormState extends State<TemplateMeetingForm> {
  final _formKey = GlobalKey<FormState>();

  late quill.QuillController templateController;

  @override
  void initState() {
    super.initState();
    templateController = quill.QuillController(
        document: widget.template.isNotEmpty ? quill.Document.fromJson(jsonDecode(widget.template)) : quill.Document(),
        selection: const TextSelection.collapsed(offset: 0));
  }

  @override
  void dispose() {
    templateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(child: buildRichTextEditor(templateController)),
            ElevatedButton(
              onPressed: () async {
                final content = jsonEncode(templateController.document.toDelta().toJson());
                await widget.onSave(content);
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              child: Text(AppLocalizations.of(context)!.formSave, style: const TextStyle(fontSize: 22.0)),
            ),
          ],
        ),
      ));
}
