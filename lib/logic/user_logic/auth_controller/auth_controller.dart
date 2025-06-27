import 'package:impaxt_alert/logic/supabase/index.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {

  // SIGNUP
  Future<String?> signUp(String email, String password, String name) async {
    try {
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'first_name': name},
      );

      if (res.user != null) {
        return null;
      }
    } on AuthException catch (e) {
      return e.message;
    }
    return null;
  }

  // LOGIN
  Future<String?> signIn(String email, String password) async {
    try {
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        return null;
      } else {
        return "User not found";
      }
    } on AuthException catch (e) {
      return e.message;
    }
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