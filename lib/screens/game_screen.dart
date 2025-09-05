import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:cetatest_v2/shared_pref/preferencias_usuario.dart';
import 'package:cetatest_v2/ui/colors_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cetatest_v2/ui/size_config.dart';

import '../providers/ui_provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
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
  // Reducimos el tiempo que se muestran las cartas al inicio.
  // Antes: 4 - dificultad  (0..3) => 4,3,2,1
  // Ahora: base 2 => 2,1,0,0 para dificultades 0..3 (más rápido iniciar el juego).
  const int baseShowSeconds = 2;
  _showingTime = (baseShowSeconds - prefs.dificultalJuego).clamp(0, baseShowSeconds);
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
    stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  UIScale.init(context);
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
        UIScale.init(context); // asegurar recalculo si cambia orientación
        final isPortrait = constraints.maxWidth < constraints.maxHeight;
        if (isPortrait) {
          // En vertical apilamos para evitar overflow horizontal
          final scoreHeight = (constraints.maxHeight * 0.22)
              .clamp(UIScale.h(150), UIScale.h(260));
          final gridAvailableHeight = constraints.maxHeight - scoreHeight - UIScale.h(12);
          return Stack(
            children: [
              // Grilla centrada vertical y horizontalmente
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: gridAvailableHeight,
                  child: buildCardGrid(uiProvider, screenSize, email,
                      isPortrait: true, maxWidth: constraints.maxWidth),
                ),
              ),
              // Panel de puntaje anclado abajo
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: UIScale.h(4)),
                  child: SizedBox(
                    height: scoreHeight,
                    child: buildScoreAndTimeContainer(screenSize, uiProvider),
                  ),
                ),
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
              child: buildCardGrid(uiProvider, screenSize, email,
                  isPortrait: false, maxWidth: constraints.maxWidth),
            ),
            // Espacio reducido entre grilla y panel (antes 2% del ancho)
            SizedBox(width: (constraints.maxWidth * 0.012).clamp(6.0, 18.0)),
            SizedBox(
              width: panelWidth.clamp(180.0, 260.0),
              child: buildScoreAndTimeContainer(screenSize, uiProvider),
            ),
          ],
        );
      },
    );
  }

  Widget buildCardGrid(UIProvider uiProvider, Size screenSize, String email,
      {required bool isPortrait, required double maxWidth}) {
    final horizontalPadding = UIScale.w(8);
    final spacingH = UIScale.w(9).clamp(4, 14); // separación horizontal solicitada
    final spacingV = UIScale.h(14).clamp(8, 24); // vertical algo mayor
    final baseWidthFactor = isPortrait ? 0.92 : 0.88;
  const double gridScale = 1.0; // revertimos reducción (tamaño completo)
  final widthFactor = (baseWidthFactor * gridScale).clamp(0.5, 0.95);
    // Aspect ratio fijo cuadrado según proporción de maqueta
    double aspectRatio = 1.0;
    return Center(
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: LayoutBuilder(
          builder: (ctx, box) {
            bool allowScroll = false;
            final availableHeight = box.maxHeight;
            final totalSpacing = spacingV * 2 + UIScale.h(20);
            final cardWidth = (box.maxWidth - (spacingH * 3)) / 4;
            double cardHeight = cardWidth / aspectRatio; // inicial
            double estimatedHeight = cardHeight * 3 + totalSpacing; // altura grilla
            if (!isPortrait) {
              // En landscape queremos que coincida con panel (~90% del alto)
              final targetHeight = availableHeight * 0.90;
              if (estimatedHeight > targetHeight) {
                // Aplanamos cartas aumentando aspectRatio para reducir altura
                final neededScale = targetHeight / estimatedHeight; // <1
                aspectRatio = (aspectRatio / neededScale).clamp(0.8, 2.0);
                cardHeight = cardWidth / aspectRatio;
                estimatedHeight = cardHeight * 3 + totalSpacing;
              }
            } else {
              // Portrait: si no entra toda la grilla, permitir scroll manteniendo cuadrado
              if (estimatedHeight > availableHeight) {
                allowScroll = true;
              }
            }
            // Portrait: intentar aplanar antes de permitir scroll
            if (isPortrait && estimatedHeight > availableHeight) {
              final targetHeight = availableHeight * 0.98; // margen leve
              final neededScale = targetHeight / estimatedHeight; // <1
              aspectRatio = (aspectRatio / neededScale).clamp(0.8, 2.2);
              cardHeight = cardWidth / aspectRatio;
              estimatedHeight = cardHeight * 3 + totalSpacing;
              if (estimatedHeight > availableHeight) {
                allowScroll = true;
              }
            }
            final grid = GridView.builder(
              physics: allowScroll
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding, vertical: UIScale.h(8)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: spacingV.toDouble(),
                crossAxisSpacing: spacingH.toDouble(),
                childAspectRatio: aspectRatio,
              ),
              itemCount: cardPairs.length,
              itemBuilder: (context, index) {
                final cardId = cardPairs[index];
                return buildMemoryCard(uiProvider, cardId, screenSize, email);
              },
            );
            // Añadimos Expanded arriba y abajo para centrar y permitir compresión
            return Column(
              children: [
                const Expanded(child: SizedBox()),
                grid,
                const Expanded(child: SizedBox()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget buildMemoryCard(
      UIProvider uiProvider, String cardId, Size screenSize, String email) {
    // Estado de la carta
    bool isFlipped = uiProvider.isCardFlipped(cardId);
    bool isRemoved = uiProvider.checkCardRemoved(cardId);
    final bool faceUp = isFlipped || _showingCards || isRemoved;

    return GestureDetector(
      onTap: () {
        if (_victory || isFlipped || isRemoved || uiProvider.flippedCards.length >= 2) return;
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
                  await player.setSource(AssetSource('sounds/negative_beeps.mp3'));
                  await player.resume();
                }
              });
              Future.delayed(const Duration(milliseconds: 900), () async {
                uiProvider.resetFlippedCards();
                if (mounted) setState(() {});
              });
            }
          } else if (uiProvider.flippedCards.length == 1) {
            _firstSelectedCardId = cardId;
          }
        });
      },
      child: FractionallySizedBox(
        widthFactor: 1.0,
        heightFactor: 1.0,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: faceUp ? 1 : 0),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            // value: 0 (dorso) -> 1 (frente)
            final angle = value * math.pi; // 0..pi
            // Determinar qué cara mostrar
            final showFront = angle > math.pi / 2;
            Widget front = Image.asset('assets/images/card_$cardId.png');
            Widget back = Image.asset('assets/images/card_back.png');
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspectiva ligera
                ..rotateY(angle),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                // Corregimos espejo del frente aplicando rotación adicional
                child: showFront
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(math.pi),
                        child: front,
                      )
                    : back,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildScoreAndTimeContainer(Size screenSize, UIProvider uiProvider) {
    final paddingH = UIScale.w(10);
    final paddingV = UIScale.h(10);
    final gapBoxes = UIScale.h(24).clamp(16, 36);
    final logoWidth = UIScale.w(90).clamp(80.0, 160.0); // Ajuste ahora por width
    return FractionallySizedBox(
      heightFactor: 0.90,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: UIScale.h(10)),
        decoration: BoxDecoration(
          color: const Color(0xFF1b1e29),
            borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xCCEF8332),
              offset: Offset(0, 7),
            ),
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            _StatBox(
              label: 'Puntaje:',
              value: '${uiProvider.marcadorActual}/6',
            ),
            SizedBox(height: gapBoxes.toDouble()),
            _StatBox(
              label: 'Tiempo:',
              value: formatTime(_timeInSeconds),
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: logoWidth,
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
  UIScale.init(context);
    return Container(
    padding: EdgeInsets.symmetric(
      horizontal: UIScale.w(6), vertical: UIScale.h(4)),
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
        fontSize: UIScale.fDown(18),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: UIScale.fDown(35),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}


 
