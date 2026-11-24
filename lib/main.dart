import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/game_controller.dart';
import 'game/setup_controller.dart';
import 'theme/app_theme.dart';
import 'ui/end_screen.dart';
import 'ui/guide_screen.dart';
import 'ui/home_screen.dart';
import 'ui/setup_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const InsiderThreatApp());
}

class InsiderThreatApp extends StatelessWidget {
  const InsiderThreatApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Insider Threat',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const AppRoot(),
      );
}

enum _Screen { home, setup, game }

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final _setup = SetupController();
  _Screen _screen = _Screen.home;
  GameController? _game;

  @override
  void dispose() {
    _game?.dispose();
    _setup.dispose();
    super.dispose();
  }

  void _start() {
    _game?.dispose();
    setState(() {
      _game = GameController(
        players: _setup.buildPlayers(),
        expert: _setup.expert,
      );
      _screen = _Screen.game;
    });
  }

  void _toSetup() {
    _game?.dispose();
    _setup.clearRoles(); // names stay, new cards are dealt
    setState(() {
      _game = null;
      _screen = _Screen.setup;
    });
  }

  Future<void> _confirmQuit() async {
    final quit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Quit this game?', style: AppText.ui(20, weight: FontWeight.w700)),
        content: Text('The current game will be lost.', style: AppText.ui(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep playing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Quit', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (quit == true) _toSetup();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _screen == _Screen.home,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_screen == _Screen.game) {
          _confirmQuit();
        } else {
          setState(() => _screen = _Screen.home);
        }
      },
      child: switch (_screen) {
        _Screen.home => HomeScreen(
            onNewGame: () => setState(() => _screen = _Screen.setup),
          ),
        _Screen.setup => SetupScreen(
            setup: _setup,
            onBack: () => setState(() => _screen = _Screen.home),
            onStart: _start,
          ),
        _Screen.game => ListenableBuilder(
            listenable: _game!,
            builder: (context, _) => _game!.phase == GamePhase.end
                ? EndScreen(game: _game!, onNewGame: _toSetup)
                : GuideScreen(game: _game!, onQuit: _confirmQuit),
          ),
      },
    );
  }
}
