import 'enums.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final String condition;
  final Priority priority;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.condition,
    required this.priority,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'condition': condition,
        'priority': priority.name,
      };

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        id: json['id'],
        name: json['name'],
        age: json['age'],
        condition: json['condition'],
        priority: Priority.values.firstWhere((e) => e.name == json['priority']),
      );
}
