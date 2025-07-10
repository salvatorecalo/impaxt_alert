import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:impaxt_alert/logic/user_logic/auth_controller/provider/auth_controller_provider.dart';
import 'package:impaxt_alert/pages/utils/index.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final authController = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Accedi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            spacing: 30,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                  "accedi per sincronizare la cronologia degli accadimenti su più dispositivi gratuitamente",
                  textAlign: TextAlign.center,

              ),
              Form(
                key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'inserisci una email valida';
                          } else if (!value.contains("@")) {
                            return 'la mail deve contenere una @';
                          }

                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'e.g. example@gmail.com',
                          label: Text('Email'),
                          border: OutlineInputBorder(
                          ),
                        ),
                      )
                    ],
                  )
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        await authController.signIn(emailController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Controlla la posta e apri il link.')),
                        );
                      } catch (err) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(err.toString())));
                      }
                    }
                  },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: blue,
                ),
                  child: Text(
                      "Accedi"
                  ),
              ),
            ],
          ),
        ),
    );
  }
}
