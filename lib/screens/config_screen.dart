import 'package:cetatest/shared_pref/preferencias_usuario.dart';
import 'package:cetatest/ui/colors_ui.dart';
import 'package:flutter/material.dart';

import '../services/services.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({Key? key, Key? superKey}) : super(key: superKey);

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  PreferenciasUsuario prefs = PreferenciasUsuario();
  int gameTime = 60;
  int difficulty = 1;
  bool music = true;
  bool sound = true;
  String email = '';
  String premios = ''; // Campo de premios
  int cantidadJuegos = 0; // Nuevo campo para la cantidad de juegos

  @override
  void initState() {
    gameTime = prefs.tiempoJuego;
    difficulty = prefs.dificultalJuego;
    music = prefs.musica;
    sound = prefs.sonido;
    email = prefs.emailMarketing;
    premios = prefs.premios; // Obtener los premios guardados
    cantidadJuegos =
        prefs.cantJuegos; // Obtener la cantidad de juegos
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColoresApp.colorFondoGeneral,
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: ColoresApp.colorSecundario,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: size.height * 0.06),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: <Widget>[
            Container(
              color: ColoresApp.colorFondoGeneral,
              padding: EdgeInsets.all(size.width * 0.05),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                      buildConfigItem(
                        "Correo Electrónico:",
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                initialValue: email,
                                onChanged: (value) {
                                  setState(() => email = value);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Ingresa el correo electrónico de marketing',
                                  hintStyle: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFf47b30),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: const BorderSide(color: Colors.transparent),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                    borderSide: const BorderSide(color: Colors.white70, width: 1),
                                  ),
                                  suffixIcon: const Icon(Icons.email, color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(width: size.width * 0.02),
                            ElevatedButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      const AlertDialog(
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
                                          'Enviando informacion',
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
                                          'Se está preparando el envio de la información\npor favor espere',
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

                                await EnviarJuegosNoEnviadosService()
                                    .enviarJuegosNoEnviados();

                                Navigator.pop(context);
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        ColoresApp.colorFondoImagenes),
                              ),
                              child: Text(
                                'Enviar',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: ColoresApp.colorPrimario,
                                ),
                              ),
                            ),
                          ],
                        ),
                        size,
                      ),
                      buildConfigItem(
                        "Premios:", // Etiqueta para el campo de premios
                        TextFormField(
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          initialValue: premios,
                          onChanged: (value) => setState(() => premios = value),
                          decoration: InputDecoration(
                            hintText: 'Ingresa los premios',
                            hintStyle: const TextStyle(fontSize: 18, color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFFf47b30),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: const BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: const BorderSide(color: Colors.white70, width: 1),
                            ),
                            suffixIcon: const Icon(Icons.star, color: Colors.white),
                          ),
                        ),
                        size,
                      ),
                      buildConfigItem(
                        "Tiempo del juego (segundos):",
                        TextFormField(
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          initialValue: gameTime.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => setState(() => gameTime = int.tryParse(value) ?? 0),
                          decoration: InputDecoration(
                            hintText: 'Ingresa el tiempo del juego en segundos',
                            hintStyle: const TextStyle(fontSize: 18, color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFFf47b30),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: const BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: const BorderSide(color: Colors.white70, width: 1),
                            ),
                            suffixIcon: const Icon(Icons.timer, color: Colors.white),
                          ),
                        ),
                        size,
                      ),
                      buildConfigItem(
                        "Dificultad:",
                        DropdownButton<int>(
                          value: difficulty,
                          onChanged: (value) {
                            setState(() {
                              difficulty = value!;
                            });
                          },
                          items: [1, 2, 3, 4].map<DropdownMenuItem<int>>(
                            (int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(
                                  'Nivel $value',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: ColoresApp.colorSecundario,
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                        size,
                      ),
                      buildConfigItem(
                        "Sonido y Música:",
                        Row(
                          children: [
                           const Icon(
                              Icons.volume_up,
                              color: Colors.white,
                            ),
                            SizedBox(width: size.width * 0.05),
                            Switch(
                              value: sound,
                              onChanged: (value) {
                                setState(() {
                                  sound = value;
                                });
                              },
                              activeColor: Colors.blue,
                            ),
                            SizedBox(width: size.width * 0.05),
                            Icon(
                              Icons.music_note,
                              color: Colors.white,
                            ),
                            SizedBox(width: size.width * 0.02),
                            Switch(
                              value: music,
                              onChanged: (value) {
                                setState(() {
                                  music = value;
                                });
                              },
                              activeColor: Colors.blue,
                            ),
                          ],
                        ),
                        size,
                      ),
                      buildConfigItem(
                        "Cantidad de Juegos:",
                        TextFormField(
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          initialValue: cantidadJuegos.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => setState(() => cantidadJuegos = int.tryParse(value) ?? 0),
                          decoration: InputDecoration(
                            hintText: 'Ingresa la cantidad de juegos',
                            hintStyle: const TextStyle(fontSize: 18, color: Colors.white70),
                            filled: true,
                            fillColor: const Color(0xFFf47b30),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: const BorderSide(color: Colors.transparent),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                              borderSide: const BorderSide(color: Colors.white70, width: 1),
                            ),
                            suffixIcon: const Icon(Icons.gamepad, color: Colors.white),
                          ),
                        ),
                        size,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              margin: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              decoration: BoxDecoration(
                color: ColoresApp.colorPrimario,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                _ConfigActionButton(
                  label: 'Volver',
                  onTap: () => Navigator.pushReplacementNamed(context, 'home'),
                  size: size,
                ),
                _ConfigActionButton(
                  label: 'Guardar',
                  onTap: () {
                    prefs.tiempoJuego = gameTime;
                    prefs.dificultalJuego = difficulty;
                    prefs.musica = music;
                    prefs.sonido = sound;
                    prefs.emailMarketing = email;
                    prefs.premios = premios;
                    prefs.cantJuegos = cantidadJuegos;
                    Navigator.pushReplacementNamed(context, 'home');
                  },
                  size: size,
                ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildConfigItem(String title, Widget widget, Size size) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: size.height * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          SizedBox(
            width: size.width * 0.05,
          ),
          Expanded(
            child: widget,
          ),
        ],
      ),
    );
  }
}

class _ConfigActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Size size;
  const _ConfigActionButton({required this.label, required this.onTap, required this.size});

  @override
  Widget build(BuildContext context) {
    // Coincide con estilo de MailScreen: contenedor oscuro con sombra naranja
    final buttonWidth = size.width * 0.30;
    final buttonHeight = size.height * 0.06;
    return MaterialButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        width: buttonWidth.clamp(140, 320),
        height: buttonHeight.clamp(42, 70),
        decoration: const BoxDecoration(
          color: Color(0xFF1b1e29),
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(color: Color(0xFFEF8332), offset: Offset(0, 6)),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
