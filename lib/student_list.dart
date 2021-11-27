import 'package:flutter/material.dart';
import 'service.dart';
import 'domain.dart';
import 'classroom_add.dart';

typedef ListStudents = List<Student> Function();
typedef RemoveStudent = Function(Student student);
typedef EditStudent = Function(Student student);

class StudentList extends StatefulWidget {
  StudentList({required this.classroom, Key? key}) : super(key: key);

  final Classroom classroom;

  final StudentService _service = StudentService();

  final List<Student> students = [];

  void onAddStudent(Student student) {
    //_service.add(classroom);
  }

  void onEditClassroom(Student student) {
    //_service.edit(classroom);
  }

  void onRemoveClassroom(Student student) {
    //_service.remove(classroom);
  }

  void loadStudents() {
    students.addAll(_service.listByClassroom(classroom));
  }

  @override
  _StudentListState createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  void _handleAddStudent(Student student) {
    setState(() {
      widget.students.add(student);
      widget.onAddStudent(student);
    });
  }

  void _handleRemoveClassroom(Student student) {
    setState(() {
      widget.students.remove(student);
      widget.onRemoveClassroom(student);
    });
  }

  void _handleEditClassroom(Student student) {
    setState(() {
      // TODO
      widget.onEditClassroom(student);
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
        title: const Text('Class TODO Class Name'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: widget.students.map((Student student) {
          return StudentListItem(
            student: student,
            onEditClassroom: _handleEditClassroom,
            onRemoveClassroom: _handleRemoveClassroom,
          );
        }).toList(),
      ),
      // floatingActionButton: FloatingActionButton(
      //     tooltip: 'Add a new student',
      //     child: const Icon(Icons.add),
      //     onPressed: () => Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //               builder: (context) => AddClassroomDialog(
      //                     onAddClassroom: _handleAddStudent,
      //                   )),
      //         )),
    );
  }
}

class StudentListItem extends StatelessWidget {
  StudentListItem(
      {required this.student,
      required this.onEditClassroom,
      required this.onRemoveClassroom})
      : super(key: ObjectKey(student));

  final Student student;

  final EditStudent onEditClassroom;
  final RemoveStudent onRemoveClassroom;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // onTap: () => Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => AddClassroomDialog(
      //             onAddClassroom: _handleAddClassroom,
      //           )),
      // ),
      leading: const CircleAvatar(
        //backgroundColor: _getColor(context),
        child: Icon(Icons.face),
      ),
      trailing: FittedBox(
        fit: BoxFit.fill,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit this student',
            splashRadius: 10,
            hoverColor: Colors.yellow[200],
            onPressed: () => onEditClassroom(student),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: 'Remove this student',
            splashRadius: 10,
            hoverColor: Colors.red[200],
            onPressed: () => onRemoveClassroom(student),
          ),
        ]),
      ),
      title: Text(
        student.givenName + ' ' + student.familyName,
      ),
    );
  }
}
