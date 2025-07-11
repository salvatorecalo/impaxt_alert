import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/provider/providers.dart';
import 'package:impaxt_alert/pages/utils/index.dart';

class EditContactPage extends ConsumerWidget {
  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Modifica lista contatti')),
      body: contacts.isEmpty
          ? Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Nessun contatto trovato"),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  _showAddDialog(context, ref);
                },
                child: Text(
                  "Aggiungine uno!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: white
                  ),
                ),
              ),

            ],
          ),
        ),
      )
          : ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return ListTile(
            title: Text(contact.name),
            subtitle: Text(contact.phoneNumber),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditDialog(context, ref, contact);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    ref.read(contactsProvider.notifier).removeContact(contact.phoneNumber);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Aggiungi contatto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nome')),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Telefono')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              final newContact = Contact(name: nameController.text, phoneNumber: phoneController.text);
              ref.read(contactsProvider.notifier).addContact(newContact, ref);
              Navigator.pop(context);
            },
            child: Text('Salva'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Contact contact) {
    final nameController = TextEditingController(text: contact.name);
    final phoneController = TextEditingController(text: contact.phoneNumber);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Modifica contatto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Nome')),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: 'Telefono')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              final updatedContact = contact.copyWith(
                name: nameController.text,
                phoneNumber: phoneController.text,
              );
              ref.read(contactsProvider.notifier).updateContact(updatedContact, ref);
              Navigator.pop(context);
            },
            child: Text('Salva'),
          ),
        ],
      ),
    );
  }
}
