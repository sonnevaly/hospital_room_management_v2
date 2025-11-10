import 'package:hospital_room_management_v2/src/models/patient.dart';
import 'package:hospital_room_management_v2/src/models/enums.dart';
import 'package:hospital_room_management_v2/src/data/repositories/patient_repository.dart';

class PatientService {
  final PatientRepository repo;
  PatientService(this.repo);

  Future<void> register({
    required String id,
    required String name,
    required int age,
    required String condition,
    required Priority priority,
  }) async {
    // Disallow duplicate registrations by id
    final existing = await repo.findById(id);
    if (existing != null) {
      throw StateError('Patient with id ' + id + ' already exists');
    }

    final p = Patient(
      id: id,
      name: name,
      age: age,
      condition: condition,
      priority: priority,
    );
    await repo.save(p);
  }

  Future<Patient?> find(String id) => repo.findById(id);
  Future<List<Patient>> all() => repo.findAll();
}
