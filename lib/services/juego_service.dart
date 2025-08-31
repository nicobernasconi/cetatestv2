import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../db/db.dart';
// Asegúrate de importar el archivo DatabaseHelper

class JuegosService {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  // Método para insertar un nuevo juego en la base de datos
  Future<int> insertJuego(Map<String, dynamic> juegoData) async {
    return await dbHelper.insertJuego(juegoData);
  }

  // Método para obtener todos los juegos de la base de datos
  Future<List<Map<String, dynamic>>> getAllJuegos() async {
    return await dbHelper.queryAllJuegos();
  }

  // Método para obtener un juego por su ID
  Future<Map<String, dynamic>> getJuegoById(int id) async {
    return await dbHelper.queryJuego(id);
  }

  // Método para obtener juegos por su nombre
  Future<List<Map<String, dynamic>>> getJuegosByNombre(String nombreJuego) async {
    return await dbHelper.queryJuegosPorNombre(nombreJuego);
  }

  // Método para actualizar un juego
  Future<int> updateJuego(Map<String, dynamic> juegoData) async {
    return await dbHelper.updateJuego(juegoData);
  }

  // Método para eliminar un juego
  Future<int> deleteJuego(int id) async {
    return await dbHelper.deleteJuego(id);
  }

  // Método para obtener juegos que no han sido enviados
  Future<List<Map<String, dynamic>>> getJuegosNoEnviados() async {
    return await dbHelper.queryJuegosNoEnviados();
  }

  // Método para actualizar el estado de un juego a enviado
  Future<int> updateJuegoEnviado(int id) async {
    return await dbHelper.updateJuegoEnviado(id);
  }

  // Método para eliminar todos los juegos
  Future<int> deleteAllJuegos() async {
    return await dbHelper.deleteAllJuegos();
  }

  // Método para actualizar el estado de todos los juegos a enviado
  Future<int> updateAllJuegosEnviados() async {
    return await dbHelper.updateAllJuegosEnviados();
  }

}