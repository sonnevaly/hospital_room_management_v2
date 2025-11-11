import 'package:hospital_room_management_v2/src/data/repositories/room_repository.dart';
import 'package:hospital_room_management_v2/src/models/room.dart';

class RoomService {
  final RoomRepository repo;
  RoomService(this.repo);

  Future<List<Room>> all() => repo.findAll();
  Future<List<Room>> available() => repo.findAvailable();
  Future<Room> findByNumber(String n) => repo.findByNumber(n);
  Future<void> save(Room r) => repo.save(r);
}
