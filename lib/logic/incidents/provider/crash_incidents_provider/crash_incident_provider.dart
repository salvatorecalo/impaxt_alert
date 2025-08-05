import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

const double kCrashThreshold = 30.0;

/// StreamProvider che emette un [AccelerometerEvent] solo
/// quando la forza supera la soglia definita.
final crashStreamProvider = StreamProvider<AccelerometerEvent>((ref) {
  return accelerometerEventStream().where(
        (e) => (e.x.abs() + e.y.abs() + e.z.abs()) > kCrashThreshold,
  );
});