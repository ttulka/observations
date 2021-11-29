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
    return {for (var y in years) y: classrooms.where((c) => c.year == y).toList()};
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
    Student(id: const Uuid().v4(), givenName: 'Milhouse', familyName: 'Van Houten'),
    Student(id: const Uuid().v4(), givenName: 'Martin', familyName: 'Prince'),
    Student(id: const Uuid().v4(), givenName: 'Nelson', familyName: 'Muntz', mittleName: 'Mandela'),
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

final category1 = Category(
    name: 'Social behavior',
    template:
        r'[{"insert":"Title 1"},{"insert":"\n","attributes":{"header":1}},{"insert":"\n\n\nTitle 2"},{"insert":"\n","attributes":{"header":1}},{"insert":"\n\n\nTitle 3"},{"insert":"\n","attributes":{"header":1}}]');
final category2 = Category(
    name: 'Work behavior',
    template:
        r'[{"insert":"Title 1"},{"insert":"\n","attributes":{"header":1}},{"insert":"\n\n\nTitle 2"},{"insert":"\n","attributes":{"header":1}},{"insert":"\n\n\nTitle 3"},{"insert":"\n","attributes":{"header":1}}]');

class CategoryService {
  final categories = [category1, category2];

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

  void up(Category category) {
    //TODO
  }

  void down(Category category) {
    //TODO
  }
}

class ObservationService {
  final observations = [
    Observation(
        id: const Uuid().v4(),
        category: category1,
        date: DateTime(2021, 1, 1),
        updatedAt: DateTime.now(),
        content:
            '[{"insert":"Title 1"},{"insert":"\n","attributes":{"header":1}},{"insert":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n"}]'),
    Observation(
        id: const Uuid().v4(),
        category: category2,
        date: DateTime(2021, 1, 1),
        updatedAt: DateTime.now(),
        content:
            '[{"insert":"Title 1"},{"insert":"\n","attributes":{"header":1}},{"insert":"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n"}]'),
  ];

  Map<DateTime, List<Observation>> listByStudent(Student student) {
    final dates = observations.map((c) => c.date).toSet();
    return {for (var d in dates) d: observations.where((o) => datesEqual(o.date, d)).toList()};
  }

  void add(Observation observation) {
    observations.add(observation);
  }

  void edit(Observation oldObservation, Observation newObservation) {
    final i = observations.indexOf(oldObservation);
    if (i != -1) {
      observations.remove(oldObservation);
      observations.insert(i, newObservation);
    }
  }

  void remove(Observation observation) {
    observations.remove(observation);
  }

  void removeByDate(DateTime date) {
    observations.removeWhere((o) => datesEqual(o.date, date));
  }

  bool datesEqual(DateTime d1, DateTime d2) => d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}
