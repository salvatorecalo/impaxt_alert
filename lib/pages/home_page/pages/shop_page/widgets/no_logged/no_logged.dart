import 'package:flutter/material.dart';
import 'package:impaxt_alert/pages/login_page/login_page.dart';
import 'package:impaxt_alert/pages/utils/index.dart';

class NoLogged extends StatelessWidget {
  const NoLogged({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          Image.asset('images/notification.png'),
          Text(
            'Rilevazioni quasi finite?\nAccedi subito per ricaricare il tuo account',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: white,
              minimumSize: const Size(double.infinity, 50),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
            child: const Text('Accedi'),
          ),
        ],
      ),
    );
  }
}
