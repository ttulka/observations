import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Category {
  Category({required this.id, required this.name, required this.template, required this.priority});

  final String id;
  final String name;
  final String template;
  final int priority;

  String localizedName(AppLocalizations localizations) {
    switch (name) {
      case '#social':
        return localizations.categoryDefaultsSocial;
      case '#work':
        return localizations.categoryDefaultsWork;
      default:
        return name;
    }
  }
}
