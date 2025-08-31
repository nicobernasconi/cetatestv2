import 'package:http/http.dart' as http;
import 'dart:convert';
import '../shared_pref/preferencias_usuario.dart';
import 'services.dart'; // Importa el servicio de juegos que ya has creado

class EnviarJuegosNoEnviadosService {
  final JuegosService juegosService = JuegosService();
  final String apiUrl =
      'https://gruposeic.com.ar/cetatest/api/enviar.php'; // Reemplaza con la URL de tu API REST

  Future<void> enviarJuegosNoEnviados() async {
    final prefs = PreferenciasUsuario();
    final String email = prefs.emailMarketing;
    try {
      // Obtén los juegos no enviados desde la base de datos
      List<Map<String, dynamic>> juegosNoEnviados =
          await juegosService.getJuegosNoEnviados();

          //obtenet lista un listado de juegos teniendo en cuenta las keys, nombre_juego, usuario, puntaje, tiempo, premio, fecha
          juegosNoEnviados=juegosNoEnviados.map((juego){
            return {
              'nombre_juego':juego['nombre_juego'],
              'usuario':juego['usuario'],
              'puntaje':juego['puntaje'],
              'tiempo':juego['tiempo'],
              'premio':juego['premio'],
              'fecha':juego['fecha'],
            };
          }).toList();

      final List<Map<String, dynamic>> data = [];
      data.add({
        'email': email,
        'juegos': juegosNoEnviados,
      });

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Si la solicitud se realizó con éxito, actualiza el estado del juego como enviado en la base de datos
        final responseBody = jsonDecode(response.body);
        if (responseBody['state'] == 'success') {
          await juegosService.updateAllJuegosEnviados();
        }
      }
    } catch (e) {
      print('Error al enviar juegos no enviados: $e');
    }
  }
}
