import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import '../utils/widget_helpers.dart';
import '../utils/printing.dart';
import '../property/service.dart';
import '../student/domain.dart';
import '../classroom/domain.dart';
import 'domain.dart';
import 'form.dart';

class ComposeMeetingDialog extends StatelessWidget {
  ComposeMeetingDialog(
      {required this.student, required this.classroom, required this.meeting, required this.saveMeeting, Key? key})
      : super(key: key);

  final Meeting meeting;
  final Student student;
  final Classroom classroom;

  final Future<bool> Function(Meeting meeting) saveMeeting;

  final _propertyService = PropertyService();

  @override
  Widget build(BuildContext context) {
    final autosave = _propertyService.autosaveActive();
    final headers = _propertyService.headersActive();
    final htmlConvert = _propertyService.printingConvertToHtmlActive();
    final obtainTemplate = _propertyService.meetingTemplate();
    Meeting currentMeeting = meeting;
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(AppLocalizations.of(context)!.meetingComposeTitle +
                ' ${student.givenName} ${student.familyName} (${classroom.name})')),
      ),
      body: ComposeMeetingForm(
        meeting: meeting,
        onSaveMeeting: (m) {
          currentMeeting = m;
          saveMeeting(m);
        },
        obtainAutosave: autosave,
        obtainTemplate: obtainTemplate,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: AppLocalizations.of(context)!.printHint,
        child: const Icon(Icons.print),
        foregroundColor: Colors.blue,
        backgroundColor: Colors.white,
        onPressed: () async => showPrintDialogForMeetigs(context, [currentMeeting],
            classroom: classroom, student: student, printHeaders: await headers, htmlConvert: await htmlConvert),
      ),
    );
  }
}

class ComposeMeetingForm extends StatefulWidget {
  const ComposeMeetingForm(
      {required this.meeting,
      required this.onSaveMeeting,
      required this.obtainAutosave,
      required this.obtainTemplate,
      Key? key})
      : super(key: key);

  final Meeting meeting;

  final Function(Meeting) onSaveMeeting;

  final Future<bool> obtainAutosave;
  final Future<String> obtainTemplate;

  @override
  ComposeMeetingFormState createState() => ComposeMeetingFormState();
}

class ComposeMeetingFormState extends State<ComposeMeetingForm> {
  final _formKey = GlobalKey<FormState>();

  final atController = TextEditingController();
  final subjectController = TextEditingController();
  late quill.QuillController contentController;

  @override
  void initState() {
    super.initState();
    atController.text = DateFormat.yMd().format(widget.meeting.at);
    subjectController.text = widget.meeting.subject;
  }

  @override
  void dispose() {
    atController.dispose();
    subjectController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildFutureWidget<_InitForm>(
        future: (() async => _InitForm(await widget.obtainAutosave, await widget.obtainTemplate))(),
        buildWidget: (initForm) {
          final content = jsonDecode(widget.meeting.content != null && widget.meeting.content!.isNotEmpty
              ? widget.meeting.content!
              : initForm.template);
          contentController = quill.QuillController(
              document: quill.Document.fromJson(content), selection: const TextSelection.collapsed(offset: 0));
          return MeetingForm(
            meeting: widget.meeting,
            onSave: widget.onSaveMeeting,
            autosave: initForm.autosave,
            atController: atController,
            subjectController: subjectController,
            contentController: contentController,
          ).build(context, _formKey);
        });
  }
}

class _InitForm {
  _InitForm(this.autosave, this.template);

  final bool autosave;
  final String template;
}
