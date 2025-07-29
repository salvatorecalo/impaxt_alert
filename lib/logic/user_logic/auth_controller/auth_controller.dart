import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/incidents/provider/providers.dart';
import 'package:impaxt_alert/logic/supabase/index.dart';
import 'package:impaxt_alert/logic/user_logic/user_session_provider/user_session_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {

  Future<bool> signIn(String email) async {
    try {
      await supabase.auth.signInWithOtp(
          email: email,
          emailRedirectTo: 'impactalert://login-callback',
      );
      return true;
    } on AuthException catch (e) {
      print('Errore login: ${e.message}');
    } catch (e) {
      print('Errore generico: $e');
    }
    return false;
  }

  // LOGOUT
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // OTTIENI L'UTENTE ATTUALE
  User? getUser() {
    return supabase.auth.currentUser;
  }

  // ELIMINA ACCOUNT
  Future<void> deleteAccount(String userId) async {
    await supabase.auth.admin.deleteUser(userId);
    await supabase.auth.signOut();
  }

  Future<void> pushLocalIncidents(WidgetRef ref) async {
    final session = ref.watch(authSessionProvider).asData?.value;
    if (session != null) {
      final dao = ref.watch(daoProvider);
      final incidents = await dao.getIncidents();

      if (incidents.isNotEmpty) {
        for (var incident in incidents) {
          try {
            await supabase.from("incidents").insert({
              "uuid": incident['uuid'],
              "created_at": incident['created_at'],
              'x': incident['x'],
              'y': incident['y'],
              'z': incident['z'],
              'called_rescue': incident['called_rescue'],
              'synced': incident['synced'],
              'response_time': incident['response_time']
            });
          } catch (e) {
            print('Errore inserimento incident ${incident['uuid']}: $e');
          }
        }
      }
    }
  }

  Future<void> pushLocalContacts(WidgetRef ref) async {
    final session = ref.watch(authSessionProvider).asData?.value;
    if (session != null) {
      final dao = ref.watch(daoProvider);
      final incidents = await dao.getIncidents();

      if (incidents.isNotEmpty) {
        for (var incident in incidents) {
          try {
            final contacts = await dao.getContactsByIncident(incident['uuid'].toString());
            for (var contact in contacts) {
              await supabase.from("incident_contact_notificated").insert({
                "incident_uuid": contact['incident_uuid'],
                "contact_name": contact['contact_name'],
                "contact_phone_number": contact['contact_phone_number']
              });
            }
          } catch (e) {
            print('Errore inserimento contatti per incident ${incident['uuid']}: $e');
          }
        }
      }
    }
  }

}