import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'service.dart';
import 'domain.dart';
import 'observation_add.dart';
// import 'observation_edit.dart';

typedef ListObservations = List<Observation> Function();
typedef RemoveObservation = Function(DateTime date);
typedef EditObservation = Function(Observation oldObservation, Observation newObservation);

class ObservationList extends StatefulWidget {
  ObservationList({required this.student, Key? key}) : super(key: key);

  final Student student;

  final ObservationService _service = ObservationService();

  final Map<DateTime, List<Observation>> observations = {};

  void onAddObservation(Observation observation) {
    _service.add(observation);
  }

  void onEditObservation(Observation oldObservation, Observation newObservation) {
    _service.edit(oldObservation, newObservation);
  }

  void onRemoveObservation(DateTime date) {
    _service.removeByDate(date);
  }

  void loadObservations() {
    observations.clear();
    observations.addAll(_service.listByStudent(student));
  }

  @override
  _ObservationListState createState() => _ObservationListState();
}

class _ObservationListState extends State<ObservationList> {
  void _handleAddObservation(Observation observation) {
    setState(() {
      widget.onAddObservation(observation);
      widget.loadObservations();
    });
  }

  void _handleRemoveObservation(DateTime date) {
    setState(() {
      widget.onRemoveObservation(date);
      widget.loadObservations();
    });
  }

  void _handleEditObservation(Observation newObservation, Observation oldObservation) {
    setState(() {
      widget.onEditObservation(newObservation, oldObservation);
      widget.loadObservations();
    });
  }

  @override
  void initState() {
    super.initState();
    widget.loadObservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.student.familyName}, ${widget.student.givenName}'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: widget.observations.entries.map((entry) {
          return ObservationListItem(
            date: entry.key,
            observations: entry.value,
            onEditObservation: _handleEditObservation,
            onRemoveObservation: _handleRemoveObservation,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: 'Add a new observation',
          child: const Icon(Icons.add),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddObservationDialog(
                        onAddObservation: _handleAddObservation,
                      )),
            );
            if (result != null && result) {
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('Added successfully.')));
            }
          }),
    );
  }
}

class ObservationListItem extends StatelessWidget {
  ObservationListItem(
      {required this.date,
      required this.observations,
      required this.onEditObservation,
      required this.onRemoveObservation})
      : super(key: ObjectKey(date));

  final DateTime date;
  final List<Observation> observations;

  final EditObservation onEditObservation;
  final RemoveObservation onRemoveObservation;

  final _formatter = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // onTap: () => Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) =>
      //           ObservationDetail(date: date, observations: observations)),
      // ),
      leading: const CircleAvatar(
        child: Icon(Icons.assignment),
      ),
      trailing: FittedBox(
        fit: BoxFit.fill,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit this observation',
              splashRadius: 20,
              onPressed: () async {
                // final result = await Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => EditObservationDialog(
                //             date: date,
                //             observations: observations,
                //             onEditObservation: onEditObservation,
                //           )),
                // );
                // if (result != null && result) {
                //   ScaffoldMessenger.of(context)
                //     ..removeCurrentSnackBar()
                //     ..showSnackBar(
                //         const SnackBar(content: Text('Edited successfully.')));
                // }
              }),
          IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: 'Remove this observation',
              splashRadius: 20,
              onPressed: () {
                onRemoveObservation(date);
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('Removed successfully.')));
              }),
        ]),
      ),
      title: Text(_formatter.format(date)),
    );
  }
}
