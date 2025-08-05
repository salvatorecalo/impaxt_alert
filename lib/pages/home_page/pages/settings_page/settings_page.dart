import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/provider/incident_dao/incident_dao_provider/incident_dao_provider.dart';
import 'package:impaxt_alert/logic/user_logic/auth_controller/provider/auth_controller_provider.dart';
import 'package:impaxt_alert/logic/user_logic/user_session_provider/user_session_provider.dart';
import 'package:impaxt_alert/pages/home_page/pages/settings_page/pages/edit_contact_page/edit_contact_page.dart';
import 'package:impaxt_alert/pages/utils/index.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final authController = ref.watch(authControllerProvider);

    return SafeArea(
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            spacing: 30,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: ElevatedButton(
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
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    final confirmed = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Sei sicuro di voler procedere?"),
                          content: Text("Non sarà possibile ripristinare i dati cancellati", style: TextStyle(fontWeight: FontWeight.bold,),),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Annulla"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Elimina"),
                            ),
                          ],
                        )
                    );
                    if (confirmed) {
                      final incidents = ref.watch(daoProvider);
                      incidents.deleteAllIncidents();
                    }
                  },
                  child: Text(
                    "Svuota cronologia incidenti locale",
                    style: TextStyle(
                        color: white
                    ),
                  ),
                ),
              session.when(
                  data: (session) {
                    if (session != null) {
                      return
                        Column(
                          spacing: 30,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(
                                      double.infinity,
                                      50
                                  ),
                                  backgroundColor: Colors.red[600]
                              ),
                              onPressed: () {
                                authController.signOut();
                              },
                              child: Text(
                                "Disconnettiti",
                                style: TextStyle(
                                    color: white
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: Size(
                                      double.infinity,
                                      50
                                  ),
                                  backgroundColor: Colors.red[700]
                              ),
                              onPressed: () async {
                                final confirmed = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Sei sicuro di voler cancellare l'account? "),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text("Annulla"),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text("Elimina"),
                                        ),
                                      ],
                                    )
                                );
                                if (confirmed) {
                                  authController.deleteAccount(session.user.id);
                                }
                              },
                              child: Text(
                                "Cancella il mio account",
                                style: TextStyle(
                                    color: white
                                ),
                              ),
                            ),
                          ],
                        );
                    }
                    return SizedBox.shrink();
                  },
                  error: (error, trace) => Text(error.toString()),
                  loading: () => CircularProgressIndicator(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
