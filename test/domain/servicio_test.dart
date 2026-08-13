import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:uniservice/core/json.dart';
import 'package:uniservice/features/servicios/domain/estado_servicio.dart';
import 'package:uniservice/features/servicios/domain/precio.dart';
import 'package:uniservice/features/servicios/domain/servicio.dart';

Servicio ejemplo({EstadoServicio? estado, List<String>? palabrasClave}) =>
    Servicio(
      id: 'srv-001',
      titulo: 'Tutoría de Cálculo Diferencial',
      descripcion: 'Refuerzo semanal con talleres resueltos.',
      categoria: 'Tutoría',
      oferenteId: 'est-087',
      precioBase: const Precio(monto: 25000, moneda: 'COP'),
      creadoEn: DateTime.utc(2026, 8, 5, 14, 0),
      estado: estado ?? const Borrador(),
      palabrasClave: palabrasClave ?? const <String>[],
    );

void main() {
  group('serialización', () {
    test('un servicio sobrevive la ida y vuelta a JSON sin perder nada', () {
      final original = ejemplo(
        estado: Publicado(DateTime.utc(2026, 8, 5, 14, 10)),
        palabrasClave: const ['cálculo', 'matemáticas'],
      );

      // Pasa por TEXTO, no solo por Map: así también se prueba que las
      // fechas y las listas sobreviven a jsonEncode.
      final texto = jsonEncode(original.toJson());
      final vuelta =
          Servicio.fromJson(jsonDecode(texto) as Map<String, dynamic>);

      expect(vuelta, equals(original));
    });

    test('un servicio sin la clave palabrasClave se lee con la lista vacía',
        () {
      final json = ejemplo().toJson()..remove('palabrasClave');
      expect(Servicio.fromJson(json).palabrasClave, isEmpty);
    });

    test('un servicio sin título dice QUÉ campo falló, no solo que falló', () {
      final json = ejemplo().toJson()..remove('titulo');

      expect(
        () => Servicio.fromJson(json),
        throwsA(isA<CampoInvalido>().having((e) => e.campo, 'campo', 'titulo')),
      );
    });

    test('una fecha que no es ISO 8601 se rechaza', () {
      final json = ejemplo().toJson()..['creadoEn'] = '5 de agosto';
      expect(() => Servicio.fromJson(json), throwsA(isA<CampoInvalido>()));
    });

    test('la hora se conserva en UTC y no se corre cinco horas', () {
      final json = ejemplo().toJson();
      expect(json['creadoEn'], '2026-08-05T14:00:00.000Z');
    });
  });

  group('igualdad', () {
    test('dos servicios con los mismos datos son iguales', () {
      expect(ejemplo(), equals(ejemplo()));
    });

    test('dos servicios con los mismos datos comparten hashCode', () {
      // Sin esto, meterlos en un Set daría dos elementos donde debería
      // haber uno.
      expect(ejemplo().hashCode, equals(ejemplo().hashCode));
      expect({ejemplo(), ejemplo()}.length, 1);
    });

    test('dos servicios con palabras clave distintas NO son iguales', () {
      expect(
        ejemplo(palabrasClave: const ['a']),
        isNot(equals(ejemplo(palabrasClave: const ['b']))),
      );
    });

    test('copyWith cambia solo lo que se le pasa', () {
      final original = ejemplo();
      final copia = original.copyWith(titulo: 'Otro título');

      expect(copia.titulo, 'Otro título');
      expect(copia.id, original.id);
      expect(copia.oferenteId, original.oferenteId);
      expect(copia.creadoEn, original.creadoEn);
    });
  });

  group('reglas de negocio', () {
    test('un servicio contratado ya no se puede editar', () {
      final estado = Contratado(
        'est-114',
        const Precio(monto: 35000, moneda: 'COP'),
        DateTime.utc(2026, 8, 3, 9),
      );
      expect(ejemplo(estado: estado).sePuedeEditar, isFalse);
    });

    test('un servicio en borrador sí se puede editar', () {
      expect(ejemplo(estado: const Borrador()).sePuedeEditar, isTrue);
    });

    test('solo un servicio publicado está disponible', () {
      expect(ejemplo(estado: const Borrador()).estaDisponible, isFalse);
      expect(
        ejemplo(estado: Publicado(DateTime.utc(2026, 8, 5))).estaDisponible,
        isTrue,
      );
    });

    test('un servicio publicado hace 40 días está vencido', () {
      final ahora = DateTime.utc(2026, 9, 20);
      final publicadoHaceTiempo = ejemplo(
        estado: Publicado(DateTime.utc(2026, 8, 5, 14, 10)),
      );
      expect(publicadoHaceTiempo.estaVencido(ahora), isTrue);
    });

    test('la etiqueta de un servicio cancelado incluye el motivo', () {
      expect(
        const Cancelado('El oferente no llegó a tiempo.').etiqueta,
        contains('no llegó a tiempo'),
      );
    });
  });
}
