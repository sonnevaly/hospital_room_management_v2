import 'dart:io';
import 'package:test/test.dart';
import 'package:hospital_room_management_v2/src/services/allocation_service.dart';
import 'package:hospital_room_management_v2/src/services/patient_service.dart';
import 'package:hospital_room_management_v2/src/services/room_service.dart';
import 'package:hospital_room_management_v2/src/data/repositories/patient_repository.dart';
import 'package:hospital_room_management_v2/src/data/repositories/room_repository.dart';
import 'package:hospital_room_management_v2/src/data/repositories/allocation_repository.dart';
import 'package:hospital_room_management_v2/src/models/room.dart';
import 'package:hospital_room_management_v2/src/models/bed.dart';
import 'package:hospital_room_management_v2/src/models/enums.dart';

void main() {
  late Directory tmp;
  late PatientService patients;
  late RoomService rooms;
  late AllocationService alloc;

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('hrm2_test_');
    final p = PatientRepository('${tmp.path}/patients.json');
    final r = RoomRepository('${tmp.path}/rooms.json');
    final a = AllocationRepository('${tmp.path}/alloc.json');
    patients = PatientService(p);
    rooms = RoomService(r);
    alloc = AllocationService(p, r, a);

    await rooms.save(Room(number: 'A101', type: 'General', floor: 1, capacity: 1, beds: [Bed(number: 1)]));
    await rooms.save(Room(number: 'ICU-1', type: 'ICU', floor: 1, capacity: 1, beds: [Bed(number: 1)]));
  });

  tearDown(() {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  test('patient_not_found when allocating unknown patient', () async {
    expect(
      () => alloc.assignBed('unknown'),
      throwsA(predicate((e) => e is AllocationError && e.code == 'patient_not_found')),
    );
  });

  test('regular priority requires room choice', () async {
    await patients.register(id: 'p1', name: 'nevaly', age: 30, condition: 'c', priority: Priority.medium);
    expect(
      () => alloc.assignBed('p1'),
      throwsA(predicate((e) => e is AllocationError && e.code == 'choose_room')),
    );
  });

  test('high priority prefers ICU when available', () async {
    await patients.register(id: 'p2', name: 'heng', age: 40, condition: 'c', priority: Priority.high);
    await alloc.assignBed('p2');
    final icu = await rooms.findByNumber('ICU-1');
    expect(icu.beds.first.patientId, 'p2');
  });

  test('regular priority allocates in chosen room', () async {
    await patients.register(id: 'p3', name: 'heeyo', age: 28, condition: 'c', priority: Priority.low);
    await alloc.assignBed('p3', preferredRoomNo: 'A101');
    final general = await rooms.findByNumber('A101');
    expect(general.beds.first.patientId, 'p3');
  });

  test('capacity_full when no free beds', () async {
    // Fill all beds first
    await patients.register(id: 'h1', name: 'yes', age: 50, condition: 'c', priority: Priority.high);
    await alloc.assignBed('h1'); // occupies ICU-1
    await patients.register(id: 'l1', name: 'no', age: 25, condition: 'c', priority: Priority.low);
    await alloc.assignBed('l1', preferredRoomNo: 'A101'); // occupies A101

    await patients.register(id: 'new', name: 'hoho', age: 22, condition: 'c', priority: Priority.high);
    expect(
      () => alloc.assignBed('new'),
      throwsA(predicate((e) => e is AllocationError && e.code == 'capacity_full')),
    );
  });

  test('release bed updates room and history', () async {
    await patients.register(id: 'p4', name: 'rrr', age: 33, condition: 'c', priority: Priority.low);
    await alloc.assignBed('p4', preferredRoomNo: 'A101');
    var room = await rooms.findByNumber('A101');
    expect(room.beds.first.patientId, 'p4');

    await alloc.releaseBed('A101', 1);
    room = await rooms.findByNumber('A101');
    expect(room.beds.first.patientId, isNull);
  });
}
