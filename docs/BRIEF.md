# Brief : Insider Threat (app Flutter du Narrateur)

## Le projet
Jeu de déduction sociale inspiré des Loups-garous de Thiercelieux, transposé dans un réseau d'entreprise piraté (CORP-LAN). Il se joue de **5 à 14 joueurs**, avec **1 Narrateur humain**. L'app est le compagnon du Narrateur : elle affiche le texte à lire étape par étape, gère les choix de nuit, le suivi de partie, les timers et les Events. Tous les textes de l'app sont en anglais.

- **Dossier :** `/Users/elysabeth/English Game` (pas de dépôt git).
- **Plateformes :** iOS, Android, web. Flutter 3.47.5, Dart 3.13.

## Sources de référence
- **Règles :** `/Users/elysabeth/Downloads/Insider-Threat-Regles-FR-2.pdf` (version FR, 5 à 14 joueurs, quiz des Événements). Elle remplace le rulebook V2 et le `Insider-Threat-Rulebook.pdf` du dossier projet.
- **Events (mode Expert) :** `Insider-Threat-Evenement.pdf`, avec 10 Events. Il **remplace** la liste d'Events et les cartes Défense de la V2.
- **Prototype UI :** https://claude.ai/artifact/BmQjqDLJ2iXpw6dcXFAUc7 (canvas Design, board `Proto.dc.html`).
- **Moodboard :** `MOODBOARD.png` (vert acide, terminal CRT, glitch). Pas encore appliqué : l'app suit le look navy néon du prototype.
- **Exemple d'animation du tirage d'Event :** `/Users/elysabeth/Downloads/flutter_event_draw/`.

## Architecture
- `lib/game/` : moteur de règles en Dart pur, sans UI, entièrement testé.
  - `game_controller.dart` : machine à états nuit, jour et fin. Gère les éliminations en chaîne (VPN, Dead Man's Switch, successeur du CISO), les conditions de victoire et les Events. Il expose un `GuideStep` que l'UI se contente d'afficher.
  - `night_script.dart` / `day_script.dart` : construction des étapes et textes « Say » (repris du rulebook).
  - `setup_controller.dart` : noms dans l'ordre de la table, rôles choisis à la main ou par scan, compositions recommandées (`compositions.dart`).
  - `card_code.dart` : format des QR des cartes, `INSIDERTHREAT:1:<role>:<nn>`.
- `lib/ui/` :
  - `home_screen` ;
  - `setup_screen`, avec le bouton « Deal at random » pour tester sans cartes ;
  - `scan_screen` (mobile_scanner) ;
  - `guide_screen` (toutes les étapes de nuit et de jour) ;
  - `end_screen` ;
  - `widgets.dart`.
- `lib/theme/app_theme.dart` : couleurs et polices (Chakra Petch + JetBrains Mono via google_fonts). `AppText.useGoogleFonts = false` dans les tests.
- `qr-codes/` : 18 PNG et un PDF A4 à imprimer. Le jeu complet comprend 4 Red, 8 Defenders, 1 de chaque rôle spécial et 1 Purple. C'est plus que nécessaire pour 14 joueurs (3 Red et 5 Defenders au maximum), donc rien à réimprimer.

## Décisions prises (à garder)
- **Victoire du Red Team :** uniquement quand il ne reste que des Red, selon le rulebook. Le prototype, lui, arrêtait la partie dès que les Red égalaient les autres.
- **Night order :** construit à partir des rôles distribués. Un rôle éliminé est quand même appelé, avec un temps d'attente. Un rôle non distribué n'est **jamais** appelé, même si les règles le conseillent (choix de l'utilisatrice).
- **Compositions :** tableau des règles de 5 à 14 joueurs, sans interpolation. La Purple Team n'est autorisée qu'à 14 joueurs (bloqué dans le setup).
- **Chronos :** débat 3 min, élection du CISO 1 min.
- **C2 Server Down :** unanimité obligatoire, même à 4 attaquants.
- **Honeypot déclenché :** l'Incident Responder ne voit aucune victime et ne peut pas consommer son Backup Restore.
- **VPN Tunnel :** rappel au Narrateur pendant le vote (dans le « todo », jamais lu à voix haute).
- **Events :** tirés à partir du jour 2, juste après le rapport du matin (et l'élection du CISO s'il n'y en a pas). Tirage sans remise, puis le paquet est remélangé. Seulement en **mode Expert**, qui est désactivé par défaut dans le setup.
- **QR codes :** au **recto** des cartes, pour que tous les dos restent identiques.
- **Répliques inventées, à faire relire :** Dead Man's Switch, successeur du CISO, victoires Purple, VPN et Total Outage, et l'étape Dawn.

## État actuel
- **Tests :** 69 qui passent (`flutter test`), analyse propre (`flutter analyze`), build iOS simulateur OK.
- **Sur appareil :** l'utilisatrice a joué 2 parties entières, sans activer le mode Expert.
- **Scan QR :** non testé avec une vraie caméra.
- **Android :** SDK non installé sur le Mac, jamais buildé.

## Animation du tirage d'Event (faite)
Le déroulé est repris de `/Users/elysabeth/Downloads/flutter_event_draw/` : alerte « INCOMING EVENT », balayage, allumage CRT, glitch RGB, retournement 3D, puis révélation avec titre décodé et blocs en cascade. Les sons sont dans `assets/sfx/` et passent par `audioplayers`.

- **Code :** `lib/ui/event_draw/` (`event_draw_panel.dart`, `event_card_faces.dart`, `glitch.dart`, `sfx.dart`). Les textes imprimés des cartes sont dans `eventCardFaces` (`lib/game/events.dart`).
- **Fonctionnement :** le tirage est fait par le moteur, l'animation ne fait que révéler `todayEvent`. Elle se joue une seule fois par jour (`GameController.markEventRevealed`), avec un bouton « Replay the draw ».
- **Accessibilité :** le réglage « réduire les animations » est respecté.
- **Tests :** `Sfx.enabled = false`.

## Reste à faire ensuite
- **Quiz des Événements (mode Expert) :** question à 3 réponses mélangées, 10 s de réflexion, bonne réponse + explication, puis l'Événement a lieu ou est bloqué selon son camp et le nombre de bonnes réponses (voir section 8 des règles).
- **Mode Expert plus visible :** choix Base / Expert, et badge pendant la partie.
- **Ambiance sonore et sons des étapes :** actuellement « Audio coming soon ».
- **Polices intégrées** dans l'app : la release Android n'a pas la permission Internet, et le jeu doit pouvoir tourner hors ligne.
- **Écran toujours allumé** pendant la partie (wakelock).
- **Icône** de l'app.
- **Tests sur vrai téléphone** : scan QR et bouton retour Android.
- **Thème :** éventuellement repasser vers le moodboard.

## Consignes de l'utilisatrice
- Répondre en français.
- **Ne pas lancer le simulateur** : elle le fait elle-même. Analyser, tester et builder, c'est OK.
- Elle aime avancer par premier jet, puis vérifier ensemble.
