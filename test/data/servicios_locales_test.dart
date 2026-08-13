import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:uniservice/core/json.dart';
import 'package:uniservice/features/servicios/data/servicios_locales.dart';

const _json = '''
[
  {
    "id": "srv-001",
    "titulo": "Tutoría de Cálculo Diferencial",
    "descripcion": "Refuerzo semanal con talleres resueltos.",
    "categoria": "Tutoría",
    "oferenteId": "est-087",
    "precioBase": { "monto": 25000, "moneda": "COP" },
    "creadoEn": "2026-08-05T14:00:00Z",
    "estado": { "tipo": "borrador" }
  },
  {
    "id": "srv-002",
    "titulo": "Diseño de logo",
    "descripcion": "Identidad visual básica.",
    "categoria": "Diseño",
    "oferenteId": "est-203",
    "precioBase": { "monto": 40000, "moneda": "COP" },
    "creadoEn": "2026-08-01T10:00:00Z",
    "estado": { "tipo": "borrador" }
  }
]
''';

void main() {
  test('lee la lista completa del archivo', () async {
    final repo = ServiciosLocales(lector: (_) async => _json);
    expect((await repo.obtenerTodos()).length, 2);
  });

  test('busca por id y devuelve null cuando no está', () async {
    final repo = ServiciosLocales(lector: (_) async => _json);

    expect((await repo.obtenerPorId('srv-001'))?.titulo,
        'Tutoría de Cálculo Diferencial');
    expect(await repo.obtenerPorId('no-existe'), isNull);
  });

  test('filtra por categoría', () async {
    final repo = ServiciosLocales(lector: (_) async => _json);
    final resultado = await repo.buscarPorCategoria('Diseño');

    expect(resultado, hasLength(1));
    expect(resultado.single.id, 'srv-002');
  });

  test('un archivo que no es una lista se rechaza', () async {
    final repo = ServiciosLocales(lector: (_) async => '{"a": 1}');
    expect(repo.obtenerTodos(), throwsA(isA<CampoInvalido>()));
  });

  test('el asset declarado en pubspec existe y el modelo lo entiende',
      () async {
    // Esta SÍ toca el bundle: es la única que caza "olvidé el pubspec".
    TestWidgetsFlutterBinding.ensureInitialized();

    final repo = ServiciosLocales(lector: rootBundle.loadString);
    expect((await repo.obtenerTodos()).length, greaterThanOrEqualTo(3));
  });
}
