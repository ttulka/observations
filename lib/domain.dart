class Classroom {
  Classroom({required this.id, required this.name, required this.description, required this.year});

  final String id;
  final String name;
  final String description;
  final int year;
}

class Student {
  Student({required this.id, required this.givenName, required this.familyName, this.mittleName});

  final String id;
  final String givenName;
  final String familyName;
  final String? mittleName;
}

class Category {
  Category({required this.id, required this.name, required this.template});

  final String id;
  final String name;
  final String template;
}

class Observation {
  Observation({required this.id, required this.category, required this.updatedAt, required this.content});

  final String id;
  final Category category;
  final DateTime updatedAt;
  final String content;
}
