import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'widget_helpers.dart';
import 'student_service.dart';
import 'student_domain.dart';
import 'classroom_domain.dart';
import 'student_add.dart';
import 'student_edit.dart';
import 'observation_compose.dart';

typedef UpdateStudent = Function(Student student);

class StudentList extends StatefulWidget {
  StudentList({required this.classroom, Key? key}) : super(key: key);

  final Classroom classroom;

  final StudentService _service = StudentService();

  Future<void> onAddStudent(Student student) => _service.add(student);
  Future<void> onEditStudent(Student student) => _service.edit(student);
  Future<void> onRemoveStudent(Student student) => _service.remove(student);
  Future<List<Student>> loadStudents() => _service.listByClassroom(classroom);

  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  Future<void> _handleAddStudent(Student student) async {
    await widget.onAddStudent(student);
    setState(() {});
  }

  Future<void> _handleRemoveStudent(Student student) async {
    await widget.onRemoveStudent(student);
    setState(() {});
  }

  Future<void> _handleEditStudent(Student student) async {
    await widget.onEditStudent(student);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classroom.name +
            (widget.classroom.description.isNotEmpty ? ' (${widget.classroom.description})' : '')),
      ),
      body: buildFutureWidget<List<Student>>(
        future: widget.loadStudents(),
        buildWidget: (students) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: students.map((Student student) {
            return StudentListItem(
              student: student,
              classroom: widget.classroom,
              onEditStudent: _handleEditStudent,
              onRemoveStudent: _handleRemoveStudent,
            );
          }).toList(),
        ),
      ),
      floatingActionButton: buildFloatingAddButton(
          context, (c) => AddStudentDialog(classroom: widget.classroom, onAddStudent: _handleAddStudent)),
    );
  }
}

class StudentListItem extends StatelessWidget {
  StudentListItem(
      {required this.student, required this.classroom, required this.onEditStudent, required this.onRemoveStudent})
      : super(key: ObjectKey(student));

  final Student student;
  final Classroom classroom;

  final UpdateStudent onEditStudent;
  final UpdateStudent onRemoveStudent;

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
              icon: const Icon(Icons.edit),
              tooltip: AppLocalizations.of(context)!.editStudentHint,
              splashRadius: 20,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditStudentDialog(student: student, onEditStudent: onEditStudent)),
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
