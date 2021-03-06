import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:uuid/uuid.dart';
import 'form.dart';
import 'domain.dart';

class AddCategoryDialog extends StatelessWidget {
  const AddCategoryDialog({required this.addCategory, Key? key}) : super(key: key);

  final Future<bool> Function(Category) addCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(AppLocalizations.of(context)!.addCategoryTitle)),
      ),
      body: AddCategoryForm(onAddCategory: (Category category) async {
        final result = await addCategory(category);
        Navigator.pop(context, result);
      }),
    );
  }
}

class AddCategoryForm extends StatefulWidget {
  const AddCategoryForm({required this.onAddCategory, Key? key}) : super(key: key);

  final Function(Category) onAddCategory;

  @override
  AddCategoryFormState createState() => AddCategoryFormState();
}

class AddCategoryFormState extends State<AddCategoryForm> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final templateController = quill.QuillController.basic();

  @override
  void dispose() {
    nameController.dispose();
    templateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CategoryForm(
        nameController: nameController,
        templateController: templateController,
        onSave: () async {
          final template = jsonEncode(templateController.document.toDelta().toJson());
          final category = Category(
            id: const Uuid().v4(),
            name: nameController.text,
            template: template,
            priority: 0,
          );
          await widget.onAddCategory(category);
        }).build(context, _formKey);
  }
}
