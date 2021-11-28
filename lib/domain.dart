class Classroom {
  Classroom({required this.id, required this.description, required this.year});

  final String id;
  final String description;
  final int year;
}

class Student {
  Student(
      {required this.id,
      required this.givenName,
      required this.familyName,
      this.mittleName});

  final String id;
  final String givenName;
  final String familyName;
  final String? mittleName;
}

class Category {
  Category({required this.name, required this.template});

  final String name;
  final String template;
}
