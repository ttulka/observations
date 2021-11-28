import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'student_form.dart';
import 'domain.dart';

typedef AddStudent = Function(Student student);

class AddStudentDialog extends StatelessWidget {
  const AddStudentDialog({required this.onAddStudent, Key? key})
      : super(key: key);

  final AddStudent onAddStudent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new student'),
      ),
      body: AddStudentForm(onAddStudent: (Student student) {
        onAddStudent(student);
        Navigator.pop(context, true);
      }),
    );
  }
}

class AddStudentForm extends StatefulWidget {
  const AddStudentForm({required this.onAddStudent, Key? key})
      : super(key: key);

  final AddStudent onAddStudent;

  @override
  AddStudentFormState createState() => AddStudentFormState();
}

class AddStudentFormState extends State<AddStudentForm> {
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
  Widget build(BuildContext context) {
    return StudentForm(
        familyNameController: familyNameController,
        givenNameController: givenNameController,
        onSave: () {
          final student = Student(
              id: const Uuid().v4(),
              familyName: familyNameController.text,
              givenName: givenNameController.text);
          widget.onAddStudent(student);
        }).build(context, _formKey);
  }
}
