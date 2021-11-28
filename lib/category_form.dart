import 'package:flutter/material.dart';

class CategoryForm {
  const CategoryForm(
      {required this.nameController,
      required this.templateController,
      required this.onSave});

  final TextEditingController nameController;
  final TextEditingController templateController;

  final Function onSave;

  Widget build(BuildContext context, GlobalKey<FormState> formKey) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            newTextField('Name', nameController, true, 50),
            newTextAreaField('Template', templateController, 1000),
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
      bool required, int maxLength,
      {RegExp? filter}) {
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

  Widget newTextAreaField(
      String label, TextEditingController controller, int maxLength) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: TextFormField(
        minLines: 20,
        maxLines: 100,
        controller: controller,
        decoration: InputDecoration(
          border: const UnderlineInputBorder(),
          labelText: label,
        ),
        maxLength: maxLength,
      ),
    );
  }
}
