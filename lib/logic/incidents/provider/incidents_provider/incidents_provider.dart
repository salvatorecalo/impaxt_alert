import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/model/incident/incident.dart';
import 'package:impaxt_alert/logic/incidents/provider/incident_dao/incident_dao_provider/incident_dao_provider.dart';

final incidentsProvider = FutureProvider<List<Incident>>((ref) async {
  final dao = ref.watch(daoProvider);
  final rows = await dao.getIncidents();
  return rows.map(Incident.fromMap).toList();
});