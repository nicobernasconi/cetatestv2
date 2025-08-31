import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cetatest/shared_pref/preferencias_usuario.dart';
import 'package:flutter/material.dart';
import 'package:cetatest/ui/colors_ui.dart';
import 'package:provider/provider.dart';
import '../providers/ui_provider.dart';

import '../services/services.dart';

class FinishScreen extends StatefulWidget {
  const FinishScreen({Key? key});

  @override
  _FinishScreenState createState() => _FinishScreenState();
}

class _FinishScreenState extends State<FinishScreen> {
  final player = AudioPlayer();
  final AudioCache audioCache = AudioCache();
  final prefs = PreferenciasUsuario();
  String premio = '';
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
      await player.setSource(AssetSource('sounds/level-win.mp3'));
      await player.resume();
    });

    final premisString = prefs.premios;
    //lista
    final List<String> premios = premisString.split(',');
    final randomPremio = Random();
    final int premioIndex = randomPremio.nextInt(premios.length);
    premio = premios[premioIndex];
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    Size size = MediaQuery.of(context).size;
    final uiProvider = Provider.of<UIProvider>(context);

    // Extraer los valores de los parámetros
    final int marcadores = args['marcador'] ?? 0;
    final int tiempo = prefs.tiempoJuego - (args['tiempo'] ?? 0) as int;
    final int intentos = args['intentos'] ?? 0;
    final String usuario = args['email'] ?? '';
    final String nombre = args['nombre'] ?? '';
    final String empresa = args['empresa'] ?? '';
    final int dificultad = prefs.dificultalJuego;

    int puntuacionFinal =
        (dificultad * (marcadores * (1000 - tiempo) / (intentos + 1))).toInt();

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          // Evitar que el usuario retroceda utilizando el botón de atrás del sistema
          return false;
        },
  child: Scaffold(
    backgroundColor: ColoresApp.colorFondoGeneral,
    body: SingleChildScrollView(
            child: Container(
              height: size
      .height, // Ajusta el alto del contenedor para que se ajuste al contenido
        color: ColoresApp.colorFondoGeneral,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.10,
                    bottom: size.height * 0.15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/logo_ceta.png',
                        width: 275,
                        fit: BoxFit.contain,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '¡Ganaste!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 108,
                              color: Color(0xFFF47B30),
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
                                  Icons
                                      .info_outline, // Cambia a un icono que desees
                                  color:
                                      Colors.blue, // Cambia el color del icono
                                ),
                                SizedBox(
                                    width:
                                        8), // Espacio entre el icono y el texto
                                Text(
                                  'Preparando el nuevo juego',
                                  style: TextStyle(
                                    fontSize:
                                        18, // Tamaño de fuente personalizado
                                    fontWeight: FontWeight
                                        .bold, // Estilo de fuente negrita
                                    color: Colors
                                        .blue, // Cambia el color del texto
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
                                    fontSize:
                                        16, // Tamaño de fuente personalizado
                                    color: Colors
                                        .black87, // Cambia el color del texto
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
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
                          'premio': premio
                        };
                        await juegosService.insertJuego(nuevoJuego);

                        uiProvider.resetFlippedCards();
                        uiProvider.resetMarcador();
                        uiProvider.resetCardRemoved();
                        uiProvider.isGameWon = false;

                        if (prefs.cantJuegosJugados >= prefs.cantJuegos) {
                          prefs.cantJuegosJugados = 0;
                          //mostrar dialogo que indique que se superaron los juegos

                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Row(
                                children: [
                                  Icon(
                                    Icons
                                        .info_outline, // Cambia a un icono que desees
                                    color: Colors
                                        .blue, // Cambia el color del icono
                                  ),
                                  SizedBox(
                                      width:
                                          8), // Espacio entre el icono y el texto
                                  Text(
                                    'Se superó la cantidad de juegos',
                                    style: TextStyle(
                                      fontSize:
                                          18, // Tamaño de fuente personalizado
                                      fontWeight: FontWeight
                                          .bold, // Estilo de fuente negrita
                                      color: Colors
                                          .blue, // Cambia el color del texto
                                    ),
                                  ),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Se superó la cantidad de juegos',
                                    style: TextStyle(
                                      fontSize:
                                          16, // Tamaño de fuente personalizado
                                      color: Colors
                                          .black87, // Cambia el color del texto
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Icon(
                                    Icons
                                        .check_circle_outline, // Cambia a un icono que desees
                                    color: Colors
                                        .green, // Cambia el color del icono
                                    size: 80,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, 'home');
                                  },
                                  child: Text('Aceptar'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          Navigator.pushReplacementNamed(context, 'mail');
                        }

                        // Volver al juego
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
                            child: const Center(
                              child: Text(
                                'Reintentar',
                                style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.white,
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
