
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/incident_list_item./pages/incident_list_item_detail_page.dart';
import 'package:impaxt_alert/logic/incidents/model/incident/incident.dart';
import 'package:impaxt_alert/logic/incidents/provider/providers.dart';

class IncidentListItem extends ConsumerWidget {
  const IncidentListItem({required this.incident, super.key});

  final Incident incident;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsByIncidentProvider(incident.uuid));
    return contacts.when(
        data: (contacts) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    IncidentListItemDetailPage(
                      date: incident.createdAt.toLocal().toString().substring(
                          0, 11),
                      hour: incident.createdAt.toLocal().toString().substring(
                          12, 19),
                      force: incident.x.abs() + incident.y.abs() +
                          incident.z.abs(),
                      called_rescue: incident.called_rescue,
                      contacts: contacts,
                      response_time: incident.response_time,
                    )
                ),
              );
            },
            leading: const Icon(Icons.warning, color: Colors.red),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  incident.createdAt.toLocal().toString().substring(0, 19),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

              ],
            ),
            subtitle: Text(
              'Forza: ${(incident.x.abs() + incident.y.abs() + incident.z.abs())
                  .toStringAsFixed(1)} g',
            ),
          );
        },
        error: (error, stack) =>
            ListTile(
              leading: const Icon(Icons.error, color: Colors.red),
              title: Text('Errore nel caricamento contatti: $error'),
            ),
        loading: () => CircularProgressIndicator()
    );
  }
}