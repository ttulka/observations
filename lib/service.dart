import 'package:observations/domain.dart';

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

  void remove(Classroom classroom) {
    classrooms.remove(classroom);
  }

  void edit(Classroom oldClassroom, Classroom newClassroom) {
    final i = classrooms.indexOf(oldClassroom);
    if (i != -1) {
      classrooms.remove(oldClassroom);
      classrooms.insert(i, newClassroom);
    }
  }
}

class StudentService {
  List<Student> listByClassroom(Classroom classroom) {
    return [
      Student(id: 'bs', givenName: 'Bart', familyName: 'Simpson'),
      Student(id: 'mvh', givenName: 'Milhouse', familyName: 'Van Houten'),
      Student(id: 'mp', givenName: 'Martin', familyName: 'Prince'),
      Student(
          id: 'nmm',
          givenName: 'Nelson',
          familyName: 'Muntz',
          mittleName: 'Mandela'),
    ];
  }
}
