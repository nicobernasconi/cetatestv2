import 'package:audioplayers/audioplayers.dart';
import 'package:cetatest/ui/colors_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  final player = AudioPlayer();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Reproduce el sonido después de que el widget se haya construido
        await player.dispose();
    });
  }
  @override
  Widget build(BuildContext context) {
    final uiProvider = Provider.of<UIProvider>(context);

    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColoresApp.colorFondoGeneral,
      appBar: AppBar(
        backgroundColor: Colors.black,
        //boton de configuracion
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'config');
              },
              icon: const Icon(
                Icons.settings,
                size: 30,
                color: Colors.white,
              ))
        ],
      ),
      body: Center(
        child: Container(
            width: size.width,
            height: size.height,
            color: ColoresApp.colorFondoGeneral,
            child: DefaultTextStyle(
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500, // Medium
                color: Colors.black,
              ),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(top: size.height * 0.1),
                  child: Image.asset(
                    'assets/images/logo_ceta.png',
                    width: size.width * 0.5,
                  ),
                ),
                Expanded(child: Container()),
                MaterialButton(
                  onPressed: () {
                    uiProvider.resetFlippedCards();
                    uiProvider.resetMarcador();
                    uiProvider.resetCardRemoved();
                    uiProvider.isGameWon = false;
                    Navigator.pushReplacementNamed(context, 'mail');
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
                    child: Center(
                      child: Text(
                        'Jugar',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 24.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )),
                SizedBox(
                  height: size.height * 0.1,
                )
              ],
              ),
            ),
        ),
      ),
    );
  }
}
