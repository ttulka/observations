import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ClassroomForm {
  const ClassroomForm(
      {required this.nameController, required this.yearController, required this.descController, required this.onSave});

  final TextEditingController nameController;
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
            newTextField(context, AppLocalizations.of(context)!.classroomName, nameController, true, 5),
            newTextField(context, AppLocalizations.of(context)!.classroomYear, yearController, true, 4,
                filter: RegExp(r'^\d{4}$')),
            newTextField(context, AppLocalizations.of(context)!.classroomDescription, descController, false, 50),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    onSave();
                  }
                },
                child: Text(AppLocalizations.of(context)!.formSave),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget newTextField(
      BuildContext context, String label, TextEditingController controller, bool required, int maxLength,
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
            return AppLocalizations.of(context)!.formRequired;
          }
          if (filter != null && value != null && !filter.hasMatch(value)) {
            return AppLocalizations.of(context)!.formInvalid;
          }
          return null;
        },
        maxLength: maxLength,
      ),
    );
  }
}
