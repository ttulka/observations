import 'package:flutter/material.dart';
import 'category_form.dart';
import 'domain.dart';

typedef EditCategory = Function(Category oldCategory, Category newCategory);

class EditCategoryDialog extends StatelessWidget {
  const EditCategoryDialog(
      {required this.category, required this.onEditCategory, Key? key})
      : super(key: key);

  final Category category;
  final EditCategory onEditCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit a category'),
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
  const EditCategoryForm(
      {required this.category, required this.onEditCategory, Key? key})
      : super(key: key);

  final Category category;
  final EditCategory onEditCategory;

  @override
  EditCategoryFormState createState() => EditCategoryFormState();
}

class EditCategoryFormState extends State<EditCategoryForm> {
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
  void initState() {
    super.initState();
    nameController.text = widget.category.name;
    templateController.text = widget.category.template;
  }

  @override
  Widget build(BuildContext context) {
    return CategoryForm(
        nameController: nameController,
        templateController: templateController,
        onSave: () {
          final newCategory = Category(
              name: nameController.text, template: templateController.text);
          widget.onEditCategory(widget.category, newCategory);
        }).build(context, _formKey);
  }
}
