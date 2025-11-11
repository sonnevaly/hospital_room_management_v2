import 'package:hospital_room_management_v2/src/models/enums.dart';
import 'package:hospital_room_management_v2/src/models/allocation.dart';
import 'package:hospital_room_management_v2/src/data/repositories/patient_repository.dart';
import 'package:hospital_room_management_v2/src/data/repositories/room_repository.dart';
import 'package:hospital_room_management_v2/src/data/repositories/allocation_repository.dart';

class AllocationError implements Exception {
  final String code;
  final String message;
  AllocationError(this.code, this.message);
  @override
  String toString() => '[$code] $message';
}

class AllocationService {
  final PatientRepository patientRepo;
  final RoomRepository roomRepo;
  final AllocationRepository allocRepo;

  AllocationService(this.patientRepo, this.roomRepo, this.allocRepo);

  Future<void> assignBed(String patientId, {String? preferredRoomNo}) async {
    final patient = await patientRepo.findById(patientId);
    if (patient == null) {
      throw AllocationError('patient_not_found', 'Patient not found');
    }

    // Prevent assigning a second bed to the same patient
    final allRooms = await roomRepo.findAll();
    final alreadyAssigned =
        allRooms.any((r) => r.beds.any((b) => b.patientId == patientId));
    if (alreadyAssigned) {
      throw AllocationError('already_assigned', 'Patient already assigned to a bed');
    }

    var rooms = await roomRepo.findAvailable();

    if (patient.priority == Priority.high) {
      final icu = rooms.where((r) => r.type.toLowerCase() == 'icu').toList();
      if (icu.isNotEmpty) rooms = icu;

      if (rooms.isEmpty) {
        throw AllocationError('capacity_full', 'No available beds.');
      }

      rooms.sort((a, b) {
        final cmp = b.availableBeds().compareTo(a.availableBeds());
        if (cmp != 0) return cmp;
        return a.number.compareTo(b.number);
      });

      final chosen = rooms.first;
      final bed = chosen.beds.firstWhere((b) => b.patientId == null);
      bed.assignPatient(patientId);

      await roomRepo.update(chosen);
      await allocRepo.save(Allocation(
        patientId: patientId,
        roomNumber: chosen.number,
        bedNumber: bed.number,
        status: 'assigned',
      ));
      return;
    }

    // Regular priority: require explicit room selection
    if (rooms.isEmpty) {
      throw AllocationError('capacity_full', 'No available beds.');
    }
    if (preferredRoomNo == null || preferredRoomNo.trim().isEmpty) {
      throw AllocationError('choose_room', 'Please choose a room for regular priority');
    }
    final chosen = rooms.firstWhere(
      (r) => r.number == preferredRoomNo,
      orElse: () => throw AllocationError('room_unavailable', 'Selected room is not available'),
    );
    final bed = chosen.beds.firstWhere((b) => b.patientId == null);
    bed.assignPatient(patientId);

    await roomRepo.update(chosen);
    await allocRepo.save(Allocation(
      patientId: patientId,
      roomNumber: chosen.number,
      bedNumber: bed.number,
      status: 'assigned',
    ));
  }

  Future<void> releaseBed(String roomNo, int bedNo) async {
    final room = await roomRepo.findByNumber(roomNo);
    final bed = room.beds.firstWhere(
      (b) => b.number == bedNo,
      orElse: () => throw AllocationError('bed_not_found', 'Bed not found'),
    );
    if (bed.patientId == null) {
      throw AllocationError('not_occupied', 'Bed already free.');
    }
    final pid = bed.patientId!;
    bed.release();
    await roomRepo.update(room);
    await allocRepo.markReleased(roomNo, bedNo, pid);
  }

  // New: print patient history
  Future<List<Allocation>> historyFor(String patientId) async {
    final patient = await patientRepo.findById(patientId);
    if (patient == null) {
      throw AllocationError('patient_not_found', 'Patient not found');
    }
    return await allocRepo.findHistoryByPatient(patientId);
  }
}
