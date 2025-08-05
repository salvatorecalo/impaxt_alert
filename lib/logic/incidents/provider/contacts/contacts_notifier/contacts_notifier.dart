import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/provider/contacts/model/my_contact_model.dart';
import 'package:impaxt_alert/logic/incidents/provider/incident_dao/incident_dao_provider/incident_dao_provider.dart';
import 'package:impaxt_alert/logic/supabase/index.dart';
import 'package:impaxt_alert/logic/user_logic/user_session_provider/user_session_provider.dart';
import 'package:sqflite/sqflite.dart';

class ContactsNotifier extends StateNotifier<List<Contact>> {
  ContactsNotifier() : super([]);

  Future<void> addContact(Contact contact, WidgetRef ref) async {
    if (!state.any((c) => c.phoneNumber == contact.phoneNumber)) {
      state = [...state, contact];
    }

    // Locale
    final dao = ref.read(daoProvider);
    final db = await dao.openMyDb();
    await db.insert("contacts", {
      'contact_name': contact.name,
      'contact_phone_number': contact.phoneNumber,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Supabase
    final session = ref.read(authSessionProvider).value;
    if (session != null) {
      final userId = session.user.id;
      await supabase.from("contacts").insert({
        'user_id': userId,
        'contact_name': contact.name,
        'contact_phone_number': contact.phoneNumber,
      });
    }
  }

  Future<void> removeContact(String phoneNumber, WidgetRef ref) async {
    // Stato interno
    state = state.where((c) => c.phoneNumber != phoneNumber).toList();

    // Locale
    final dao = ref.read(daoProvider);
    final db = await dao.openMyDb();
    await db.delete(
      'contacts',
      where: 'contact_phone_number = ?',
      whereArgs: [phoneNumber],
    );

    // Supabase
    final session = ref.read(authSessionProvider).value;
    if (session != null) {
      final userId = session.user.id;
      await supabase
          .from("contacts")
          .delete()
          .eq("contact_phone_number", phoneNumber)
          .eq("user_id", userId);
    }
  }

  Future<void> syncContactsFromLocalToSupabase(WidgetRef ref) async {
    final session = ref.read(authSessionProvider).value;
    if (session == null) return;

    final userId = session.user.id;
    final dao = ref.read(daoProvider);
    final db = await dao.openMyDb();

    final localContacts = await db.query("contacts");

    final contactsToUpload = localContacts.map((row) {
      return {
        'user_id': userId,
        'contact_name': row['contact_name'],
        'contact_phone_number': row['contact_phone_number'],
      };
    }).toList();

    if (contactsToUpload.isNotEmpty) {
      await supabase
          .from("contacts")
          .upsert(contactsToUpload, onConflict: 'user_id, contact_phone_number');
    }
  }


  Future<void> uploadContactsToSupabase(WidgetRef ref) async {
    final session = ref.read(authSessionProvider).value;
    if (session == null) return;

    final userId = session.user.id;
    final dao = ref.read(daoProvider);
    final db = await dao.openMyDb();

    // Prendi tutti i contatti locali
    final localContacts = await db.query("contacts");

    // Mappa per inserimento
    final List<Map<String, dynamic>> contactsToUpload = localContacts.map((row) {
      return {
        'user_id': userId,
        'contact_name': row['contact_name'],
        'contact_phone_number': row['contact_phone_number'],
      };
    }).toList();

    if (contactsToUpload.isEmpty) return;

    // Per evitare duplicati, puoi usare UPSERT (PostgREST supporta insert con upsert)
    // Se supabase Dart client lo supporta:
    final response = await supabase
        .from('contacts')
        .upsert(contactsToUpload, onConflict: 'contact_phone_number, user_id');

    if (response.error != null) {
      // Gestisci errore
      print('Errore upload contatti: ${response.error!.message}');
    }
  }
}
