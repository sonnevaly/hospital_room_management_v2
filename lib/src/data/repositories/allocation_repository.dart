import 'dart:convert';
import 'dart:io';
import 'package:hospital_room_management_v2/src/models/allocation.dart';

class AllocationRepository {
  final String filePath;
  AllocationRepository(this.filePath);

  Future<List<Allocation>> _readAll() async {
    final file = File(filePath);
    if (!file.existsSync()) return [];
    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];
    final data = jsonDecode(content) as List;
    return data.map((e) => Allocation.fromJson(e)).toList();
  }

  Future<void> _writeAll(List<Allocation> list) async {
    final file = File(filePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(
        list.map((a) => a.toJson()).toList(),
      ),
    );
  }

  Future<void> save(Allocation a) async {
    final list = await _readAll();
    list.add(a);
    await _writeAll(list);
  }

  // Instead of deleting, we append a 'released' record for history
  Future<void> markReleased(String roomNo, int bedNo, String patientId) async {
    final list = await _readAll();
    list.add(Allocation(
      patientId: patientId,
      roomNumber: roomNo,
      bedNumber: bedNo,
      status: 'released',
    ));
    await _writeAll(list);
  }

  Future<List<Allocation>> findHistoryByPatient(String patientId) async {
    final list = await _readAll();
    return list.where((a) => a.patientId == patientId).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}
