import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/provider/Sensor/sensor_state/sensor_state.dart';
import 'package:impaxt_alert/logic/incidents/provider/sensor/sensor_state_notifier/sensor_state_notifier.dart';

final sensorDataProvider =
StateNotifierProvider<SensorStateNotifier, SensorState>(
      (ref) => SensorStateNotifier(ref),
);