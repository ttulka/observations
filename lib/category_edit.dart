import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:uuid/uuid.dart';
import 'category_form.dart';
import 'domain.dart';

typedef EditCategory = Function(Category oldCategory, Category newCategory);

class EditCategoryDialog extends StatelessWidget {
  const EditCategoryDialog({required this.category, required this.onEditCategory, Key? key}) : super(key: key);

  final Category category;
  final EditCategory onEditCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editCategoryTitle),
      ),
      body: EditCategoryForm(
          category: category,
          onEditCategory: (Category oldCategory, Category newCategory) {
            onEditCategory(oldCategory, newCategory);
            Navigator.pop(context, true);
          }),
    );
  }
}

class EditCategoryForm extends StatefulWidget {
  const EditCategoryForm({required this.category, required this.onEditCategory, Key? key}) : super(key: key);

  final Category category;
  final EditCategory onEditCategory;

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
    nameController.text = widget.category.name;
    templateController = quill.QuillController(
        document: quill.Document.fromJson(jsonDecode(widget.category.template)),
        selection: const TextSelection.collapsed(offset: 0));
  }

  @override
  Widget build(BuildContext context) {
    return CategoryForm(
        nameController: nameController,
        templateController: templateController,
        onSave: () {
          final template = jsonEncode(templateController.document.toDelta().toJson());
          final newCategory = Category(id: const Uuid().v4(), name: nameController.text, template: template);
          widget.onEditCategory(widget.category, newCategory);
        }).build(context, _formKey);
  }
}
