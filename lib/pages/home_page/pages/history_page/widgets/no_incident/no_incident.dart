import 'package:flutter/cupertino.dart';

class NoIncident extends StatelessWidget {
  const NoIncident({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 30,
      children: [
        SizedBox(
          width: double.infinity,
            height: 300,
            child: Image.asset('images/no_incidents.png'),
        ),
        Text(
            'Nessuna frenata brusca rilevata.\n Sono fiero di te!',
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
