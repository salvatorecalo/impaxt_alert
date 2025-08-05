import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/provider/incident_dao/model/incident_dao.dart';

final daoProvider = Provider<IncidentDao>(
        (_) => IncidentDao.instance
);
