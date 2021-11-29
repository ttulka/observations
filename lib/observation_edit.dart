import 'package:flutter/material.dart';
import 'observation_form.dart';
import 'domain.dart';

typedef EditObservation = Function(Observation observation);

class EditObservationDialog extends StatelessWidget {
  const EditObservationDialog({required this.observations, required this.onEditObservation, Key? key})
      : super(key: key);

  final List<Observation> observations;
  final EditObservation onEditObservation;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: observations.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit observations'),
          bottom: TabBar(
            tabs: observations.map((o) => Tab(text: o.category.name)).toList(),
          ),
        ),
        body: EditObservationForm(onEditObservation: onEditObservation, observations: observations),
      ),
    );
  }
}

class EditObservationForm extends StatefulWidget {
  const EditObservationForm({required this.onEditObservation, required this.observations, Key? key}) : super(key: key);

  final EditObservation onEditObservation;
  final List<Observation> observations;

  @override
  EditObservationFormState createState() => EditObservationFormState();
}

class EditObservationFormState extends State<EditObservationForm> {
  @override
  Widget build(BuildContext context) {
    return ObservationForm(
      intialDate: widget.observations.first.date,
      observations: widget.observations,
      onSave: widget.onEditObservation,
    ).build(context, () => Navigator.pop(context, true));
  }
}
