import 'package:flutter/material.dart';
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
  final templateController = TextEditingController();

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
        onSave: () {
          final category = Category(
              name: nameController.text, template: templateController.text);
          widget.onAddCategory(category);
        }).build(context, _formKey);
  }
}
