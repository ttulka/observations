import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'form.dart';
import 'domain.dart';

class EditCategoryDialog extends StatelessWidget {
  const EditCategoryDialog({required this.category, required this.editCategory, Key? key}) : super(key: key);

  final Category category;
  final Future<bool> Function(Category) editCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editCategoryTitle),
      ),
      body: EditCategoryForm(
          category: category,
          onEditCategory: (Category category) async {
            final result = await editCategory(category);
            Navigator.pop(context, result);
          }),
    );
  }
}

class EditCategoryForm extends StatefulWidget {
  const EditCategoryForm({required this.category, required this.onEditCategory, Key? key}) : super(key: key);

  final Category category;
  final Function(Category) onEditCategory;

  @override
  EditCategoryFormState createState() => EditCategoryFormState();
}

class EditCategoryFormState extends State<EditCategoryForm> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  late quill.QuillController templateController;

  @override
  void dispose() {
    nameController.dispose();
    templateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    templateController = quill.QuillController(
        document: widget.category.template.isNotEmpty
            ? quill.Document.fromJson(jsonDecode(widget.category.template))
            : quill.Document(),
        selection: const TextSelection.collapsed(offset: 0));
  }

  @override
  Widget build(BuildContext context) {
    nameController.text = widget.category.localizedName(AppLocalizations.of(context)!);
    return CategoryForm(
        nameController: nameController,
        templateController: templateController,
        onSave: () async {
          final template = jsonEncode(templateController.document.toDelta().toJson());
          final category = Category(
            id: widget.category.id,
            name: nameController.text,
            template: template,
          );
          await widget.onEditCategory(category);
        }).build(context, _formKey);
  }
}
