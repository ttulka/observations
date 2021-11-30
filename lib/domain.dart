import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Classroom {
  Classroom({required this.id, required this.name, required this.description, required this.year});

  final String id;
  final String name;
  final String description;
  final int year;
}

class Student {
  Student({required this.id, required this.givenName, required this.familyName});

  final String id;
  final String givenName;
  final String familyName;
}

class Category {
  Category({required this.id, required this.name, required this.template});

  final String id;
  final String name;
  final String template;

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

class Observation {
  Observation({required this.id, required this.category, required this.updatedAt, required this.content});

  final String id;
  final Category category;
  final DateTime updatedAt;
  final String content;
}
