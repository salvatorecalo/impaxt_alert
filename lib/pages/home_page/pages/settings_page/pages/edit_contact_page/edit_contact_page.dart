import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' hide Contact;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/provider/providers.dart';
import 'package:impaxt_alert/pages/utils/index.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class EditContactPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('Modifica lista contatti')),
        body: contacts.isEmpty
            ? Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      Text("Nessun contatto trovato"),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextButton(
                          onPressed: () async {
                            await launchUrl(
                              Uri.parse(
                                "https://salvatorecalo.github.io/impaxt_alert_privacy_policy.github.io/",
                              ),
                            );
                          },
                          child: Text(
                            "Privacy e trattamento dati",
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: contacts.length,
                          itemBuilder: (context, index) {
                            final contact = contacts[index];
                            return ListTile(
                              title: Text(contact.name),
                              subtitle: Text(contact.phoneNumber),
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  ref
                                      .read(contactsProvider.notifier)
                                      .removeContact(contact.phoneNumber);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextButton(
                          onPressed: () async {
                            await launchUrl(
                              Uri.parse(
                                "https://salvatorecalo.github.io/impaxt_alert_privacy_policy.github.io/",
                              ),
                            );
                          },
                          child: Text(
                            "Privacy e trattamento dati",
                            style: TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.all(10),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              minimumSize: Size(double.infinity, 50),
            ),
            onPressed: () {
              _showAddDialog(context, ref);
            },
            child: Text(
              "Aggiungine uno",
              textAlign: TextAlign.center,
              style: TextStyle(color: white),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _requestContactsPermission(BuildContext context) async {
    var status = await Permission.contacts.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      final result = await Permission.contacts.request();
      if (result.isGranted) {
        return true;
      } else if (result.isPermanentlyDenied) {
        bool openSettings = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Permesso necessario"),
            content: Text(
              "L'app necessita il permesso ai contatti. Vuoi aprire le impostazioni?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Sì"),
              ),
            ],
          ),
        );
        if (openSettings == true) {
          await openAppSettings();
        }
      }
      return false;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return false;
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) async {
    final granted = await _requestContactsPermission(context);
    if (!granted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Permesso contatti negato")));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => Center(child: const CircularProgressIndicator()),
    );

    final contacts = await FlutterContacts.getContacts(withProperties: true);

    Navigator.of(context).pop();

    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (ctx, index) {
          final c = contacts[index];
          return ListTile(
            title: Text(c.displayName),
            subtitle: c.phones.isNotEmpty ? Text(c.phones.first.number) : null,
            onTap: () {
              if (c.phones.isNotEmpty) {
                final _contact = Contact(
                  name: c.displayName,
                  phoneNumber: c.phones.first.number,
                );
                ref.read(contactsProvider.notifier).addContact(_contact, ref);
                Navigator.of(context).pop(); // chiudi bottom sheet
              }
            },
          );
        },
      ),
    );
  }
}
