# Insider Threat : script du trailer (V1)

- **Durée :** 2:00 pile (8 séquences).
- **Format :** tourné à la caméra, mise en scène d'une vraie partie autour d'une table.
- **Voix off :** 100 % anglais, ton trailer (grave, posé, un peu menaçant). Environ 190 mots, ce qui laisse de la place à la musique et aux silences.
- **Motion :** limité à 4 éléments (logo, 2 textes à l'écran, carton de fin). Le reste vient de l'app filmée ou enregistrée en capture d'écran.

Légende :
- **VO** : voix off (hors champ).
- **IN** : réplique dite à l'écran par le Narrateur (c'est le vrai texte de l'app).
- **SFX** : sons du jeu, tous déjà dans `assets/sfx/`.

---

## 1. Cold open : 0:00 → 0:12

**Image :** noir total, puis une pièce sombre. Des joueurs assis autour d'une table, les yeux fermés, éclairés seulement par l'écran d'un téléphone posé au centre. Travelling lent sur les visages. Gros plan sur une main qui retourne une carte face cachée, juste assez pour voir le capuchon de GHOSTLOAD (Red Team).

**SFX :** `nightAmbience.mp3` en fond, très bas.

> **VO :** Every company has a network. Every network has a weakness.
> *(un temps)*
> And sometimes… the weakness is sitting right next to you.

Sur « next to you » : un joueur ouvre les yeux face caméra. Il ne sourit pas.

## 2. Titre : 0:12 → 0:18

**Image :** cut au noir.

**Motion n°1 :** logo INSIDER THREAT qui apparaît avec un glitch RGB, celui de l'animation d'Event.

**SFX :** `glitch.wav` puis `spawn.wav`.

*Pas de VO.*

## 3. Présentation : 0:18 → 0:32

**Image :** changement d'ambiance, lumière normale, plus chaleureuse. Des amis arrivent et s'installent. Les cartes sont distribuées. Gros plan sur le téléphone qui scanne le QR d'une carte (écran de scan de l'app). Le Narrateur tape les noms dans le setup.

**Motion n°2 :** texte à l'écran « 5–14 PLAYERS · 1 NARRATOR · 1 APP ».

> **VO :** Welcome to CORP-LAN. Five to fourteen players. One Narrator. One app that runs the whole game.
> *(un temps)*
> And somewhere around this table… a hacker.

## 4. La nuit : 0:32 → 0:50

**Image :** retour à la lumière sombre. Plan large : le Narrateur tient le téléphone, tout le monde ferme les yeux.

**SFX :** `nightAmbience.mp3`.

> **IN (Narrateur) :** Night falls on CORP-LAN. All employees, log off and close your eyes.
> **IN (Narrateur) :** Red Team… open your eyes.

Deux joueurs ouvrent les yeux. Ils échangent un regard, puis l'un pointe silencieusement quelqu'un du doigt. Gros plan sur la victime qui dort, sans se douter de rien.

> **VO :** At night, the Red Team wakes up. Silent. Coordinated. Choosing their next target.

## 5. La Blue Team : 0:50 → 1:10

**Image :** montage rapide, un plan par rôle (2 à 3 s chacun). Chaque rôle est montré par un geste, sans dialogue.

- **Threat Hunter :** pointe un joueur, le Narrateur lui montre discrètement la carte de ce joueur. Son regard change.
- **SOC Analyst :** pendant le tour des Red, entrouvre les yeux entre ses doigts.
- **Incident Responder :** hésite au-dessus de l'écran, entre « Backup Restore » et « Kill Process ».
- **Network Engineer :** le Narrateur touche l'épaule de deux joueurs, qui sont désormais liés.

> **VO :** But the Blue Team fights back. A Threat Hunter who sees through any disguise. A SOC Analyst who never really sleeps. An Incident Responder… with one backup, and one kill switch.

## 6. Le jour : 1:10 → 1:32

**Image :** la lumière revient d'un coup. Tout le monde ouvre les yeux.

**SFX :** `dayAmbience.mp3`.

> **IN (Narrateur) :** Good morning, CORP-LAN. Overnight, one machine went offline: Max has been compromised.

Max retourne sa carte, dépité. Les autres réagissent. Puis le débat : gros plan sur le chrono 3:00 de l'app qui défile, des doigts accusateurs, quelqu'un qui se défend, mains levées pour le vote. Un joueur est éliminé et retourne sa carte : Defender. Silence gêné autour de la table.

**SFX :** `timerWarning.mp3` sur la fin du chrono.

> **VO :** By day, everyone is a suspect. Debate. Accuse. Vote.
> *(sur la carte Defender retournée)*
> Get it wrong… and you just fired your best defender.

## 7. Mode Expert : 1:32 → 1:48

**Image :** insert plein écran sur l'animation de tirage d'Event : alerte « INCOMING EVENT », allumage CRT, retournement de la carte. C'est une capture d'écran de l'app, donc aucun motion à faire. Ensuite, les joueurs face à la question du quiz : ils lèvent 1 ou 2 doigts (Phishing Campaign).

**SFX :** `alert.wav`, puis `revealRed.wav`.

> **VO :** Play Expert mode, and real cyberattacks hit the office. Phishing. DDoS. Zero-Day.
> Answer right, together… or hand the hackers the keys.

**Motion n°3 :** texte à l'écran « EXPERT MODE ».

## 8. Climax et fin : 1:48 → 2:00

**Image :** dernier vote. Plan sur les mains levées, ralenti. Le joueur du cold open, celui qui avait ouvert les yeux, est épargné. Il pose sa carte face visible : Red Team. Il regarde la caméra.

**SFX :** coupure nette de la musique, puis `revealChaos.wav`.

> **VO (1:50) :** Trust is a vulnerability.

**Motion n°4 (1:54 → 2:00) :** carton de fin sur fond noir avec le logo INSIDER THREAT et la tagline :

> **VO :** Insider Threat. The threat is already inside.

---

## Notes de production

**Casting :** 7 à 8 joueurs plus 1 Narrateur. 4 personnes comptent vraiment à l'image :
- le Narrateur ;
- le « traître » du cold open ;
- Max, la victime ;
- le Defender éliminé par erreur.

**Lumière :** deux ambiances seulement.
- **Nuit :** pièce noire, téléphone en source principale, éventuellement une lampe LED verte ou bleue pour rappeler le moodboard.
- **Jour :** lumière normale, chaude.

**Accessoires :** les vraies cartes imprimées (avec les QR), un téléphone avec l'app, une table.

**Inserts écran :** les enregistrer directement sur le téléphone (enregistrement d'écran), c'est plus net que de filmer l'écran :
- scan QR ;
- texte de nuit ;
- chrono ;
- tirage d'Event ;
- quiz.

**Musique :** une piste électro sombre qui monte. Coupure nette à 1:48 pour le climax, puis la dernière note sur le carton de fin.

**VO :** à enregistrer en premier, pour caler le montage dessus. À 2,2 mots par seconde environ, chaque bloc tient dans sa séquence avec de la marge.

**Si c'est trop long au montage :** la séquence 5 se raccourcit le plus facilement. On peut enlever le Network Engineer, qui n'est pas dans la VO.
