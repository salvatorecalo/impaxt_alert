import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authSessionProvider = StreamProvider<Session?>((ref) {
  final auth = Supabase.instance.client.auth;

  return auth.onAuthStateChange.map((event) => event.session).distinct();
});
