import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:impaxt_alert/logic/incidents/incident_list_item./pages/flutter_map/flutter_map.dart';
import 'package:share_plus/share_plus.dart';

class IncidentListItemDetailPage extends StatelessWidget {
  final String date;
  final String hour;
  final double force;
  final List<Map<String, Object?>> contacts;
  final int called_rescue;
  final int response_time;
  final double lat;
  final double long;
  final double acceleration;

  const IncidentListItemDetailPage({
    super.key,
    required this.date,
    required this.hour,
    required this.force,
    required this.contacts,
    required this.called_rescue,
    required this.response_time,
    required this.lat,
    required this.long,
    required this.acceleration,
  });

  @override
  Widget build(BuildContext context) {
    print(called_rescue);
    return Scaffold(
      appBar: AppBar(
        title: Text("Riepologo segnalazione"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await SharePlus.instance.share(
                ShareParams(
                  text:
                      "Riepilogo \n Data: $date \n Ora: $hour \n Forza: $force \n Sono stati chiamati i contatti? ${called_rescue == 1 ? "si" : "no"} \n Tempo di risposta alla domanda ${response_time == 0 ? "Nessuna" : "${response_time} s"}",
                ),
              );
            },
            icon: Icon(Icons.share),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            spacing: 30,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Data", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(date),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Ora", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(hour),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Intensità impatto", style: TextStyle(fontWeight: FontWeight.bold)),
                  force > 20
                      ? Text("alto")
                      : (force < 20 ? Text("basso") : Text("medio")),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Accelerazione", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${acceleration.toStringAsFixed(2)} m/s\u00B2"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tempo di risposta",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("${response_time}s"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Contatti avvisati",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Icon(called_rescue == 1 ? Icons.close : Icons.check),
                ],
              ),
              SizedBox(
                  height: 350,
                  child: IncidentMap(lat: lat, long: long),
              ),
              Column(
                spacing: 30,
                children: [
                  Text(
                    "Contatti notificati: ",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (contacts.isEmpty)
                    Text("Nessun contatto notificato")
                  else
                    for (var contact in contacts)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(contact['contact_name'].toString() ?? ''),
                          Text(contact['contact_phone_number'].toString() ?? ''),
                        ],
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
