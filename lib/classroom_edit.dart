import 'package:flutter/material.dart';
import 'classroom_form.dart';
import 'domain.dart';

typedef EditClassroom = Function(
    Classroom oldClassroom, Classroom newClassroom);

class EditClassroomDialog extends StatelessWidget {
  const EditClassroomDialog(
      {required this.classroom, required this.onEditClassroom, Key? key})
      : super(key: key);

  final Classroom classroom;
  final EditClassroom onEditClassroom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit a classroom'),
      ),
      body: EditClassroomForm(
          classroom: classroom,
          onEditClassroom: (Classroom oldClassroom, Classroom newClassroom) {
            onEditClassroom(oldClassroom, newClassroom);
            Navigator.pop(context);
          }),
    );
  }
}

class EditClassroomForm extends StatefulWidget {
  const EditClassroomForm(
      {required this.classroom, required this.onEditClassroom, Key? key})
      : super(key: key);

  final Classroom classroom;
  final EditClassroom onEditClassroom;

  @override
  EditClassroomFormState createState() => EditClassroomFormState();
}

class EditClassroomFormState extends State<EditClassroomForm> {
  final _formKey = GlobalKey<FormState>();

  final idController = TextEditingController();
  final yearController = TextEditingController();
  final descController = TextEditingController();

  @override
  void dispose() {
    idController.dispose();
    yearController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    idController.text = widget.classroom.id;
    yearController.text = widget.classroom.year.toString();
    descController.text = widget.classroom.description;
  }

  @override
  Widget build(BuildContext context) {
    return ClassroomForm(
        idController: idController,
        yearController: yearController,
        descController: descController,
        onSave: () {
          final newClassroom = Classroom(
              id: idController.text,
              year: int.parse(yearController.text),
              description: descController.text);
          widget.onEditClassroom(widget.classroom, newClassroom);
        }).build(context, _formKey);
  }
}
