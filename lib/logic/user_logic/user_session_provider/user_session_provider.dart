import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/user_logic/auth_state_provider/auth_state_provider.dart';

final authSessionProvider = Provider((ref){
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (data) => data.session,
    loading: () => null,
    error: (_, __) => null,
  );
});