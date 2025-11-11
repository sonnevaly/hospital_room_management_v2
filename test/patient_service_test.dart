import 'dart:io';
import 'package:test/test.dart';
import 'package:hospital_room_management_v2/src/services/patient_service.dart';
import 'package:hospital_room_management_v2/src/data/repositories/patient_repository.dart';
import 'package:hospital_room_management_v2/src/models/enums.dart';

void main() {
  late Directory tmp;
  late PatientService service;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('hrm2_test_');
    service = PatientService(PatientRepository('${tmp.path}/patients.json'));
  });

  tearDown(() {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  test('register saves a new patient', () async {
    await service.register(
      id: 'p1', name: 'nevaly', age: 30, condition: 'headache', priority: Priority.medium,
    );
    final found = await service.find('p1');
    expect(found, isNotNull);
    expect(found!.name, 'nevaly');
  });

  test('register throws on duplicate id', () async {
    await service.register(
      id: 'p1', name: 'heng', age: 30, condition: 'broken heart', priority: Priority.medium,
    );
    expect(
      () => service.register(
        id: 'p1', name: 'youyou', age: 31, condition: 'flu', priority: Priority.low,
      ),
      throwsA(isA<StateError>()),
    );
  });
}
