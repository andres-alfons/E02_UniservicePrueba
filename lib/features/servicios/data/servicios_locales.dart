import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:uniservice/core/json.dart';
import 'package:uniservice/features/servicios/domain/servicio.dart';
import 'package:uniservice/features/servicios/domain/servicios_repository.dart';

/// Cómo se lee un archivo de texto. Se inyecta para poder probar sin assets.
typedef LectorDeAssets = Future<String> Function(String ruta);

class ServiciosLocales implements ServiciosRepository {
  /// El lector entra por el constructor. En producción es `rootBundle`; en
  /// las pruebas, una función que devuelve una cadena. Esa costura de dos
  /// líneas es lo que hace que las pruebas no necesiten ni Flutter ni el
  /// bundle.
  ServiciosLocales({
    LectorDeAssets? lector,
    this.ruta = 'assets/data/servicios.json',
  }) : _lector = lector ?? rootBundle.loadString;

  final LectorDeAssets _lector;
  final String ruta;

  /// El archivo no cambia mientras la app corre: leerlo y parsearlo en cada
  /// pantalla sería tirar trabajo a la basura.
  List<Servicio>? _cache;

  @override
  Future<List<Servicio>> obtenerTodos() async {
    final guardado = _cache;
    if (guardado != null) return guardado;

    final crudo = await _lector(ruta);
    final decodificado = jsonDecode(crudo);

    if (decodificado is! List) {
      throw const CampoInvalido(
          '(raíz)', 'el archivo debe contener una lista', null);
    }

    return _cache = decodificado
        .map((e) => Servicio.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Servicio?> obtenerPorId(String id) async {
    // firstWhere sin orElse lanza `Bad state: No element` cuando no encuentra.
    // Un bucle explícito devuelve null y se lee mejor que el orElse con truco.
    for (final servicio in await obtenerTodos()) {
      if (servicio.id == id) return servicio;
    }
    return null;
  }

  @override
  Future<List<Servicio>> buscarPorCategoria(String categoria) async {
    final todos = await obtenerTodos();
    return todos.where((s) => s.categoria == categoria).toList(growable: false);
  }
}
