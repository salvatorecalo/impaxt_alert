import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authSessionProvider = StreamProvider<Session?>((ref) {
  final auth = Supabase.instance.client.auth;

  return (() async* {
    yield auth.currentSession;            // valore iniziale
    await for (final event in auth.onAuthStateChange) {
      yield event.session;                // valori successivi
    }
  })();
});
