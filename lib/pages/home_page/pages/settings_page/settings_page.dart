import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/provider/providers.dart';
import 'package:impaxt_alert/pages/home_page/pages/settings_page/pages/edit_contact_page/edit_contact_page.dart';
import 'package:impaxt_alert/pages/utils/index.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 30,
            children: [
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: () async {
                             final incidents = ref.watch(daoProvider);
                             incidents.deleteAllIncidents();
                        },
                        child: Text(
                          "Svuota cronologia incidenti locale",
                          style: TextStyle(
                            color: white
                          ),
                        ),
                    ),
                  ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditContactPage(),
                    ),
                  );
                },
                child: Text(
                  "Modifica lista contatti notificati",
                  style: TextStyle(
                      color: white
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
