import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../utils/widget_helpers.dart';

class CategoryForm {
  const CategoryForm({required this.nameController, required this.templateController, required this.onSave});

  final TextEditingController nameController;
  final quill.QuillController templateController;

  final Function onSave;

  Widget build(BuildContext context, GlobalKey<FormState> formKey) {
    return Column(children: [
      Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _newTextField(context, AppLocalizations.of(context)!.categoryName, nameController, true, 50),
            ],
          ),
        ),
      ),
      Expanded(child: buildRichTextEditor(templateController)),
      Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 32),
        child: ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              onSave();
            }
          },
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
          child: Text(AppLocalizations.of(context)!.formSave, style: const TextStyle(fontSize: 22.0)),
        ),
      )
    ]);
  }

  static Widget _newTextField(
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
