import 'package:flutter/material.dart';
import 'service.dart';
import 'domain.dart';
import 'classroom_add.dart';
import 'classroom_edit.dart';
import 'student_list.dart';

typedef ListClassrooms = List<Classroom> Function();
typedef RemoveClassroom = Function(Classroom classroom);

class ClassroomList extends StatefulWidget {
  ClassroomList({Key? key}) : super(key: key);

  final ClassroomService _service = ClassroomService();

  final Map<int, List<Classroom>> classrooms = {};

  void onAddClassroom(Classroom classroom) {
    _service.add(classroom);
  }

  void onEditClassroom(Classroom oldClassroom, Classroom newClassroom) {
    _service.edit(oldClassroom, newClassroom);
  }

  void onRemoveClassroom(Classroom classroom) {
    _service.remove(classroom);
  }

  void loadClassrooms() {
    classrooms.clear();
    classrooms.addAll(_service.listAll());
  }

  @override
  _ClassroomListState createState() => _ClassroomListState();
}

class _ClassroomListState extends State<ClassroomList> {
  void _handleAddClassroom(Classroom classroom) {
    setState(() {
      widget.onAddClassroom(classroom);
      widget.loadClassrooms();
    });
  }

  void _handleRemoveClassroom(Classroom classroom) {
    setState(() {
      widget.onRemoveClassroom(classroom);
      widget.loadClassrooms();
    });
  }

  void _handleEditClassroom(Classroom oldClassroom, Classroom newClassroom) {
    setState(() {
      widget.onEditClassroom(oldClassroom, newClassroom);
      widget.loadClassrooms();
    });
  }

  @override
  void initState() {
    super.initState();
    widget.loadClassrooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: _buildItems(),
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: 'Add a new classroom',
          child: const Icon(Icons.add),
          onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddClassroomDialog(
                          onAddClassroom: _handleAddClassroom,
                        )),
              )),
    );
  }

  List<Widget> _buildItems() {
    final List<Widget> items = [];
    for (final entry in widget.classrooms.entries) {
      items.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 68, vertical: 14),
          child: Text(entry.key.toString(),
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))));
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
  ClassroomListItem(
      {required this.classroom,
      required this.onEditClassroom,
      required this.onRemoveClassroom})
      : super(key: ObjectKey(classroom));

  final Classroom classroom;

  final EditClassroom onEditClassroom;
  final RemoveClassroom onRemoveClassroom;

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
        //backgroundColor: _getColor(context),
        child: Text(classroom.id),
      ),
      trailing: FittedBox(
        fit: BoxFit.fill,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit this classroom',
            splashRadius: 10,
            hoverColor: Colors.yellow[200],
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditClassroomDialog(
                        classroom: classroom,
                        onEditClassroom: onEditClassroom,
                      )),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: 'Remove this classroom',
            splashRadius: 10,
            hoverColor: Colors.red[200],
            onPressed: () => onRemoveClassroom(classroom),
          ),
        ]),
      ),
      title: Text(
        classroom.description,
      ),
    );
  }
}
