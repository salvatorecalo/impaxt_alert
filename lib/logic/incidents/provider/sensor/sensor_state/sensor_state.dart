import 'package:sensors_plus/sensors_plus.dart';

class SensorState {
  final bool incidentDetected;
  final AccelerometerEvent? lastEvent;

  const SensorState({this.incidentDetected = false, this.lastEvent});

  SensorState copyWith({
    bool? incidentDetected,
    AccelerometerEvent? lastEvent,
  }) => SensorState(
    incidentDetected: incidentDetected ?? this.incidentDetected,
    lastEvent: lastEvent ?? this.lastEvent,
  );
}