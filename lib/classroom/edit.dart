import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'form.dart';
import 'domain.dart';

class EditClassroomDialog extends StatelessWidget {
  const EditClassroomDialog({required this.classroom, required this.editClassroom, Key? key}) : super(key: key);

  final Classroom classroom;
  final Future<bool> Function(Classroom) editClassroom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editClassroomTitle),
      ),
      body: EditClassroomForm(
          classroom: classroom,
          onEditClassroom: (Classroom classroom) async {
            final result = await editClassroom(classroom);
            Navigator.pop(context, result);
          }),
    );
  }
}

class EditClassroomForm extends StatefulWidget {
  const EditClassroomForm({required this.classroom, required this.onEditClassroom, Key? key}) : super(key: key);

  final Classroom classroom;
  final Function(Classroom) onEditClassroom;

  @override
  EditClassroomFormState createState() => EditClassroomFormState();
}

class EditClassroomFormState extends State<EditClassroomForm> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final yearController = TextEditingController();
  final descController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    yearController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    nameController.text = widget.classroom.name;
    yearController.text = widget.classroom.year.toString();
    descController.text = widget.classroom.description;
  }

  @override
  Widget build(BuildContext context) {
    return ClassroomForm(
        nameController: nameController,
        yearController: yearController,
        descController: descController,
        onSave: () async {
          final classroom = Classroom(
              id: widget.classroom.id,
              name: nameController.text,
              year: int.parse(yearController.text),
              description: descController.text);
          await widget.onEditClassroom(classroom);
        }).build(context, _formKey);
  }
}
