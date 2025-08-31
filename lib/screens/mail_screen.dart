import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cetatest/ui/colors_ui.dart'; // Asumo que este archivo existe y es necesario

import '../services/services.dart';
import '../shared_pref/preferencias_usuario.dart';

class MailScreen extends StatefulWidget {
  const MailScreen({Key? key}) : super(key: key);

  @override
  _MailScreenState createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  // Controladores para todos los campos
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isEmailValid = false;
  final prefs = PreferenciasUsuario();

  @override
  void initState() {
    super.initState();
    // Podrías inicializar los controllers con valores de prefs si fuera necesario
    // _nombreController.text = prefs.nombreGuardado ?? ''; // Ejemplo
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _empresaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    setState(() {
      _isEmailValid = emailRegExp.hasMatch(email);
    });
  }

  Future<void> _continueIfValidEmail(BuildContext context) async {
    // Opcional: podrías agregar validación para nombre y empresa aquí si son obligatorios
    // final nombre = _nombreController.text.trim();
    // final empresa = _empresaController.text.trim();
    // if (nombre.isEmpty || empresa.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Por favor, completa todos los campos.')),
    //   );
    //   return;
    // }

    if (_isEmailValid) {
      final audioPlayer = AudioPlayer();
      final juegosService = JuegosService();
      if (prefs.sonido) {
        await audioPlayer.setVolume(1.0);
      } else {
        await audioPlayer.setVolume(0.0);
      }
      // Es buena práctica no bloquear la UI con setSource si no es necesario esperar
      // el resultado inmediato para la navegación.
      audioPlayer.setSource(AssetSource('sounds/game-start.mp3')).then((_) {
        audioPlayer.resume();
      }).catchError((error) {
        // Manejar error al cargar el sonido si es necesario
        print("Error al cargar el sonido: $error");
      });

      final todosLosJuegos = await juegosService.getAllJuegos();
      print(todosLosJuegos);

      // Aquí guardas los valores en PreferenciasUsuario si lo deseas

      // Espera un poco para que el sonido pueda empezar a reproducirse
      await Future.delayed(const Duration(milliseconds: 500));

      Navigator.pushReplacementNamed(context, 'game', arguments: {
        'nombre': _nombreController.text, // Añadido
        'empresa': _empresaController.text, // Añadido
        'email': _emailController.text,
      });
    } else {
      // Mostrar un mensaje si el email no es válido y se intenta continuar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, ingresa un correo electrónico válido.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ColoresApp.colorFondoGeneral,
      body: SingleChildScrollView(
        child: Container(
          height: size.height < 600 ? null : size.height,
          color: ColoresApp.colorFondoGeneral,
          child: Center(
            child: Padding(
              // Añadido Padding general para evitar que el teclado cubra todo
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  SizedBox(height: size.height * 0.03),
                  Image.asset(
                    'assets/images/logo_ceta.png',
                    width: 275, // Reducido un poco para más espacio
                  ),
                  SizedBox(height: size.height * 0.1),

                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                            size.width * 0.2), // Reducido padding horizontal
                    child: TextField(
                      controller: _nombreController,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 29),
                      decoration: InputDecoration(
                        hintText: 'Nombre:',
                        hintStyle: const TextStyle(
                            color: Colors.white70, fontSize: 29),
                        filled: true,
                        fillColor: const Color(0xFFf47b30),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide:
                              const BorderSide(color: Colors.white70, width: 1),
                        ),
                      ),

                      // onChanged: (value) {
                      //   // No es necesario si usas el controller, a menos que quieras validación en tiempo real
                      // },
                    ),
                  ),
                  SizedBox(height: size.height * 0.08),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.2),
                    child: TextField(
                      controller: _empresaController,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 29),
                      decoration: InputDecoration(
                        hintText: 'Empresa:',
                        hintStyle: const TextStyle(
                            color: Colors.white70, fontSize: 29),
                        filled: true,
                        fillColor: const Color(0xFFf47b30),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide:
                              const BorderSide(color: Colors.white70, width: 1),
                        ),
                      ),

                      // onChanged: (value) {
                      //   // No es necesario si usas el controller
                      // },
                    ),
                  ),
                  SizedBox(height: size.height * 0.08),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.2),
                    child: TextField(
                      controller: _emailController,
                      onChanged: _validateEmail,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 29),
                      onSubmitted: (_) => _continueIfValidEmail(context),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Mail:',
                        hintStyle: const TextStyle(
                            color: Colors.white70, fontSize: 29),
                        filled: true,
                        fillColor: const Color(0xFFf47b30),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 2),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide:
                              const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40),
                          borderSide:
                              const BorderSide(color: Colors.white70, width: 1),
                        ),
                      ),
                    ),
                  ),
                  // Mantenemos el mensaje de validación si prefieres este estilo
                  if (_emailController.text.isNotEmpty && !_isEmailValid)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Ingrese un correo electrónico válido',
                        style: TextStyle(
                          fontSize: size.height * 0.018, // Ajustado tamaño
                          color: Colors.orangeAccent, // Un color de advertencia
                        ),
                      ),
                    ),
                  SizedBox(
                      height: size.height *
                          0.08), // Un poco más de espacio antes del botón

                  MaterialButton(
                      onPressed: () {
                        _continueIfValidEmail(context);
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
                              offset: Offset(0, 6), // desplazamiento vertical
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Jugar',
                            style: TextStyle(
                              fontSize: 24.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
