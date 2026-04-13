import 'dart:convert';

class LabTestEntry {
  final String imagePath;
  final String testName;
  final DateTime testDate;
  final String? notes;
  final DateTime createdAt;

  LabTestEntry({
    required this.imagePath,
    required this.testName,
    required this.testDate,
    this.notes,
    required this.createdAt,
  });

  String toJson() {
    return jsonEncode({
      'imagePath': imagePath,
      'testName': testName,
      'testDate': testDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    });
  }

  factory LabTestEntry.fromJson(String source) {
    final map = jsonDecode(source);

    return LabTestEntry(
      imagePath: map['imagePath'],
      testName: map['testName'],
      testDate: DateTime.parse(map['testDate']),
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
