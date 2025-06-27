import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/pages/home_page/home_page.dart';
import 'package:impaxt_alert/pages/on_boarding/on_boarding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGuard extends ConsumerWidget {
  const AuthGuard({super.key});

  Future<bool> isOnBoardViewed() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onBoardViewed') ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<bool>(
      future: isOnBoardViewed(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}'));
        } else {
          final viewed = snapshot.data ?? false;
          return viewed ? const HomePage() : const OnboardingScreen();
        }
      },
    );
  }
}
