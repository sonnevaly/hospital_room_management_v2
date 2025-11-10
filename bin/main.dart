import 'package:hospital_room_management_v2/src/services/allocation_service.dart';
import 'package:hospital_room_management_v2/src/services/patient_service.dart';
import 'package:hospital_room_management_v2/src/services/room_service.dart';
import 'package:hospital_room_management_v2/src/data/repositories/patient_repository.dart';
import 'package:hospital_room_management_v2/src/data/repositories/room_repository.dart';
import 'package:hospital_room_management_v2/src/data/repositories/allocation_repository.dart';
import 'package:hospital_room_management_v2/ui/console/menu.dart';

Future<void> main() async {
  final patientRepo = PatientRepository('data/patients.json');
  final roomRepo = RoomRepository('data/rooms.json');
  final allocRepo = AllocationRepository('data/allocations.json');

  final patientService = PatientService(patientRepo);
  final roomService = RoomService(roomRepo);
  final allocationService = AllocationService(patientRepo, roomRepo, allocRepo);

  final menu = Menu(
    patientService: patientService,
    roomService: roomService,
    allocationService: allocationService,
  );

  await menu.start();
}
