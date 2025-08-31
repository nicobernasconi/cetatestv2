import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cetatest/ui/colors_ui.dart';
import 'package:cetatest/shared_pref/preferencias_usuario.dart';
import '../providers/ui_provider.dart';
import '../ui/size_config.dart';
import '../services/services.dart';

class FinishScreen extends StatefulWidget {
  const FinishScreen({Key? key}) : super(key: key);
  @override
  State<FinishScreen> createState() => _FinishScreenState();
}

class _FinishScreenState extends State<FinishScreen> {
  final player = AudioPlayer();
  final prefs = PreferenciasUsuario();
  String premio = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await player.setVolume(prefs.sonido ? 1.0 : 0.0);
      await player.setSource(AssetSource('sounds/level-win.mp3'));
      await player.resume();
    });
    final lista = prefs.premios.split(',');
    if (lista.isNotEmpty) premio = lista[Random().nextInt(lista.length)];
  }

  @override
  Widget build(BuildContext context) {
  UIScale.init(context);
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final size = MediaQuery.of(context).size;
    final uiProvider = Provider.of<UIProvider>(context, listen: false);

  // Usamos UIScale.f para fuentes proporcionales.

    final marcadores = args['marcador'] as int? ?? 0;
    final tiempo = prefs.tiempoJuego - (args['tiempo'] as int? ?? 0);
    final intentos = args['intentos'] as int? ?? 0;
    final usuario = args['email'] as String? ?? '';
    final nombre = args['nombre'] as String? ?? '';
    final empresa = args['empresa'] as String? ?? '';
    final dificultad = prefs.dificultalJuego;
    final puntuacionFinal = (dificultad * (marcadores * (1000 - tiempo) / (intentos + 1))).toInt();

    return SafeArea(
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: ColoresApp.colorFondoGeneral,
          body: Padding(
            padding: EdgeInsets.only(top: size.height * 0.10, bottom: size.height * 0.07),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Tamaño fijo solicitado 275 px
                Image.asset('assets/images/logo_ceta.png', width: 275, fit: BoxFit.contain),
                Expanded(
                  child: Center(
                    child: Text('¡Ganaste!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                          fontSize: UIScale.fDown(108),
                          color: const Color(0xFFF47B30),
                        )),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    _mostrarPreparando(context);
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
                      'premio': premio,
                    };
                    await juegosService.insertJuego(nuevoJuego);
                    uiProvider.resetFlippedCards();
                    uiProvider.resetMarcador();
                    uiProvider.resetCardRemoved();
                    uiProvider.isGameWon = false;
                    if (prefs.cantJuegosJugados >= prefs.cantJuegos) {
                      prefs.cantJuegosJugados = 0;
                      if (mounted) {
                        Navigator.of(context).pop();
                        _mostrarLimite(context);
                      }
                    } else {
                      if (mounted) {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, 'mail');
                      }
                    }
                  },
                  child: Container(
                    // Mismo tamaño que el botón de Home
                    width: size.width * 0.3,
                    height: size.height * 0.06,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1b1e29),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(color: Color(0xFFEF8332), offset: Offset(0, 6)),
                      ],
                    ),
                    child: Center(
                      child: Text('Reintentar',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 24.0,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarPreparando(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: Row(children: const [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Text('Preparando el nuevo juego', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Se está preparando el nuevo juego', style: TextStyle(fontSize: 16, color: Colors.black87)),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void _mostrarLimite(BuildContext context) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Row(children: const [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Text('Se superó la cantidad de juegos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Se superó la cantidad de juegos', style: TextStyle(fontSize: 16, color: Colors.black87)),
            SizedBox(height: 20),
            Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, 'home'),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
