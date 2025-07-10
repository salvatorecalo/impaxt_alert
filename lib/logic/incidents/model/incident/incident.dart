class Incident {
  final String uuid;
  final DateTime createdAt;
  final double x;
  final double y;
  final double z;
  final int called_rescue;
  final bool synced;
  final int response_time;

  Incident({
    required this.uuid,
    required this.createdAt,
    required this.x,
    required this.y,
    required this.z,
    required this.synced,
    required this.called_rescue,
    required this.response_time,
  });

  factory Incident.fromMap(Map<String, dynamic> map) {
    return Incident(
      uuid: map['uuid'],
      createdAt: DateTime.parse(map['created_at']),
      x: map['x'],
      y: map['y'],
      z: map['z'],
      synced: map['synced'] == 1,
      called_rescue: map['called_rescue'],
      response_time: map['response_time']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'created_at': createdAt.toIso8601String(),
      'x': x,
      'y': y,
      'z': z,
      'synced': synced ? 1 : 0,
      'called_rescue': called_rescue,
      'response_time': response_time
    };
  }
}
