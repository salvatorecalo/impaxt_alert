import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/pages/auth_guard/auth_guard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Supabase.initialize(
      url: const String.fromEnvironment("API_URL"),
      anonKey: const String.fromEnvironment("API_KEY"),

  );

  runApp(
      ProviderScope(
          child: const MyApp(),
      ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ImpactAlert',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthGuard(),
    );
  }
}
