import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/widget_helpers.dart';
import 'domain.dart';
import 'service.dart';
import 'add.dart';
import 'edit.dart';

typedef UpdateCategory = Future<bool> Function(Category category);

class CategoryList extends StatefulWidget {
  CategoryList({Key? key}) : super(key: key);

  final CategoryService _service = CategoryService();

  Future<bool> addCategory(Category category) => _service.add(category);
  Future<bool> editCategory(Category category) => _service.edit(category);
  Future<bool> removeCategory(Category category) => _service.remove(category);
  Future<bool> upCategory(Category category) => _service.up(category);
  Future<bool> downCategory(Category category) => _service.down(category);
  Future<List<Category>> loadCategories() => _service.listAll();

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  Future<bool> _handleAddCategory(Category category) async {
    final result = await widget.addCategory(category);
    setState(() {});
    return result;
  }

  Future<bool> _handleEditCategory(Category category) async {
    final result = await widget.editCategory(category);
    setState(() {});
    return result;
  }

  Future<bool> _handleRemoveCategory(Category category) async {
    final result = await widget.removeCategory(category);
    setState(() {});
    return result;
  }

  Future<bool> _handleUpCategory(Category category) async {
    final result = await widget.upCategory(category);
    setState(() {});
    return result;
  }

  Future<bool> _handleDownCategory(Category category) async {
    final result = await widget.downCategory(category);
    setState(() {});
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(AppLocalizations.of(context)!.listCategoryTitle)),
      ),
      body: buildFutureWidget<List<Category>>(
        future: widget.loadCategories(),
        buildWidget: (categories) => ListView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          children: categories
              .map((category) => CategoryListItem(
                    category: category,
                    onUpCategory: _handleUpCategory,
                    onDownCategory: _handleDownCategory,
                    onEditCategory: _handleEditCategory,
                    onRemoveCategory: (c) async {
                      if (categories.length == 1) {
                        showAlert(context, AppLocalizations.of(context)!.alertAtLeastOne);
                        return false;
                      }
                      return await _handleRemoveCategory(c);
                    },
                  ))
              .toList(),
        ),
      ),
      floatingActionButton: buildFloatingAddButton(context, AppLocalizations.of(context)!.addCategoryTitle,
          (ctx) => AddCategoryDialog(addCategory: _handleAddCategory)),
    );
  }
}

class CategoryListItem extends StatelessWidget {
  CategoryListItem(
      {required this.category,
      required this.onEditCategory,
      required this.onRemoveCategory,
      required this.onUpCategory,
      required this.onDownCategory})
      : super(key: ObjectKey(category));

  final Category category;

  final UpdateCategory onEditCategory;
  final UpdateCategory onRemoveCategory;
  final UpdateCategory onUpCategory;
  final UpdateCategory onDownCategory;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _edit(context),
      leading: const CircleAvatar(
        child: Icon(Icons.category),
      ),
      trailing: FittedBox(
        fit: BoxFit.fill,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
              icon: const Icon(Icons.expand_less),
              tooltip: AppLocalizations.of(context)!.listCategoryUp,
              splashRadius: 20,
              onPressed: () => onUpCategory(category)),
          IconButton(
              icon: const Icon(Icons.expand_more),
              tooltip: AppLocalizations.of(context)!.listCategoryDown,
              splashRadius: 20,
              onPressed: () => onDownCategory(category)),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: AppLocalizations.of(context)!.editCategoryHint,
            splashRadius: 20,
            onPressed: () => _edit(context),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: AppLocalizations.of(context)!.removeCategoryHint,
            splashRadius: 20,
            onPressed: () => removalWithAlert(context, () => onRemoveCategory(category)),
          ),
        ]),
      ),
      title: Text(category.localizedName(AppLocalizations.of(context)!)),
    );
  }

  Future<void> _edit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditCategoryDialog(
                category: category,
                editCategory: onEditCategory,
              )),
    );
    if (result != null && result) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.editSuccess)));
    }
  }
}
