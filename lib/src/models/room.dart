import 'bed.dart';

class Room {
  final String number;
  final String type;
  final int floor;
  final int capacity;
  final List<Bed> beds;

  Room({
    required this.number,
    required this.type,
    required this.floor,
    required this.capacity,
    required this.beds,
  });

  int availableBeds() => beds.where((b) => b.patientId == null).length;
  bool isFull() => availableBeds() == 0;

  Map<String, dynamic> toJson() => {
        'number': number,
        'type': type,
        'floor': floor,
        'capacity': capacity,
        'beds': beds.map((b) => b.toJson()).toList(),
      };

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        number: json['number'],
        type: json['type'],
        floor: json['floor'],
        capacity: json['capacity'],
        beds: (json['beds'] as List).map((e) => Bed.fromJson(e)).toList(),
      );
}
