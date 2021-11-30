import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'widget_helpers.dart';
import 'classroom_service.dart';
import 'classroom_domain.dart';
import 'classroom_add.dart';
import 'classroom_edit.dart';
import 'student_list.dart';

typedef UpdateClassroom = Function(Classroom classroom);

class ClassroomList extends StatefulWidget {
  ClassroomList({Key? key}) : super(key: key);

  final ClassroomService _service = ClassroomService();

  Future<void> onAddClassroom(Classroom classroom) => _service.add(classroom);
  Future<void> onEditClassroom(Classroom classroom) => _service.edit(classroom);
  Future<void> onRemoveClassroom(Classroom classroom) => _service.remove(classroom);
  Future<ClassroomPerYear> loadClassrooms() => _service.listAll();

  @override
  _ClassroomListState createState() => _ClassroomListState();
}

class _ClassroomListState extends State<ClassroomList> {
  Future<void> _handleAddClassroom(Classroom classroom) async {
    await widget.onAddClassroom(classroom);
    setState(() {});
  }

  Future<void> _handleRemoveClassroom(Classroom classroom) async {
    await widget.onRemoveClassroom(classroom);
    setState(() {});
  }

  Future<void> _handleEditClassroom(Classroom classroom) async {
    await widget.onEditClassroom(classroom);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildFutureWidget<ClassroomPerYear>(
        future: widget.loadClassrooms(),
        buildWidget: (categories) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: _buildItems(categories),
        ),
      ),
      floatingActionButton:
          buildFloatingAddButton(context, (c) => AddClassroomDialog(onAddClassroom: _handleAddClassroom)),
    );
  }

  List<Widget> _buildItems(ClassroomPerYear classrooms) {
    final List<Widget> items = [];
    for (final entry in classrooms.entries) {
      items.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 68, vertical: 14),
          child: Text('${entry.key}/${entry.key + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))));
      items.addAll(entry.value.map((c) => ClassroomListItem(
            classroom: c,
            onEditClassroom: _handleEditClassroom,
            onRemoveClassroom: _handleRemoveClassroom,
          )));
    }
    return items;
  }
}

class ClassroomListItem extends StatelessWidget {
  ClassroomListItem({required this.classroom, required this.onEditClassroom, required this.onRemoveClassroom})
      : super(key: ObjectKey(classroom));

  final Classroom classroom;

  final UpdateClassroom onEditClassroom;
  final UpdateClassroom onRemoveClassroom;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => StudentList(
                  classroom: classroom,
                )),
      ),
      leading: CircleAvatar(
        child: Text(classroom.name),
      ),
      trailing: FittedBox(
        fit: BoxFit.fill,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: AppLocalizations.of(context)!.editClassroomHint,
            splashRadius: 20,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditClassroomDialog(
                          classroom: classroom,
                          onEditClassroom: onEditClassroom,
                        )),
              );
              if (result != null && result) {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.editSuccess)));
              }
            },
          ),
          IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: AppLocalizations.of(context)!.removeClassroomHint,
              splashRadius: 20,
              onPressed: () async {
                await onRemoveClassroom(classroom);
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.removeSuccess)));
              }),
        ]),
      ),
      title: Text(
        classroom.description,
      ),
    );
  }
}
