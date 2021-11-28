import 'package:uuid/uuid.dart';
import 'domain.dart';

class ClassroomService {
  final classrooms = [
    Classroom(id: 'A1', description: 'First class A', year: 2021),
    Classroom(id: 'A2', description: 'Second class A', year: 2020),
    Classroom(id: 'B2', description: 'Second class B', year: 2020),
  ];

  Map<int, List<Classroom>> listAll() {
    final years = classrooms.map((c) => c.year).toSet();
    return {
      for (var y in years) y: classrooms.where((c) => c.year == y).toList()
    };
  }

  void add(Classroom classroom) {
    classrooms.add(classroom);
  }

  void edit(Classroom oldClassroom, Classroom newClassroom) {
    final i = classrooms.indexOf(oldClassroom);
    if (i != -1) {
      classrooms.remove(oldClassroom);
      classrooms.insert(i, newClassroom);
    }
  }

  void remove(Classroom classroom) {
    classrooms.remove(classroom);
  }
}

class StudentService {
  final students = [
    Student(id: const Uuid().v4(), givenName: 'Bart', familyName: 'Simpson'),
    Student(
        id: const Uuid().v4(), givenName: 'Milhouse', familyName: 'Van Houten'),
    Student(id: const Uuid().v4(), givenName: 'Martin', familyName: 'Prince'),
    Student(
        id: const Uuid().v4(),
        givenName: 'Nelson',
        familyName: 'Muntz',
        mittleName: 'Mandela'),
  ];
  List<Student> listByClassroom(Classroom classroom) {
    students.sort((a, b) => a.familyName.compareTo(b.familyName));
    return students;
  }

  void add(Student student) {
    students.add(student);
  }

  void edit(Student oldStudent, Student newStudent) {
    final i = students.indexOf(oldStudent);
    if (i != -1) {
      students.remove(oldStudent);
      students.insert(i, newStudent);
    }
  }

  void remove(Student student) {
    students.remove(student);
  }
}

class CategoryService {
  final categories = [
    Category(
        name: 'Social behavior',
        template: '## Subtitle 1\n\n## Subtitle 2\n\n## Subtitle 3'),
    Category(
        name: 'Work behavior',
        template: '## Subtitle 1\n\n## Subtitle 2\n\n## Subtitle 3')
  ];

  List<Category> listAll() {
    return categories;
  }

  void add(Category category) {
    categories.add(category);
  }

  void edit(Category oldCategory, Category newCategory) {
    final i = categories.indexOf(oldCategory);
    if (i != -1) {
      categories.remove(oldCategory);
      categories.insert(i, newCategory);
    }
  }

  void remove(Category category) {
    categories.remove(category);
  }
}
