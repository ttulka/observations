import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'service.dart';
import 'domain.dart';
import 'category_add.dart';
import 'category_edit.dart';

typedef ListCategories = List<Category> Function();
typedef RemoveCategory = Function(Category category);
typedef EditCategory = Function(Category oldCategory, Category newCategory);
typedef UpCategory = Function(Category category);
typedef DownCategory = Function(Category category);

class CategoryList extends StatefulWidget {
  CategoryList({Key? key}) : super(key: key);

  final CategoryService _service = CategoryService();

  final List<Category> categories = [];

  void onAddCategory(Category category) {
    _service.add(category);
  }

  void onEditCategory(Category oldCategory, Category newCategory) {
    _service.edit(oldCategory, newCategory);
  }

  void onRemoveCategory(Category category) {
    _service.remove(category);
  }

  void onUpCategory(Category category) {
    _service.up(category);
  }

  void onDownCategory(Category category) {
    _service.down(category);
  }

  void loadCategories() {
    categories.clear();
    categories.addAll(_service.listAll());
  }

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  void _handleAddCategory(Category category) {
    setState(() {
      widget.onAddCategory(category);
      widget.loadCategories();
    });
  }

  void _handleEditCategory(Category newCategory, Category oldCategory) {
    setState(() {
      widget.onEditCategory(newCategory, oldCategory);
      widget.loadCategories();
    });
  }

  void _handleRemoveCategory(Category category) {
    setState(() {
      widget.onRemoveCategory(category);
      widget.loadCategories();
    });
  }

  void _handleUpCategory(Category category) {
    setState(() {
      widget.onUpCategory(category);
      widget.loadCategories();
    });
  }

  void _handleDownCategory(Category category) {
    setState(() {
      widget.onDownCategory(category);
      widget.loadCategories();
    });
  }

  @override
  void initState() {
    super.initState();
    widget.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.listCategoryTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: widget.categories.map((Category category) {
          return CategoryListItem(
            category: category,
            onEditCategory: _handleEditCategory,
            onRemoveCategory: _handleRemoveCategory,
            onUpCategory: _handleUpCategory,
            onDownCategory: _handleDownCategory,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: AppLocalizations.of(context)!.addCategoryTitle,
          child: const Icon(Icons.add),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddCategoryDialog(
                        onAddCategory: _handleAddCategory,
                      )),
            );
            if (result != null && result) {
              ScaffoldMessenger.of(context)
                ..removeCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.addSuccess)));
            }
          }),
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

  final EditCategory onEditCategory;
  final RemoveCategory onRemoveCategory;
  final UpCategory onUpCategory;
  final DownCategory onDownCategory;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.category),
      ),
      trailing: FittedBox(
        fit: BoxFit.fill,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
              icon: const Icon(Icons.arrow_upward),
              tooltip: AppLocalizations.of(context)!.listCategoryUp,
              splashRadius: 20,
              onPressed: () => onUpCategory(category)),
          IconButton(
              icon: const Icon(Icons.arrow_downward),
              tooltip: AppLocalizations.of(context)!.listCategoryDown,
              splashRadius: 20,
              onPressed: () => onDownCategory(category)),
          IconButton(
              icon: const Icon(Icons.edit),
              tooltip: AppLocalizations.of(context)!.editCategoryHint,
              splashRadius: 20,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditCategoryDialog(
                            category: category,
                            onEditCategory: onEditCategory,
                          )),
                );
                if (result != null && result) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.editSuccess)));
                }
              }),
          IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: AppLocalizations.of(context)!.removeCategoryHint,
              splashRadius: 20,
              onPressed: () {
                onRemoveCategory(category);
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.removeSuccess)));
              }),
        ]),
      ),
      title: Text(category.name),
    );
  }
}
