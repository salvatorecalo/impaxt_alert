import 'package:flutter/material.dart';
import 'package:impaxt_alert/pages/home_page/pages/index.dart';
import 'package:impaxt_alert/pages/utils/index.dart';

class NoIncidentRelevation extends StatelessWidget {
  final VoidCallback? onGoToShop;

  const NoIncidentRelevation(
      {
        super.key,
        required this.onGoToShop,
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            width: 300,
            'images/no_more_revelation.png'
          ),
          Text(
            "Limite giornaliero raggiunto",
            style: TextStyle(
                fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          Align(
            child: Text(
              textAlign: TextAlign.center,
              "Hai esaurito il numero di rilevazioni possibili giornaliere. Riprova domani o acquista la possibilità di fare rilevazioni.",
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShopPage()),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: blue,
                minimumSize: Size(
                    double.infinity,
                    50
                )
              ),
              child: Text("Acquista", style: TextStyle(color: white)),
              onPressed: () {
                Navigator.pop(context);
                onGoToShop!.call();
              },
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Torna alla home page"),
          ),
        ],
      ),
    );
  }
}
