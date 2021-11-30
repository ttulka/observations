import 'package:uuid/uuid.dart';
import 'domain.dart';

final CLASSROOMS = [
  Classroom(id: const Uuid().v4(), name: 'A1', description: 'First class A', year: 2021),
  Classroom(id: const Uuid().v4(), name: 'A2', description: 'Second class A', year: 2020),
  Classroom(id: const Uuid().v4(), name: 'B2', description: 'Second class B', year: 2020),
];

class ClassroomService {
  Map<int, List<Classroom>> listAll() {
    final years = CLASSROOMS.map((c) => c.year).toSet();
    return {for (var y in years) y: CLASSROOMS.where((c) => c.year == y).toList()};
  }

  void add(Classroom classroom) {
    CLASSROOMS.add(classroom);
  }

  void edit(Classroom classroom) {
    final i = CLASSROOMS.indexWhere((c) => c.id == classroom.id);
    if (i != -1) {
      CLASSROOMS.removeAt(i);
      CLASSROOMS.insert(i, classroom);
    }
  }

  void remove(Classroom classroom) {
    CLASSROOMS.remove(classroom);
  }
}

final STUDENTS = [
  Student(id: const Uuid().v4(), givenName: 'Bart', familyName: 'Simpson'),
  Student(id: const Uuid().v4(), givenName: 'Milhouse', familyName: 'Van Houten'),
  Student(id: const Uuid().v4(), givenName: 'Martin', familyName: 'Prince'),
  Student(id: const Uuid().v4(), givenName: 'Nelson', familyName: 'Muntz', mittleName: 'Mandela'),
];

class StudentService {
  List<Student> listByClassroom(Classroom classroom) {
    STUDENTS.sort((a, b) => a.familyName.compareTo(b.familyName));
    return STUDENTS;
  }

  void add(Student student) {
    STUDENTS.add(student);
  }

  void edit(Student oldStudent, Student newStudent) {
    final i = STUDENTS.indexOf(oldStudent);
    if (i != -1) {
      STUDENTS.remove(oldStudent);
      STUDENTS.insert(i, newStudent);
    }
  }

  void remove(Student student) {
    STUDENTS.remove(student);
  }
}

final CATEGORY1 = Category(
    id: const Uuid().v4(),
    name: 'Social behavior',
    template:
        r'[{"insert":"Title 1"},{"insert":"\n","attributes":{"header":1}},{"insert":"\n\n\nTitle 2"},{"insert":"\n","attributes":{"header":1}},{"insert":"\n\n\nTitle 3"},{"insert":"\n","attributes":{"header":1}}]');
final CATEGORY2 = Category(
    id: const Uuid().v4(),
    name: 'Work behavior',
    template:
        r'[{"insert":"Title A"},{"insert":"\n","attributes":{"header":1}},{"insert":"\n\n\nTitle B"},{"insert":"\n","attributes":{"header":1}},{"insert":"\n\n\nTitle C"},{"insert":"\n","attributes":{"header":1}}]');

final CATEGORIES = [CATEGORY1, CATEGORY2];

class CategoryService {
  List<Category> listAll() {
    return CATEGORIES;
  }

  void add(Category category) {
    CATEGORIES.add(category);
  }

  void edit(Category oldCategory, Category newCategory) {
    final i = CATEGORIES.indexOf(oldCategory);
    if (i != -1) {
      CATEGORIES.remove(oldCategory);
      CATEGORIES.insert(i, newCategory);
    }
  }

  void remove(Category category) {
    CATEGORIES.remove(category);
  }

  void up(Category category) {
    //TODO
  }

  void down(Category category) {
    //TODO
  }
}

final OBSERVATIONS = [
  Observation(
      id: const Uuid().v4(),
      category: CATEGORY1,
      updatedAt: DateTime.now(),
      content:
          r'[{"insert":"Title 1"},{"insert":"\n","attributes":{"header":1}},{"insert":"\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n"}]'),
  Observation(
      id: const Uuid().v4(),
      category: CATEGORY2,
      updatedAt: DateTime.now(),
      content:
          r'[{"insert":"Title 1"},{"insert":"\n","attributes":{"header":1}},{"insert":"\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n"}]'),
];

class ObservationService {
  List<Observation> listByStudent(Student student) {
    return OBSERVATIONS;
  }

  void save(Observation observation) {
    final i = OBSERVATIONS.indexWhere((o) => o.id == observation.id);
    if (i != -1) {
      OBSERVATIONS.removeAt(i);
      OBSERVATIONS.insert(i, observation);
    } else {
      OBSERVATIONS.add(observation);
    }
  }

  void remove(Observation observation) {
    OBSERVATIONS.remove(observation);
  }
}
