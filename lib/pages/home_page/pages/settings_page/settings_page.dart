import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/provider/providers.dart';
import 'package:impaxt_alert/pages/utils/index.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 30,
          children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,

                    ),
                    onPressed: () async {
                         final incidents = ref.watch(daoProvider);
                         incidents.deleteAllIncidents();
                    },
                    child: Text(
                      "Cancella i dati memorizzati",
                      style: TextStyle(
                        color: white
                      ),
                    ),
                ),
          ],
        ),
      ),
    );
  }
}
