import 'dart:convert';
import 'dart:io';
import 'package:hospital_room_management_v2/src/models/patient.dart';

class PatientRepository {
  final String filePath;
  PatientRepository(this.filePath);

  Future<List<Patient>> _readAll() async {
    final file = File(filePath);
    if (!file.existsSync()) return [];
    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];
    final data = jsonDecode(content) as List;
    return data.map((e) => Patient.fromJson(e)).toList();
  }

  Future<void> _writeAll(List<Patient> patients) async {
    final file = File(filePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(
        patients.map((p) => p.toJson()).toList(),
      ),
    );
  }

  Future<void> save(Patient p) async {
    final list = await _readAll();
    list.removeWhere((x) => x.id == p.id);
    list.add(p);
    await _writeAll(list);
  }

  Future<Patient?> findById(String id) async {
    final list = await _readAll();
    try {
      return list.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Patient>> findAll() => _readAll();
}
