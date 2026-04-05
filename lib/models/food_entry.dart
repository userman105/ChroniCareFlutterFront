import 'dart:convert';

class FoodEntry {
  final String name;
  final String? imagePath;
  final String? mealType;
  final int? calories;
  final double? carbs;
  final double? protein;
  final double? fat;
  final String? notes;
  final DateTime dateTime;

  FoodEntry({
    required this.name,
    this.imagePath,
    this.mealType,
    this.calories,
    this.carbs,
    this.protein,
    this.fat,
    this.notes,
    required this.dateTime,
  });

  // Whether the entry has any macro data at all
  bool get hasMacros =>
      calories != null || carbs != null ||
          protein != null || fat != null;

  bool get hasImage =>
      imagePath != null && imagePath!.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imagePath': imagePath,
      'mealType': mealType,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'notes': notes,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory FoodEntry.fromMap(Map<String, dynamic> map) {
    return FoodEntry(
      name: map['name'],
      imagePath: map['imagePath'],
      mealType: map['mealType'],
      calories: map['calories'],
      carbs: map['carbs'] != null
          ? (map['carbs'] as num).toDouble()
          : null,
      protein: map['protein'] != null
          ? (map['protein'] as num).toDouble()
          : null,
      fat: map['fat'] != null
          ? (map['fat'] as num).toDouble()
          : null,
      notes: map['notes'],
      dateTime: DateTime.parse(map['dateTime']),
    );
  }

  String toJson() => json.encode(toMap());

  factory FoodEntry.fromJson(String source) =>
      FoodEntry.fromMap(json.decode(source));
}