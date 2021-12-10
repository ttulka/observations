import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../preview_features.dart';
import '../utils/widget_helpers.dart';
import 'service.dart';
import 'domain.dart';
import 'add.dart';
import 'edit.dart';
import '../student/list.dart';

typedef UpdateClassroom = Future<bool> Function(Classroom classroom);

class ClassroomList extends StatefulWidget {
  ClassroomList({Key? key}) : super(key: key);

  final ClassroomService _service = ClassroomService();

  Future<ClassroomPerYear> loadClassrooms() => _service.listAll();
  Future<bool> addClassroom(Classroom classroom) => _service.add(classroom);
  Future<bool> editClassroom(Classroom classroom) => _service.edit(classroom);
  Future<bool> removeClassroom(Classroom classroom) => _service.remove(classroom);
  Future<void> copyClassroom(Classroom classroom) => _service.copyWithStudents(classroom);

  @override
  _ClassroomListState createState() => _ClassroomListState();
}

class _ClassroomListState extends State<ClassroomList> {
  Future<bool> _handleAddClassroom(Classroom classroom, BuildContext context) async {
    // TODO remove this hack when the feature is published:
    if (classroom.name.startsWith('#! ')) {
      execPreviewAction(context, classroom.name);
      setState(() {});
      return false; // prevent from standard action's message
    }
    final result = await widget.addClassroom(classroom);
    setState(() {});
    return result;
  }

  Future<bool> _handleRemoveClassroom(Classroom classroom) async {
    final result = await widget.removeClassroom(classroom);
    setState(() {});
    return result;
  }

  Future<bool> _handleEditClassroom(Classroom classroom) async {
    final result = await widget.editClassroom(classroom);
    setState(() {});
    return result;
  }

  Future<bool> _handleCopyClassroom(Classroom classroom) async {
    await widget.copyClassroom(classroom);
    setState(() {});
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildFutureWidget<ClassroomPerYear>(
        future: widget.loadClassrooms(),
        buildWidget: (categories) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: categories.isNotEmpty
              ? _buildItems(categories)
              : [emptyListTile(AppLocalizations.of(context)!.emptyClassroomList)],
        ),
      ),
      floatingActionButton: buildFloatingAddButton(context, AppLocalizations.of(context)!.addClassroomTitle,
          (ctx) => AddClassroomDialog(addClassroom: (c) => _handleAddClassroom(c, ctx))),
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
            onCopyClassroom: _handleCopyClassroom,
          )));
    }
    return items;
  }
}

class ClassroomListItem extends StatelessWidget {
  ClassroomListItem(
      {required this.classroom,
      required this.onEditClassroom,
      required this.onRemoveClassroom,
      required this.onCopyClassroom})
      : super(key: ObjectKey(classroom));

  final Classroom classroom;

  final UpdateClassroom onEditClassroom;
  final UpdateClassroom onRemoveClassroom;
  final UpdateClassroom onCopyClassroom;

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
            icon: const Icon(Icons.content_copy),
            tooltip: AppLocalizations.of(context)!.copyClassroomHint,
            splashRadius: 20,
            onPressed: () => actionWithAlert(context,
                action: () => onCopyClassroom(classroom),
                alertTitle: AppLocalizations.of(context)!.copyClassroomAlertTitle,
                alertText: AppLocalizations.of(context)!.copyClassroomAlertText,
                successText: AppLocalizations.of(context)!.copySuccess),
          ),
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
                          editClassroom: onEditClassroom,
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
            onPressed: () => removalWithAlert(context, () => onRemoveClassroom(classroom)),
          ),
        ]),
      ),
      title: Text(
        classroom.description,
      ),
    );
  }
}
