import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "juegos.db";
  static final _databaseVersion = 1;

  static final table = 'juegos';

  static final columnId = '_id';
  static final columnNombreJuego = 'nombre_juego';
  static final columnUsuario = 'usuario';
  static final columnNombre = 'nombre';
  static final columnEmpresa = 'empresa';
  static final columnPuntaje = 'puntaje';
  static final columnTiempo = 'tiempo';
  static final columnEnviado = 'enviado';
  static final columPremio = 'premio';
  static final columnFecha = 'fecha';

  // hacer que esta clase sea un singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // solo tener una referencia a la base de datos
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // inicializar la base de datos
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // crear la tabla "juegos"
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnNombreJuego TEXT NOT NULL,
            $columnUsuario TEXT NOT NULL,
            $columnNombre TEXT NOT NULL,
            $columnEmpresa TEXT NOT NULL,
            $columnPuntaje INTEGER NOT NULL,
            $columnTiempo INTEGER NOT NULL,
            $columnEnviado INTEGER NOT NULL,
            $columPremio TEXT NOT NULL,
            $columnFecha TEXT NOT NULL
          )
          ''');
  }

  // insertar un nuevo juego en la tabla "juegos"
  Future<int> insertJuego(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // obtener todos los juegos de la tabla "juegos"
  Future<List<Map<String, dynamic>>> queryAllJuegos() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // obtener un juego de la tabla "juegos" por su id
  Future<Map<String, dynamic>> queryJuego(int id) async {
    Database db = await instance.database;
    return (await db.query(table, where: '$columnId = ?', whereArgs: [id]))
        .first;
  }

  // obtener todos los juegos de la tabla "juegos" por su nombre
  Future<List<Map<String, dynamic>>> queryJuegosPorNombre(
      String nombreJuego) async {
    Database db = await instance.database;
    return await db
        .query(table, where: '$columnNombreJuego = ?', whereArgs: [nombreJuego]);
  }

  // actualizar un juego de la tabla "juegos" por su id
  Future<int> updateJuego(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db
        .update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // obtener juegos que no han sido enviados
  Future<List<Map<String, dynamic>>> queryJuegosNoEnviados() async {
    Database db = await instance.database;
    return await db.query(table, where: '$columnEnviado = ?', whereArgs: [0]);
  }

  // actualizar el estado de un juego a enviado
  Future<int> updateJuegoEnviado(int id) async {
    Database db = await instance.database;
    return await db.rawUpdate(
        'UPDATE $table SET $columnEnviado = 1 WHERE $columnId = $id');
  }

  //actualizar el estado de todos los juegos a enviado
  Future<int> updateAllJuegosEnviados() async {
    Database db = await instance.database;
    return await db.rawUpdate('UPDATE $table SET $columnEnviado = 1');
  }


//eliminar un juego de la tabla "juegos" por su id
  Future<int> deleteJuego(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  //eliminar todos los juegos de la tabla "juegos"
  Future<int> deleteAllJuegos() async {
    Database db = await instance.database;
    return await db.delete(table);
  }


}