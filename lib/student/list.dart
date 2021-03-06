import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/widget_helpers.dart';
import '../utils/printing.dart';
import '../property/service.dart';
import '../classroom/domain.dart';
import '../observation/domain.dart';
import '../observation/service.dart';
import '../observation/compose.dart';
import '../meeting/list.dart';
import 'domain.dart';
import 'service.dart';
import 'add.dart';
import 'edit.dart';

typedef UpdateStudent = Future<bool> Function(Student student);

class StudentList extends StatefulWidget {
  StudentList({required this.classroom, Key? key}) : super(key: key);

  final Classroom classroom;

  final StudentService _service = StudentService();
  final ObservationService _observationService = ObservationService();
  final PropertyService _propertyService = PropertyService();

  Future<List<Student>> loadStudents() => _service.listByClassroom(classroom);
  Future<bool> addStudent(Student student) => _service.add(student);
  Future<bool> editStudent(Student student) => _service.edit(student);
  Future<bool> removeStudent(Student student) => _service.remove(student);
  Future<List<Observation>> loadObservations(Student student) => _observationService.listByStudent(student);

  Future<bool> printingConvertToHtmlActive() => _propertyService.printingConvertToHtmlActive();

  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  Future<bool> _handleAddStudent(Student student) async {
    final result = await widget.addStudent(student);
    setState(() {});
    return result;
  }

  Future<bool> _handleRemoveStudent(Student student) async {
    final result = await widget.removeStudent(student);
    setState(() {});
    return result;
  }

  Future<bool> _handleEditStudent(Student student) async {
    final result = await widget.editStudent(student);
    setState(() {});
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(widget.classroom.name +
                (widget.classroom.description.isNotEmpty ? ' (${widget.classroom.description})' : ''))),
      ),
      body: buildFutureWidget<List<Student>>(
        future: widget.loadStudents(),
        buildWidget: (students) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: students.isNotEmpty
              ? students
                  .map((Student student) => StudentListItem(
                        student: student,
                        classroom: widget.classroom,
                        loadObservations: widget.loadObservations,
                        printingConvertToHtmlActive: widget.printingConvertToHtmlActive(),
                        onEditStudent: _handleEditStudent,
                        onRemoveStudent: _handleRemoveStudent,
                      ))
                  .toList()
              : [emptyListTile(AppLocalizations.of(context)!.emptyStudentList)],
        ),
      ),
      floatingActionButton: buildFloatingAddButton(context, AppLocalizations.of(context)!.addStudentTitle,
          (ctx) => AddStudentDialog(classroom: widget.classroom, addStudent: _handleAddStudent)),
    );
  }
}

class StudentListItem extends StatelessWidget {
  StudentListItem({
    required this.student,
    required this.classroom,
    required this.onEditStudent,
    required this.onRemoveStudent,
    required this.loadObservations,
    required this.printingConvertToHtmlActive,
  }) : super(key: ObjectKey(student));

  final Student student;
  final Classroom classroom;

  final UpdateStudent onEditStudent;
  final UpdateStudent onRemoveStudent;

  final Future<List<Observation>> Function(Student) loadObservations;
  final Future<bool> printingConvertToHtmlActive;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ComposeObservationDialog(student: student, classroom: classroom)),
        );
        if (result != null && result) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.editSuccess)));
        }
      },
      leading: const CircleAvatar(
        child: Icon(Icons.face),
      ),
      trailing: FittedBox(
        fit: BoxFit.fill,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: AppLocalizations.of(context)!.printStudentObservationsHint,
            splashRadius: 20,
            onPressed: () async {
              final observations = await loadObservations(student);
              await showPrintDialogForObservations(context, observations,
                  classroom: classroom, student: student, htmlConvert: await printingConvertToHtmlActive);
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: AppLocalizations.of(context)!.pdfStudentObservationsHint,
            splashRadius: 20,
            onPressed: () async {
              final observations = await loadObservations(student);
              final result = await showSaveDialogForObservations(context, observations,
                  classroom: classroom, student: student, htmlConvert: await printingConvertToHtmlActive);
              if (result) {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.saveSuccess)));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: AppLocalizations.of(context)!.meetingStudentHint,
            splashRadius: 20,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MeetingList(student: student, classroom: classroom)),
              );
            },
          ),
          IconButton(
              icon: const Icon(Icons.edit),
              tooltip: AppLocalizations.of(context)!.editStudentHint,
              splashRadius: 20,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditStudentDialog(student: student, editStudent: onEditStudent)),
                );
                if (result != null && result) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.editSuccess)));
                }
              }),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: AppLocalizations.of(context)!.removeStudentHint,
            splashRadius: 20,
            onPressed: () => removalWithAlert(context, () => onRemoveStudent(student)),
          ),
        ]),
      ),
      title: Text('${student.familyName}, ${student.givenName}'),
    );
  }
}
