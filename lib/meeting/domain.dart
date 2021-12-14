class Meeting {
  Meeting({required this.id, required this.at, required this.subject, this.content, required this.studentId});

  final String id;
  final DateTime at;
  final String subject;
  final String? content;
  final String studentId;
}
