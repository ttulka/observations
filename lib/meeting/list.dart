import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../utils/widget_helpers.dart';
import '../utils/printing.dart';
import '../property/service.dart';
import '../classroom/domain.dart';
import '../student/domain.dart';
import 'domain.dart';
import 'service.dart';
import 'compose.dart';

typedef UpdateStudent = Future<bool> Function(Student student);

class MeetingList extends StatefulWidget {
  MeetingList({required this.student, required this.classroom, Key? key}) : super(key: key);

  final Student student;
  final Classroom classroom;

  final MeetingService _service = MeetingService();
  final PropertyService _propertyService = PropertyService();

  Future<Meeting?> getMeeting(String meetingId) => _service.getById(meetingId);
  Future<bool> saveMeeting(Meeting meeting) => _service.save(meeting);
  Future<bool> removeMeeting(Meeting meeting) => _service.remove(meeting);
  Future<List<Meeting>> loadMeetings() => _service.listByStudent(student);

  Future<bool> printingConvertToHtmlActive() => _propertyService.printingConvertToHtmlActive();

  @override
  _MeetingListState createState() => _MeetingListState();
}

class _MeetingListState extends State<MeetingList> {
  Future<bool> _handleSaveMeeting(Meeting meeting) async {
    final result = await widget.saveMeeting(meeting);
    setState(() {});
    return result;
  }

  Future<bool> _handleRemoveMeeting(Meeting meeting) async {
    final result = await widget.removeMeeting(meeting);
    setState(() {});
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(AppLocalizations.of(context)!.meetingListTitle +
                ' ${widget.student.givenName} ${widget.student.familyName} (${widget.classroom.name})')),
      ),
      body: buildFutureWidget<List<Meeting>>(
        future: widget.loadMeetings(),
        buildWidget: (meetings) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: meetings.isNotEmpty
              ? meetings
                  .map((Meeting meeting) => MeetingListItem(
                        meeting: meeting,
                        student: widget.student,
                        classroom: widget.classroom,
                        getMeeting: widget.getMeeting,
                        saveMeeting: _handleSaveMeeting,
                        removeMeeting: _handleRemoveMeeting,
                        printingConvertToHtmlActive: widget.printingConvertToHtmlActive(),
                      ))
                  .toList()
              : [emptyListTile(AppLocalizations.of(context)!.emptyMeetingList)],
        ),
      ),
      floatingActionButton: buildFloatingAddButton(
          context,
          AppLocalizations.of(context)!.addMeetingTitle,
          (ctx) => ComposeMeetingDialog(
              student: widget.student,
              classroom: widget.classroom,
              meeting: Meeting(id: const Uuid().v4(), at: DateTime.now(), subject: '', studentId: widget.student.id),
              saveMeeting: _handleSaveMeeting)),
    );
  }
}

class MeetingListItem extends StatelessWidget {
  MeetingListItem({
    required this.meeting,
    required this.student,
    required this.classroom,
    required this.getMeeting,
    required this.saveMeeting,
    required this.removeMeeting,
    required this.printingConvertToHtmlActive,
  }) : super(key: ObjectKey(meeting));

  final Meeting meeting;
  final Student student;
  final Classroom classroom;

  final Future<Meeting?> Function(String meetingId) getMeeting;
  final Future<bool> Function(Meeting meeting) saveMeeting;
  final Future<bool> Function(Meeting meeting) removeMeeting;
  final Future<bool> printingConvertToHtmlActive;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        final meetingFull = await getMeeting(meeting.id);
        final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ComposeMeetingDialog(
                    student: student, classroom: classroom, meeting: meetingFull!, saveMeeting: saveMeeting)));
        if (result != null && result) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.editSuccess)));
        }
      },
      leading: const CircleAvatar(
        child: Icon(Icons.people),
      ),
      trailing: FittedBox(
        fit: BoxFit.fill,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: AppLocalizations.of(context)!.printMeetingsHint,
            splashRadius: 20,
            onPressed: () async {
              final meetingFull = await getMeeting(meeting.id);
              await showPrintDialogForMeetigs(context, [meetingFull!],
                  classroom: classroom, student: student, htmlConvert: await printingConvertToHtmlActive);
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: AppLocalizations.of(context)!.pdfMeetingsHint,
            splashRadius: 20,
            onPressed: () async {
              final meetingFull = await getMeeting(meeting.id);
              final result = await showSaveDialogForMeetings(context, [meetingFull!],
                  classroom: classroom, student: student, htmlConvert: await printingConvertToHtmlActive);
              if (result) {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.saveSuccess)));
              }
            },
          ),
          IconButton(
              icon: const Icon(Icons.edit),
              tooltip: AppLocalizations.of(context)!.editMeetingHint,
              splashRadius: 20,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ComposeMeetingDialog(
                          student: student, classroom: classroom, meeting: meeting, saveMeeting: saveMeeting)),
                );
                if (result != null && result) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.editSuccess)));
                }
              }),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: AppLocalizations.of(context)!.removeMeetingHint,
            splashRadius: 20,
            onPressed: () => removalWithAlert(context, () => removeMeeting(meeting)),
          ),
        ]),
      ),
      title: Row(children: [
        Container(width: 160, child: Text(DateFormat.yMMMEd().format(meeting.at))),
        Text(
          meeting.subject,
          style: const TextStyle(fontStyle: FontStyle.italic),
        )
      ]),
    );
  }
}
