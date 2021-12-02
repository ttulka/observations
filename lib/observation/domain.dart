import '../category/domain.dart';

class Observation {
  Observation(
      {required this.id,
      required this.category,
      required this.updatedAt,
      required this.studentId,
      required this.content});

  final String id;
  final Category category;
  final DateTime updatedAt;
  final String studentId;
  final String content;
}
