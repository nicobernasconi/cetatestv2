import 'package:cetatest/shared_pref/preferencias_usuario.dart';
import 'package:flutter/material.dart';
import 'package:cetatest/ui/colors_ui.dart';
import 'package:provider/provider.dart';
import '../ui/size_config.dart';
import '../providers/ui_provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../services/services.dart';

class FailScreen extends StatefulWidget {
  const FailScreen({Key? key});

  @override
  _FailScreenState createState() => _FailScreenState();
}

class _FailScreenState extends State<FailScreen> {
  final player = AudioPlayer();
  final AudioCache audioCache = AudioCache();
  final prefs = PreferenciasUsuario();

  @override
  void initState() {
    super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Reproduce el sonido después de que el widget se haya construido

      if (prefs.sonido) {
        await player.setVolume(1.0);
      } else {
        await player.setVolume(0.0);
      }
      await player.setSource(AssetSource('sounds/failure-lavel.mp3'));
      await player.resume();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  final Size size = MediaQuery.of(context).size;
  UIScale.init(context);
    final uiProvider = Provider.of<UIProvider>(context, listen: false);

    final int marcadores = args['marcador'] ?? 0;
    final int tiempo = prefs.tiempoJuego - (args['tiempo'] ?? 0) as int;
    final int intentos = args['intentos'] ?? 0;
    final String usuario = args['email'] ?? '';
    final String nombre = args['nombre'] ?? '';
    final String empresa = args['empresa'] ?? '';
    final int dificultad = prefs.dificultalJuego;

    final int puntuacionFinal =
        (dificultad * (marcadores * (1000 - tiempo) / (intentos + 1))).toInt();

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: ColoresApp.colorFondoGeneral,
          body: SingleChildScrollView(
            child: Container(
              height: size.height,
              color: ColoresApp.colorFondoGeneral,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.10,
                    bottom: size.height * 0.15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo_ceta.png',
                        width: 275,
                        fit: BoxFit.contain,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '¡Perdiste!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: UIScale.fDown(108),
                              color: const Color(0xFFF47B30),
                            ),
                          ),
                        ),
                      ),
                      MaterialButton(
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => const AlertDialog(
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Preparando el nuevo juego',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Se está preparando el nuevo juego',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  CircularProgressIndicator(),
                                ],
                              ),
                            ),
                          );

                          final juegosService = JuegosService();
                          final nuevoJuego = {
                            'nombre_juego': 'Memotest',
                            'usuario': usuario,
                            'nombre': nombre,
                            'empresa': empresa,
                            'puntaje': puntuacionFinal,
                            'tiempo': tiempo,
                            'fecha': DateTime.now().toString(),
                            'enviado': 0,
                            'premio': '',
                          };
                          await juegosService.insertJuego(nuevoJuego);

                          uiProvider.resetFlippedCards();
                          uiProvider.resetMarcador();
                          uiProvider.resetCardRemoved();

                          if (prefs.cantJuegosJugados >= prefs.cantJuegos) {
                            prefs.cantJuegosJugados = 0;
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Row(
                                  children: const [
                                    Icon(
                                      Icons.info_outline,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Se superó la cantidad de juegos',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      'Se superó la cantidad de juegos',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.green,
                                      size: 80,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(context, 'home');
                                    },
                                    child: const Text('Aceptar'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            Navigator.pushReplacementNamed(context, 'mail');
                          }
                        },
                        child: Container(
                          width: size.width * 0.3,
                          height: size.height * 0.06,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1b1e29),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFEF8332),
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Reintentar',
                              style: TextStyle(
                                fontSize: 24.0,
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
