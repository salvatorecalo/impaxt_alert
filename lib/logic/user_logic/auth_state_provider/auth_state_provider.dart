import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/supabase/index.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<AuthState>((ref){
  return supabase.auth.onAuthStateChange.map((data) {
    return data;
  });
});
