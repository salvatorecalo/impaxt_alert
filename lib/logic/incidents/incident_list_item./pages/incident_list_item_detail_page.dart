import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class IncidentListItemDetailPage extends StatelessWidget {
  final String date;
  final String hour;
  final double force;
  final List<Map<String, Object?>> contacts;
  final int called_rescue;
  final int response_time;

  const IncidentListItemDetailPage({
    super.key,
    required this.date,
    required this.hour,
    required this.force,
    required this.contacts,
    required this.called_rescue,
    required this.response_time,
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
                Text("Hour", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(hour),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Force", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("${force.toStringAsFixed(1)}g"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tempo di risposta",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text("$response_time s"),
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
            Column(
              spacing: 30,
              children: [
                Text(
                  "Contatti notificati: ",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
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
    );
  }
}
