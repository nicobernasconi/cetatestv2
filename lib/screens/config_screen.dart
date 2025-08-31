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
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Container(
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
                                style: TextStyle(
                                  fontSize: 18,
                                  color: ColoresApp.colorSecundario,
                                ),
                                initialValue: email,
                                onChanged: (value) {
                                  setState(() {
                                    email = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      'Ingresa el correo electrónico de marketing',
                                  hintStyle: TextStyle(
                                    fontSize: 18,
                                    color: ColoresApp.colorSecundario,
                                  ),
                                  suffixIcon: Icon(
                                    Icons.email,
                                    color: ColoresApp.colorFondoImagenes,
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: 18,
                                    color: ColoresApp.colorSecundario,
                                  ),
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
                          style: TextStyle(
                            fontSize: 18,
                            color: ColoresApp.colorSecundario,
                          ),
                          initialValue: premios,
                          onChanged: (value) {
                            setState(() {
                              premios = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Ingresa los premios',
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: ColoresApp.colorSecundario,
                            ),
                            suffixIcon: Icon(
                              Icons.star,
                              color: ColoresApp.colorFondoImagenes,
                            ),
                            labelStyle: TextStyle(
                              fontSize: 18,
                              color: ColoresApp.colorSecundario,
                            ),
                          ),
                        ),
                        size,
                      ),
                      buildConfigItem(
                        "Tiempo del juego (segundos):",
                        TextFormField(
                          style: TextStyle(
                            fontSize: 18,
                            color: ColoresApp.colorSecundario,
                          ),
                          initialValue: gameTime.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              gameTime = int.tryParse(value) ?? 0;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Ingresa el tiempo del juego en segundos',
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: ColoresApp.colorSecundario,
                            ),
                            suffixIcon: Icon(
                              Icons.timer,
                              color: ColoresApp.colorFondoImagenes,
                            ),
                            labelStyle: TextStyle(
                              fontSize: 18,
                              color: ColoresApp.colorSecundario,
                            ),
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
                          style: TextStyle(
                            fontSize: 18,
                            color: ColoresApp.colorSecundario,
                          ),
                          initialValue: cantidadJuegos.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              cantidadJuegos = int.tryParse(value) ?? 0;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Ingresa la cantidad de juegos',
                            hintStyle: TextStyle(
                              fontSize: 18,
                              color: ColoresApp.colorSecundario,
                            ),
                            suffixIcon: Icon(
                              Icons.gamepad,
                              color: ColoresApp.colorFondoImagenes,
                            ),
                            labelStyle: TextStyle(
                              fontSize: 18,
                              color: ColoresApp.colorSecundario,
                            ),
                          ),
                        ),
                        size,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: ColoresApp.colorPrimario,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                MaterialButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, 'home');
                  },
                  color: ColoresApp.colorSecundario,
                  child: Text(
                    'Volver',
                    style: TextStyle(
                      fontSize: (size.height * 0.05),
                      color: ColoresApp.colorFondoImagenes,
                    ),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    prefs.tiempoJuego = gameTime;
                    prefs.dificultalJuego = difficulty;
                    prefs.musica = music;
                    prefs.sonido = sound;
                    prefs.emailMarketing = email;
                    prefs.premios = premios; // Guardar los premios
                    prefs.cantJuegos = 
                        cantidadJuegos; // Guardar la cantidad de juegos
                    Navigator.pushReplacementNamed(context, 'home');
                  },
                  color: ColoresApp.colorFondoImagenes,
                  child: Text(
                    'Guardar',
                    style: TextStyle(
                      fontSize: (size.height * 0.05),
                      color: ColoresApp.colorPrimario,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
