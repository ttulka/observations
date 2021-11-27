import 'package:flutter/material.dart';

class ClassroomForm {
  const ClassroomForm(
      {required this.idController,
      required this.yearController,
      required this.descController,
      required this.onSave});

  final TextEditingController idController;
  final TextEditingController yearController;
  final TextEditingController descController;

  final Function onSave;

  Widget build(BuildContext context, GlobalKey<FormState> formKey) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            newTextField('Classroom ID', idController, true, 5, null),
            newTextField('Starting school year', yearController, true, 4,
                RegExp(r'^\d{4}$')),
            newTextField('Classroom Description (optional)', descController,
                false, 50, null),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    onSave();
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget newTextField(String label, TextEditingController controller,
      bool required, int maxLength, RegExp? filter) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: label,
        ),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Required';
          }
          if (filter != null && value != null && !filter.hasMatch(value)) {
            return 'Invalid value';
          }
          return null;
        },
        maxLength: maxLength,
      ),
    );
  }
}
