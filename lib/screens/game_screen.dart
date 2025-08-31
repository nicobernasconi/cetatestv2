import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:cetatest/shared_pref/preferencias_usuario.dart';
import 'package:cetatest/ui/colors_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/ui_provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late AnimationController _controller;
  final List<String> cardPairs = [
    '1',
    '1a',
    '2',
    '2a',
    '3',
    '3a',
    '4',
    '4a',
    '5',
    '5a',
    '6',
    '6a',
  ];

  bool _isScreenActive = true;
  late AudioPlayer audioPlayer;
  late Timer _timer;
  late Timer _timerShowingCards;
  int _timeInSeconds = 0;
  PreferenciasUsuario prefs = PreferenciasUsuario();
  bool _victory = false;
  String? _firstSelectedCardId;
  int _intentos = 0;
  int _marcador = 0;
  String _email = '';
  bool _showingCards = false; // Mostrar cartas al inicio
  int _showingTime = 0; // Tiempo en segundos para mostrar cartas

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    audioPlayer = AudioPlayer();
    if (prefs.musica) {
      startBackgroundMusic();
    }
    cardPairs.shuffle();
    _timeInSeconds = prefs.tiempoJuego;
    _intentos = 0;
    _marcador = 0;
    _showingTime = 4 - prefs.dificultalJuego;
    _showingCards = (_showingTime > 0);
    // Mostrar las cartas durante un tiempo determinado antes de comenzar el juego

    if (_showingCards) {
      startShowingCardsTimer();
    } else {
      startTimer();
    }
  }

  void startShowingCardsTimer() {
    _timerShowingCards = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_showingTime > 0) {
          _showingTime--;
        } else {
          _showingCards = false;
          _timerShowingCards.cancel();
          startTimer();
        }
      });
    });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeInSeconds > 0) {
          _timeInSeconds--;
        } else {
          prefs.cantJuegosJugados++;
          Navigator.pushReplacementNamed(context, 'fail', arguments: {
            'marcador': _marcador,
            'tiempo': _timeInSeconds,
            'intentos': _intentos,
            'email': _email,
          });
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _isScreenActive = false;
    stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final screenSize = MediaQuery.of(context).size;
    final uiProvider = Provider.of<UIProvider>(context);
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _email = args['email'] ?? '';
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: ColoresApp.colorFondoGeneral,
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              color: ColoresApp.colorFondoGeneral,
              child: buildGameLayout(screenSize, uiProvider, _email),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGameLayout(Size screenSize, UIProvider uiProvider, String email) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPortrait = constraints.maxWidth < constraints.maxHeight;
        if (isPortrait) {
          // En vertical apilamos para evitar overflow horizontal
            return Column(
            children: [
              Expanded(
                flex: 6,
                child: buildCardGrid(uiProvider, screenSize, email),
              ),
              SizedBox(height: screenSize.height * 0.015),
              Expanded(
                flex: 2, // reducido (antes 4) para ~2/3 del tamaño previo
                child: buildScoreAndTimeContainer(screenSize, uiProvider),
              ),
            ],
          );
        }
        // En horizontal: grid principal + panel lateral angosto fijo basado en ancho
        final panelWidth = constraints.maxWidth * 0.18; // ~18% similar a maqueta
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: buildCardGrid(uiProvider, screenSize, email),
            ),
            SizedBox(width: constraints.maxWidth * 0.02),
            SizedBox(
              width: panelWidth.clamp(180.0, 260.0),
              child: buildScoreAndTimeContainer(screenSize, uiProvider),
            ),
          ],
        );
      },
    );
  }

  Widget buildCardGrid(UIProvider uiProvider, Size screenSize, String email) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Center(
          child: FractionallySizedBox(
            widthFactor: 0.87, // mismo factor de ancho que venías usando
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: cardPairs.length,
              itemBuilder: (context, index) {
                final cardId = cardPairs[index];
                return buildMemoryCard(uiProvider, cardId, screenSize, email);
              },
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget buildMemoryCard(

    
      UIProvider uiProvider, String cardId, Size screenSize, String email) {
        
    bool isFlipped = uiProvider.isCardFlipped(cardId);
    bool isRemoved = uiProvider.checkCardRemoved(cardId);

    String cardImage =
        isFlipped || _showingCards ? 'card_$cardId.png' : 'card_back.png';
    String cardImageKey = isFlipped ? 'card_$cardId' : 'card_back_$cardId';

    if (isRemoved) {
      cardImage = 'card_$cardId.png';
    }

    return GestureDetector(
      onTap: () {
        if (!_victory &&
            !isFlipped &&
            !isRemoved &&
            uiProvider.flippedCards.length < 2) {
          setState(() {
            uiProvider.addFlippedCard(cardId);

            if (uiProvider.flippedCards.length == 2) {
              _intentos++;
              int firstCardId = int.parse(uiProvider.flippedCards[0][0]);
              int secondCardId = int.parse(cardId[0]);

              if (firstCardId == secondCardId) {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final player = AudioPlayer();
                  if (prefs.sonido) {
                    await player.setVolume(1.0);
                    await player.setSource(AssetSource('sounds/correct.mp3'));
                    await player.resume();
                  }
                });
                _marcador++;
                uiProvider.addMarcador();
                uiProvider.removeCard(cardId);
                uiProvider.removeCard(_firstSelectedCardId);
                uiProvider.resetFlippedCards();
                if (uiProvider.cardsRemoved.length == 12) {
                  uiProvider.isGameWon = true;
                  _timer.cancel();
                }

                if (uiProvider.isGameWon) {
                  _victory = true;
                  prefs.cantJuegosJugados++;
                  Navigator.pushReplacementNamed(context, 'finish', arguments: {
                    'marcador': uiProvider.marcadorActual,
                    'tiempo': _timeInSeconds,
                    'intentos': _intentos,
                    'email': email,
                  });


                }
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  final player = AudioPlayer();
                  if (prefs.sonido) {
                    await player.setVolume(1.0);
                    await player
                        .setSource(AssetSource('sounds/negative_beeps.mp3'));
                    await player.resume();
                  }
                });
                Future.delayed(const Duration(milliseconds: 1000), () async {
                  uiProvider.resetFlippedCards();
                  setState(() {});
                });
              }
            } else if (uiProvider.flippedCards.length == 1) {
              _firstSelectedCardId = cardId;
            }
          });
        }
      },
      child: FractionallySizedBox(
        widthFactor: 0.97,
        heightFactor: 0.97,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Image.asset('assets/images/$cardImage', key: Key(cardImageKey)),
          ),
        ),
      ),
    );
  }

  Widget buildScoreAndTimeContainer(Size screenSize, UIProvider uiProvider) {
  return FractionallySizedBox(
    heightFactor: 0.90, // antes 0.99 -> reduce ~3% del alto total
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1b1e29),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          // Sombra ancha y más sólida en color principal
          BoxShadow(
            color: Color(0xCCEF8332), // más opaco
            offset: Offset(0, 7),
          ),
          // Sombra secundaria suave para profundidad
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          _StatBox(
            label: 'Puntaje:',
            value: '${uiProvider.marcadorActual}/6',
          ),
          const SizedBox(height: 28),
          _StatBox(
            label: 'Tiempo:',
            value: formatTime(_timeInSeconds),
          ),
          const Spacer(),
          Center(
            child: SizedBox(
              height: 55,
              child: Image.asset(
                'assets/images/logo_ceta_puntaje.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  void startBackgroundMusic() async {
    if (prefs.sonido) {
      await audioPlayer.setVolume(1.0);
    } else {
      await audioPlayer.setVolume(0.0);
    }
    await audioPlayer.setSource(AssetSource('sounds/game-music.mp3'));
    await audioPlayer.resume();
  }

  void stopBackgroundMusic() async {
    await audioPlayer.dispose();
  }
}

// Widget reutilizable para cajas de estadísticas (fuera de la clase State)
class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}


 
