class OnboardingContents {
  final String title;
  final String image;
  final String desc;

  OnboardingContents({
    required this.title,
    required this.image,
    required this.desc,
  });
}

List<OnboardingContents> contents = [
  OnboardingContents(
    title: "Rileviamo quando qualcosa va storto",
    image: "images/crash.png",
    desc: "In caso di un impatto brusco o un arresto improvviso, l’app si attiva automaticamente, anche se non la stai usando.",
  ),
  OnboardingContents(
    title: "Non rispondi? L’app avvisa per te.",
    image: "images/notification.png",
    desc:
    "Se non confermi di stare bene, viene inviata subito una notifica d’emergenza con data, ora e posizione.",
  ),
  OnboardingContents(
    title: "Avvisiamo chi conta davvero.",
    image: "images/contact.png",
    desc:
    "I tuoi contatti ricevono un SMS con tutte le informazioni utili per intervenire subito.",
  ),
];