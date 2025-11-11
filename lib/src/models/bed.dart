import 'enums.dart';

class Bed {
  final int number;
  BedStatus status;
  String? patientId;

  Bed({required this.number, this.status = BedStatus.available, this.patientId});

  void assignPatient(String id) {
    if (status == BedStatus.occupied) {
      throw StateError('Bed already occupied');
    }
    status = BedStatus.occupied;
    patientId = id;
  }

  void release() {
    status = BedStatus.available;
    patientId = null;
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'status': status.name,
        'patientId': patientId,
      };

  factory Bed.fromJson(Map<String, dynamic> json) => Bed(
        number: json['number'],
        status: BedStatus.values.firstWhere((e) => e.name == json['status']),
        patientId: json['patientId'],
      );
}
