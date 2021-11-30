import 'package:flutter/material.dart';
import 'service.dart';
import 'domain.dart';
import 'student_add.dart';
import 'student_edit.dart';
import 'observation_compose.dart';

typedef ListStudents = List<Student> Function();
typedef RemoveStudent = Function(Student student);
typedef EditStudent = Function(Student oldStudent, Student newStudent);

class StudentList extends StatefulWidget {
  StudentList({required this.classroom, Key? key}) : super(key: key);

  final Classroom classroom;

  final StudentService _service = StudentService();

  final List<Student> students = [];

  void onAddStudent(Student student) {
    _service.add(student);
  }

  void onEditStudent(Student oldStudent, Student newStudent) {
    _service.edit(oldStudent, newStudent);
  }

  void onRemoveStudent(Student student) {
    _service.remove(student);
  }

  void loadStudents() {
    students.clear();
    students.addAll(_service.listByClassroom(classroom));
  }

  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  void _handleAddStudent(Student student) {
    setState(() {
      widget.onAddStudent(student);
      widget.loadStudents();
    });
  }

  void _handleRemoveStudent(Student student) {
    setState(() {
      widget.onRemoveStudent(student);
      widget.loadStudents();
    });
  }

  void _handleEditStudent(Student newStudent, Student oldStudent) {
    setState(() {
      widget.onEditStudent(newStudent, oldStudent);
      widget.loadStudents();
    });
  }

  @override
  void initState() {
    super.initState();
    widget.loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classroom.name +
            (widget.classroom.description.isNotEmpty ? ' (${widget.classroom.description})' : '')),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: widget.students.map((Student student) {
          return StudentListItem(
            student: student,
            classroom: widget.classroom,
            onEditStudent: _handleEditStudent,
            onRemoveStudent: _handleRemoveStudent,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: 'Add a new student',
          child: const Icon(Icons.add),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddStudentDialog(
                        onAddStudent: _handleAddStudent,
                      )),
            );
            if (result != null && result) {
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('Added successfully.')));
            }
          }),
    );
  }
}

class StudentListItem extends StatelessWidget {
  StudentListItem(
      {required this.student, required this.classroom, required this.onEditStudent, required this.onRemoveStudent})
      : super(key: ObjectKey(student));

  final Student student;
  final Classroom classroom;

  final EditStudent onEditStudent;
  final RemoveStudent onRemoveStudent;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ComposeObservationDialog(student: student, classroom: classroom)),
      ),
      leading: const CircleAvatar(
        child: Icon(Icons.face),
      ),
      trailing: FittedBox(
        fit: BoxFit.fill,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit this student',
              splashRadius: 20,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditStudentDialog(
                            student: student,
                            onEditStudent: onEditStudent,
                          )),
                );
                if (result != null && result) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(const SnackBar(content: Text('Edited successfully.')));
                }
              }),
          IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: 'Remove this student',
              splashRadius: 20,
              onPressed: () {
                onRemoveStudent(student);
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('Removed successfully.')));
              }),
        ]),
      ),
      title: Text(
        '${student.familyName}, ${student.givenName}',
      ),
    );
  }
}
