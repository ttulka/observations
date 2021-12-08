import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

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
      Expanded(child: _newTextAreaField(templateController, 1000)),
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

  static Widget _newTextAreaField(quill.QuillController controller, int maxLength) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: quill.QuillToolbar.basic(
              controller: controller,
              showInlineCode: false,
              showImageButton: false,
              showVideoButton: false,
              showCameraButton: false,
              showListCheck: false,
              showBackgroundColorButton: false, // it can't be printed
              showLink: false, // it can't be printed
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(width: 2.0, color: Colors.grey), borderRadius: BorderRadius.circular(10.0)),
              child: quill.QuillEditor(
                controller: controller,
                readOnly: false, // true for view only mode
                autoFocus: true,
                scrollable: true,
                focusNode: FocusNode(),
                scrollController: ScrollController(),
                padding: const EdgeInsets.all(16.0),
                expands: true,
              ),
            ),
          )
        ],
      ),
    );
  }
}
