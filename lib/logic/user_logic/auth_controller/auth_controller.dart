import 'package:flutter/material.dart';
import 'package:impaxt_alert/logic/supabase/index.dart';
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

  // OTTIENI IL NOME UTENTE
  String? getUsername(User user) {
    return user.userMetadata?['first_name'];
  }
}