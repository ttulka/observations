import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'student_form.dart';
import 'student_domain.dart';

class EditStudentDialog extends StatelessWidget {
  const EditStudentDialog({required this.student, required this.onEditStudent, Key? key}) : super(key: key);

  final Student student;
  final Function(Student) onEditStudent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editStudentTitle),
      ),
      body: EditStudentForm(
          student: student,
          onEditStudent: (Student student) async {
            await onEditStudent(student);
            Navigator.pop(context, true);
          }),
    );
  }
}

class EditStudentForm extends StatefulWidget {
  const EditStudentForm({required this.student, required this.onEditStudent, Key? key}) : super(key: key);

  final Student student;
  final Function(Student) onEditStudent;

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
        onSave: () async {
          final student = Student(
            id: widget.student.id,
            familyName: familyNameController.text,
            givenName: givenNameController.text,
            classroomId: widget.student.classroomId,
          );
          await widget.onEditStudent(student);
        }).build(context, _formKey);
  }
}
