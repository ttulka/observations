import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'form.dart';
import 'domain.dart';
import '../classroom/domain.dart';

class AddStudentDialog extends StatelessWidget {
  const AddStudentDialog({required this.classroom, required this.onAddStudent, Key? key}) : super(key: key);

  final Classroom classroom;
  final Function(Student) onAddStudent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addStudentTitle),
      ),
      body: AddStudentForm(
          classroom: classroom,
          onAddStudent: (Student student) async {
            await onAddStudent(student);
            Navigator.pop(context, true);
          }),
    );
  }
}

class AddStudentForm extends StatefulWidget {
  const AddStudentForm({required this.classroom, required this.onAddStudent, Key? key}) : super(key: key);

  final Classroom classroom;
  final Function(Student) onAddStudent;

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
        onSave: () async {
          final student = Student(
            id: const Uuid().v4(),
            familyName: familyNameController.text,
            givenName: givenNameController.text,
            classroomId: widget.classroom.id,
          );
          await widget.onAddStudent(student);
        }).build(context, _formKey);
  }
}
