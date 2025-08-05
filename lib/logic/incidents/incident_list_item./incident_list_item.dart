import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/incident_list_item./pages/incident_list_item_detail_page.dart';
import 'package:impaxt_alert/logic/incidents/model/incident/incident.dart';
import 'package:impaxt_alert/logic/incidents/provider/contacts/contacts_by_incident_provider.dart';
import 'package:share_plus/share_plus.dart';

class IncidentListItem extends ConsumerWidget {
  const IncidentListItem({required this.incident, super.key});

  final Incident incident;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double force = incident.x.abs() + incident.y.abs() + incident.z.abs();
    final double acceleration = sqrt(
        incident.x * incident.x +
            incident.y * incident.y +
            incident.z * incident.z
    );
    final String hour = incident.createdAt.toLocal().toString().substring(11, 19);
    final String date = incident.createdAt.toLocal().toString().substring(0, 11);
    final contacts = ref.watch(contactsByIncidentProvider(incident.uuid));
    return contacts.when(
        data: (contacts) {
          return ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    IncidentListItemDetailPage(
                      date: date,
                      hour: hour,
                      force: force,
                      called_rescue: incident.called_rescue,
                      contacts: contacts,
                      response_time: incident.response_time,
                      lat: incident.lat,
                      long: incident.long,
                      acceleration: acceleration
                    )
                ),
              );
            },
            leading: const Icon(Icons.warning, color: Colors.red),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "$date " " $hour",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () async {
                      await SharePlus.instance.share(
                        ShareParams(
                          text:
                          "Riepilogo \n Data: $date \n Ora: $hour \n Forza: $force \n Sono stati chiamati i contatti? ${incident.called_rescue == 1 ? "si" : "no"} \n Tempo di risposta alla domanda ${incident.response_time == 0 ? "Nessuna" : "${incident.response_time} s"}",
                        ),
                      );
                    },
                icon: Icon(Icons.share)
                ),
              ],
            ),
            subtitle: Row(
              spacing: 10,
              children: [
                Text("Intensità impatto", style: TextStyle(fontWeight: FontWeight.bold)),
                force > 20
                    ? Text("alto")
                    : (force < 20 ? Text("basso") : Text("medio")),
              ],
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