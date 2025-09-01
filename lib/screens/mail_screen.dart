import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cetatest_v2/ui/colors_ui.dart';
import '../ui/size_config.dart';
import '../shared_pref/preferencias_usuario.dart';

class MailScreen extends StatefulWidget {
  const MailScreen({Key? key}) : super(key: key);
  @override
  State<MailScreen> createState() => _MailScreenState();
}

class _MailScreenState extends State<MailScreen> {
  final _nombreController = TextEditingController();
  final _empresaController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEmailValid = false;
  final prefs = PreferenciasUsuario();

  @override
  void dispose() {
    _nombreController.dispose();
    _empresaController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail(String v) {
    final r = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    setState(() => _isEmailValid = r.hasMatch(v));
  }

  Future<void> _continue(BuildContext context) async {
    if (!_isEmailValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Correo inválido.')));
      return;
    }
    final audioPlayer = AudioPlayer();
    await audioPlayer.setVolume(prefs.sonido ? 1.0 : 0.0);
    audioPlayer.setSource(AssetSource('sounds/game-start.mp3')).then((_) => audioPlayer.resume());
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, 'game', arguments: {
      'nombre': _nombreController.text,
      'empresa': _empresaController.text,
      'email': _emailController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    UIScale.init(context);
    final size = MediaQuery.of(context).size;
    const baseHeight = 900.0;
    final scaleDown = (size.height / baseHeight).clamp(0.6, 1.0);
    final logoTop = size.height * 0.03 * scaleDown;
    final afterLogo = size.height * 0.10 * scaleDown;
    final gapField = size.height * 0.08 * scaleDown;
    final paddingH = size.width * 0.2;
    final fieldFont = UIScale.fDown(29);
    final warningFont = UIScale.fDown(16);

    List<Widget> children = [
      SizedBox(height: logoTop),
      Image.asset('assets/images/logo_ceta.png', width: 275),
      SizedBox(height: afterLogo),
      _field(paddingH, _nombreController, 'Nombre:', fieldFont),
      SizedBox(height: gapField),
      _field(paddingH, _empresaController, 'Empresa:', fieldFont),
      SizedBox(height: gapField),
      _field(paddingH, _emailController, 'Mail:', fieldFont, onChanged: _validateEmail, onSubmitted: (_) => _continue(context), keyboardType: TextInputType.emailAddress),
      if (_emailController.text.isNotEmpty && !_isEmailValid)
        Padding(
          padding: EdgeInsets.only(top: UIScale.h(8)),
          child: Text('Ingrese un correo electrónico válido', style: TextStyle(fontSize: warningFont, color: Colors.black)),
        ),
      SizedBox(height: gapField),
      MaterialButton(
        onPressed: () => _continue(context),
        child: Container(
          width: size.width * 0.3,
          height: size.height * 0.06,
          decoration: const BoxDecoration(
            color: Color(0xFF1b1e29),
            borderRadius: BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Color(0xFFEF8332), offset: Offset(0, 6)),
            ],
          ),
          child: const Center(
            child: Text('Jugar', style: TextStyle(fontSize: 24.0, color: Colors.white)),
          ),
        ),
      ),
      SizedBox(height: gapField),
    ];

    final content = Column(mainAxisSize: MainAxisSize.min, children: children);

    return Scaffold(
      backgroundColor: ColoresApp.colorFondoGeneral,
      // Evita reconstrucciones con diferente jerarquía cuando cambia la altura por el teclado.
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(child: content),
        ),
      ),
    );
  }

  Widget _field(double paddingH, TextEditingController controller, String hint, double fontSize,
      {void Function(String)? onChanged, void Function(String)? onSubmitted, TextInputType? keyboardType}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingH),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: fontSize),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white70, fontSize: fontSize),
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
        ),
      ),
    );
  }
}
