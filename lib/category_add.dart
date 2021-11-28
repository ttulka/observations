import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'category_form.dart';
import 'domain.dart';

typedef AddCategory = Function(Category category);

class AddCategoryDialog extends StatelessWidget {
  const AddCategoryDialog({required this.onAddCategory, Key? key})
      : super(key: key);

  final AddCategory onAddCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new category'),
      ),
      body: AddCategoryForm(onAddCategory: (Category category) {
        onAddCategory(category);
        Navigator.pop(context, true);
      }),
    );
  }
}

class AddCategoryForm extends StatefulWidget {
  const AddCategoryForm({required this.onAddCategory, Key? key})
      : super(key: key);

  final AddCategory onAddCategory;

  @override
  AddCategoryFormState createState() => AddCategoryFormState();
}

class AddCategoryFormState extends State<AddCategoryForm> {
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
        document: quill.Document.fromJson(jsonDecode(
            r'[{"insert":"Title 1"},{"insert":"\n","attributes":{"header":1}},{"insert":"\n\n\nTitle 2"},{"insert":"\n","attributes":{"header":1}},{"insert":"\n\n\nTitle 3"},{"insert":"\n","attributes":{"header":1}}]')),
        selection: const TextSelection.collapsed(offset: 0));
  }

  @override
  Widget build(BuildContext context) {
    return CategoryForm(
        nameController: nameController,
        templateController: templateController,
        onSave: () {
          final template =
              jsonEncode(templateController.document.toDelta().toJson());
          final category =
              Category(name: nameController.text, template: template);
          widget.onAddCategory(category);
        }).build(context, _formKey);
  }
}
