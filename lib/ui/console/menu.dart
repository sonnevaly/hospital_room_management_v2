import 'dart:io';
import 'package:hospital_room_management_v2/src/models/enums.dart';
import 'package:hospital_room_management_v2/src/models/bed.dart';
import 'package:hospital_room_management_v2/src/models/room.dart';
import 'package:hospital_room_management_v2/src/services/patient_service.dart';
import 'package:hospital_room_management_v2/src/services/room_service.dart';
import 'package:hospital_room_management_v2/src/services/allocation_service.dart';
 

class Menu {
  final PatientService patientService;
  final RoomService roomService;
  final AllocationService allocationService;

  Menu({
    required this.patientService,
    required this.roomService,
    required this.allocationService,
  });

  Future<void> start() async {
    await _seedRoomsIfEmpty();

    while (true) {
      print('\n=== HOSPITAL ROOM MANAGEMENT SYSTEM ===');
      print('1. Register Patient');
      print('2. Allocate Bed');
      print('3. Release Bed');
      print('4. View All Rooms');
      print('5. View Available Beds');
      print('6. View Patient History');
      print('7. Exit');
      stdout.write('Enter choice: ');
      final choice = stdin.readLineSync();

      switch (choice) {
        case '1': await _registerPatient(); break;
        case '2': await _allocateBed(); break;
        case '3': await _releaseBed(); break;
        case '4': await _viewAllRooms(); break;
        case '5': await _viewAvailableBeds(); break;
        case '6': await _viewHistory(); break;
        case '7': print('Exiting...'); return;
        default: print('Invalid choice.');
      }
    }
  }

  Future<void> _seedRoomsIfEmpty() async {
    final rooms = await roomService.all();
    if (rooms.isNotEmpty) return;

    final defaults = [
      Room(number: 'A101', type: 'General', floor: 1, capacity: 2,
        beds: [Bed(number: 1), Bed(number: 2)]),
      Room(number: 'A102', type: 'General', floor: 1, capacity: 2,
        beds: [Bed(number: 1), Bed(number: 2)]),
      Room(number: 'ICU-1', type: 'ICU', floor: 1, capacity: 1,
        beds: [Bed(number: 1)]),
    ];
    for (final r in defaults) { await roomService.save(r); }
  }

  Future<void> _registerPatient() async {
    stdout.write('Enter Patient ID: ');
    final id = stdin.readLineSync()!.trim();
    stdout.write('Enter Name: ');
    final name = stdin.readLineSync()!.trim();
    stdout.write('Enter Age: ');
    final age = int.parse(stdin.readLineSync()!.trim());
    stdout.write('Enter Condition: ');
    final condition = stdin.readLineSync()!.trim();
    stdout.write('Priority (low/medium/high): ');
    final pr = stdin.readLineSync()!.trim().toLowerCase();
    final priority = Priority.values.firstWhere((p) => p.name == pr, orElse: () => Priority.medium);

    await patientService.register(id: id, name: name, age: age, condition: condition, priority: priority);
    print('✅ Patient registered successfully.');
  }

  Future<void> _allocateBed() async {
    stdout.write('Enter Patient ID: ');
    final id = stdin.readLineSync()!.trim();
    try {
      final patient = await patientService.find(id);
      if (patient == null) {
        print('❌ Patient not found');
        return;
      }

      if (patient.priority == Priority.high) {
        await allocationService.assignBed(id);
        print('✅ Bed allocated (ICU preference)');
        return;
      }

      final rooms = await roomService.available();
      if (rooms.isEmpty) {
        print('❌ No available beds.');
        return;
      }

      print('\nAvailable rooms:');
      for (final r in rooms) {
        final free = r.beds.where((b) => b.patientId == null).length;
        print('- ${r.number} [${r.type}] — $free free');
      }
      stdout.write('Enter Room No to allocate: ');
      final roomNo = stdin.readLineSync()!.trim();

      await allocationService.assignBed(id, preferredRoomNo: roomNo);
      print('✅ Bed allocated in room $roomNo');
    } catch (e) { print('❌ $e'); }
  }

  Future<void> _releaseBed() async {
    stdout.write('Enter Room No: ');
    final room = stdin.readLineSync()!.trim();
    stdout.write('Enter Bed No: ');
    final bed = int.parse(stdin.readLineSync()!.trim());
    try {
      await allocationService.releaseBed(room, bed);
      print('✅ Bed released successfully.');
    } catch (e) { print('❌ $e'); }
  }

  Future<void> _viewAllRooms() async {
    final rooms = await roomService.all();
    print('\n=== ROOMS ===');
    for (final r in rooms) {
      final occ = r.beds.where((b) => b.patientId != null).length;
      print('- Room ${r.number} [${r.type}] - $occ/${r.capacity} occupied');
      for (final b in r.beds) {
        print('   Bed ${b.number}: ${b.patientId ?? "Available"}');
      }
    }
  }

  Future<void> _viewAvailableBeds() async {
    final rooms = await roomService.available();
    print('\n=== AVAILABLE BEDS ===');
    if (rooms.isEmpty) { print('No available beds.'); return; }
    for (final r in rooms) {
      final free = r.beds.where((b) => b.patientId == null).length;
      print('- Room ${r.number} [${r.type}] - $free free');
    }
  }

 

  Future<void> _viewHistory() async {
    stdout.write('Enter Patient ID: ');
    final id = stdin.readLineSync()!.trim();
    try {
      final history = await allocationService.historyFor(id);
      if (history.isEmpty) { print('No history found.'); return; }
      print('\n=== PATIENT HISTORY ===');
      for (final a in history) {
        print('- ${a.timestamp.toLocal()} : Room ${a.roomNumber}, Bed ${a.bedNumber} [${a.status}]');
      }
    } catch (e) { print('❌ $e'); }
  }
}
