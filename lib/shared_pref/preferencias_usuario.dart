
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PreferenciasUsuario {
  static final PreferenciasUsuario _instancia =
      PreferenciasUsuario._internal();

  factory PreferenciasUsuario() {
    return _instancia;
  }

  PreferenciasUsuario._internal();

  late SharedPreferences _prefs;
  String _versionApp = '';


  initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _versionApp = packageInfo.version;

  }

  
  get versionApp {
    return _versionApp;
  }

 int get tiempoJuego {
    return _prefs.getInt('tiempoJuego') ?? 60;
  }
  set tiempoJuego(int value) {
    _prefs.setInt('tiempoJuego', value);
  }

  int get dificultalJuego {
    return _prefs.getInt('dificultalJuego') ?? 1;
  }

  set dificultalJuego(int value) {
    _prefs.setInt('dificultalJuego', value);
  }

  bool get musica {
    return _prefs.getBool('musica') ?? true;
  }

  set musica(bool value) {
    _prefs.setBool('musica', value);
  }

  bool get sonido {
    return _prefs.getBool('sonido') ?? true;
  }

  set sonido(bool value) {
    _prefs.setBool('sonido', value);
  }

  String get emailMarketing {
    return _prefs.getString('emailMarketing') ?? '';
  }

  set emailMarketing(String value) {
    _prefs.setString('emailMarketing', value);
  }
  
  String get premios {
    return _prefs.getString('premios') ?? 'Lapicera,Vaso Termico,Sorpresa';
  }

  set premios(String value) {
    _prefs.setString('premios', value);
  }

  int get cantJuegos {
    return _prefs.getInt('cantJuegos') ?? 200;
  }

  set cantJuegos(int value) {
    _prefs.setInt('cantJuegos', value);
  }

  int get cantJuegosJugados {
    return _prefs.getInt('cantJuegosJugados') ?? 0;
  }

  set cantJuegosJugados(int value) {
    _prefs.setInt('cantJuegosJugados', value);
  }

  

  borrarPreferencias() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

}
