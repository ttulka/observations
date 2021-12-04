import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'form.dart';
import 'domain.dart';

class AddClassroomDialog extends StatelessWidget {
  const AddClassroomDialog({required this.addClassroom, Key? key})
      : super(key: key);

  final Future<bool> Function(Classroom classroom) addClassroom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(AppLocalizations.of(context)!.addClassroomTitle)),
      ),
      body: AddClassroomForm(onAddClassroom: (Classroom classroom) async {
        final result = await addClassroom(classroom);
        Navigator.pop(context, result);
      }),
    );
  }
}

class AddClassroomForm extends StatefulWidget {
  const AddClassroomForm({required this.onAddClassroom, Key? key})
      : super(key: key);

  final Function(Classroom classroom) onAddClassroom;

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
        onSave: () async {
          final classroom = Classroom(
              id: const Uuid().v4(),
              name: nameController.text,
              year: int.parse(yearController.text),
              description: descController.text);
          await widget.onAddClassroom(classroom);
        }).build(context, _formKey);
  }
}
