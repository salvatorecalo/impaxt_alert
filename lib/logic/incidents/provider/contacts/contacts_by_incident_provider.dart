import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/provider/incident_dao/incident_dao_provider/incident_dao_provider.dart';

final contactsByIncidentProvider =
FutureProvider.family<List<Map<String, Object?>>, String>((
    ref,
    uuid,
    ) async {
  final dao = ref.watch(daoProvider);
  return dao.getContactsByIncident(uuid);
});
