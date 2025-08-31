import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'providers/providers.dart';
import 'screens/screens.dart';
import 'shared_pref/preferencias_usuario.dart';
import 'package:provider/provider.dart';

import 'ui/colors_ui.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  final prefs = PreferenciasUsuario();
  await prefs.initPrefs();

  runApp(const AppState());
}

class AppState extends StatelessWidget {
  const AppState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UIProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: ColoresApp.colorSecundario),
      scaffoldBackgroundColor: ColoresApp.colorFondoGeneral,
      appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ColoresApp.colorSecundario,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(fontSize: 12),
      ),
    );

    return MaterialApp(
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(baseTheme.textTheme),
      ),
      debugShowCheckedModeBanner: false,

  title: 'CetaTest',
      //initialRoute: 'inicio',
      routes: {
        'home': (context) => const HomeScreen(),
        'game': (context) => const GameScreen(),
        'finish': (context) => const FinishScreen(),
        'fail': (context) => const FailScreen(),
        'config': (context) => const ConfigScreen(),
        'mail': (context) => const MailScreen(),

      },
      home: const HomeScreen(),
    );
  }
}
