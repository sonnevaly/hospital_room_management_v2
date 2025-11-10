class Allocation {
  final String patientId;
  final String roomNumber;
  final int bedNumber;
  final DateTime timestamp;
  final String status; // 'assigned' or 'released'

  Allocation({
    required this.patientId,
    required this.roomNumber,
    required this.bedNumber,
    this.status = 'assigned',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'patientId': patientId,
        'roomNumber': roomNumber,
        'bedNumber': bedNumber,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
      };

  factory Allocation.fromJson(Map<String, dynamic> json) => Allocation(
        patientId: json['patientId'],
        roomNumber: json['roomNumber'],
        bedNumber: json['bedNumber'],
        status: json['status'] ?? 'assigned',
        timestamp: DateTime.parse(json['timestamp']),
      );
}
