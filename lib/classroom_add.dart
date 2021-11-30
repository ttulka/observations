import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'classroom_form.dart';
import 'domain.dart';

typedef AddClassroom = Function(Classroom classroom);

class AddClassroomDialog extends StatelessWidget {
  const AddClassroomDialog({required this.onAddClassroom, Key? key}) : super(key: key);

  final AddClassroom onAddClassroom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addClassroomTitle),
      ),
      body: AddClassroomForm(onAddClassroom: (Classroom classroom) {
        onAddClassroom(classroom);
        Navigator.pop(context, true);
      }),
    );
  }
}

class AddClassroomForm extends StatefulWidget {
  const AddClassroomForm({required this.onAddClassroom, Key? key}) : super(key: key);

  final AddClassroom onAddClassroom;

  @override
  AddClassroomFormState createState() => AddClassroomFormState();
}

class AddClassroomFormState extends State<AddClassroomForm> {
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
    yearController.text = DateTime.now().year.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ClassroomForm(
        nameController: nameController,
        yearController: yearController,
        descController: descController,
        onSave: () {
          final classroom = Classroom(
              id: const Uuid().v4(),
              name: nameController.text,
              year: int.parse(yearController.text),
              description: descController.text);
          widget.onAddClassroom(classroom);
        }).build(context, _formKey);
  }
}
