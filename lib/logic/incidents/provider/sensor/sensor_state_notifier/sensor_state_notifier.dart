import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/provider/Sensor/sensor_state/sensor_state.dart';
import 'package:impaxt_alert/logic/incidents/provider/crash_incidents_provider/crash_incident_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorStateNotifier extends StateNotifier<SensorState> {
  SensorStateNotifier(this.ref) : super(const SensorState()) {
    /* Ascolta il provider di crash vero e proprio */

    ref.listen<AsyncValue<AccelerometerEvent>>(crashStreamProvider, (_, next) {
      next.whenData((evt) {
        /* 1️⃣ Salva l’evento e alza il flag */
        state = state.copyWith(incidentDetected: true, lastEvent: evt);

        /* 2️⃣ Dopo 1 s abbassa il flag (UI chiude dialog) */
        Timer(const Duration(seconds: 1), () {
          state = state.copyWith(incidentDetected: false);
        });
      });
    });
  }

  void resetIncident() {
    state = state.copyWith(incidentDetected: false, lastEvent: null);
  }

  final Ref ref;
}