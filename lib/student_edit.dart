import 'package:flutter/material.dart';
import 'student_form.dart';
import 'domain.dart';

typedef EditStudent = Function(Student oldStudent, Student newStudent);

class EditStudentDialog extends StatelessWidget {
  const EditStudentDialog(
      {required this.student, required this.onEditStudent, Key? key})
      : super(key: key);

  final Student student;
  final EditStudent onEditStudent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit a student'),
      ),
      body: EditStudentForm(
          student: student,
          onEditStudent: (Student oldStudent, Student newStudent) {
            onEditStudent(oldStudent, newStudent);
            Navigator.pop(context, true);
          }),
    );
  }
}

class EditStudentForm extends StatefulWidget {
  const EditStudentForm(
      {required this.student, required this.onEditStudent, Key? key})
      : super(key: key);

  final Student student;
  final EditStudent onEditStudent;

  @override
  EditStudentFormState createState() => EditStudentFormState();
}

class EditStudentFormState extends State<EditStudentForm> {
  final _formKey = GlobalKey<FormState>();

  final familyNameController = TextEditingController();
  final givenNameController = TextEditingController();

  @override
  void dispose() {
    familyNameController.dispose();
    givenNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    familyNameController.text = widget.student.familyName;
    givenNameController.text = widget.student.givenName;
  }

  @override
  Widget build(BuildContext context) {
    return StudentForm(
        familyNameController: familyNameController,
        givenNameController: givenNameController,
        onSave: () {
          final newStudent = Student(
              id: widget.student.id,
              familyName: familyNameController.text,
              givenName: givenNameController.text);
          widget.onEditStudent(widget.student, newStudent);
        }).build(context, _formKey);
  }
}
