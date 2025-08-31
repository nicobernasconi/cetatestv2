import 'package:flutter/widgets.dart';

/// Utilidad global para escalar tamaños (fuentes / dimensiones) según la pantalla.
/// Basado en un layout de referencia con shortestSide = 400 y longestSide = 800.
class UIScale {
  static double _scale = 1.0; // factor uniforme usando shortestSide
  static double _scaleW = 1.0; // factor respecto al ancho
  static double _scaleH = 1.0; // factor respecto al alto
  static Size _size = const Size(0, 0);

  static const double _baseShortest = 400; // teléfono vertical típico
  static const double _baseWidth = 800;    // referencia aproximada landscape
  static const double _baseHeight = 480;   // referencia paisaje (16:10 ~)

  static void init(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;
    if (size == _size) return; // evita recalcular
    _size = size;
    final shortest = size.shortestSide;
    _scale = (shortest / _baseShortest).clamp(0.6, 2.4);
    _scaleW = (size.width / _baseWidth).clamp(0.6, 2.4);
    _scaleH = (size.height / _baseHeight).clamp(0.6, 2.4);
  }

  /// Escala uniforme (útil para fuentes)
  static double f(double v) => v * _scale;
  /// Escala solo hacia abajo: mantiene tamaño base en pantallas iguales o más grandes,
  /// reduce proporcionalmente en pantallas pequeñas.
  static double fDown(double v) => _scale < 1 ? v * _scale : v;
  /// Escala a partir del ancho
  static double w(double v) => v * _scaleW;
  /// Escala a partir del alto
  static double h(double v) => v * _scaleH;

  /// Limita un valor entre min y max tras escalar
  static double clamp(double value, double min, double max) => value.clamp(min, max);
}
