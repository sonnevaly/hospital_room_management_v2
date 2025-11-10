import 'dart:convert';
import 'dart:io';
import 'package:hospital_room_management_v2/src/models/room.dart';

class RoomRepository {
  final String filePath;
  RoomRepository(this.filePath);

  Future<List<Room>> _readAll() async {
    final file = File(filePath);
    if (!file.existsSync()) return [];
    final content = await file.readAsString();
    if (content.trim().isEmpty) return [];
    final data = jsonDecode(content) as List;
    return data.map((e) => Room.fromJson(e)).toList();
  }

  Future<void> _writeAll(List<Room> rooms) async {
    final file = File(filePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(
        rooms.map((r) => r.toJson()).toList(),
      ),
    );
  }

  Future<List<Room>> findAll() => _readAll();

  Future<Room> findByNumber(String number) async {
    final all = await _readAll();
    for (final r in all) {
      if (r.number == number) return r;
    }
    throw Exception('Room not found: $number');
  }

  Future<void> save(Room r) async {
    final all = await _readAll();
    all.removeWhere((x) => x.number == r.number);
    all.add(r);
    await _writeAll(all);
  }

  Future<void> update(Room r) async => save(r);

  Future<List<Room>> findAvailable() async {
    final all = await _readAll();
    return all.where((r) => r.beds.any((b) => b.patientId == null)).toList();
  }
}
