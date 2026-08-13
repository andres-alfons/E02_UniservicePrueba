import 'package:uniservice/core/comparaciones.dart';
import 'package:uniservice/core/json.dart';
import 'package:uniservice/features/servicios/domain/estado_servicio.dart';
import 'package:uniservice/features/servicios/domain/precio.dart';

/// Un servicio publicado por un estudiante en UniService.
///
/// Es una **entidad**: tiene identidad propia. Dos servicios con el mismo
/// título son dos servicios distintos si tienen `id` distinto.
class Servicio {
  const Servicio({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.oferenteId,
    required this.precioBase,
    required this.creadoEn,
    required this.estado,
    this.palabrasClave = const <String>[],
  });

  factory Servicio.fromJson(Map<String, dynamic> json) => Servicio(
        id: leerTexto(json, 'id'),
        titulo: leerTexto(json, 'titulo'),
        descripcion: leerTexto(json, 'descripcion'),
        categoria: leerTexto(json, 'categoria'),
        oferenteId: leerTexto(json, 'oferenteId'),
        precioBase: Precio.fromJson(leerMapa(json, 'precioBase')),
        creadoEn: leerFecha(json, 'creadoEn'),
        estado: EstadoServicio.fromJson(leerMapa(json, 'estado')),
        palabrasClave: leerTextos(json, 'palabrasClave'),
      );

  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String oferenteId;
  final Precio precioBase;
  final DateTime creadoEn;
  final EstadoServicio estado;
  final List<String> palabrasClave;

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'categoria': categoria,
        'oferenteId': oferenteId,
        'precioBase': precioBase.toJson(),
        'creadoEn': creadoEn.toUtc().toIso8601String(),
        'estado': estado.toJson(),
        'palabrasClave': palabrasClave,
      };

  // ── Reglas de negocio ───────────────────────────────────────────────────
  // Viven aquí, no en el widget. Un widget no se puede probar en 3 ms.

  bool get tienePalabrasClave => palabrasClave.isNotEmpty;

  bool get sePuedeEditar => estado.sePuedeEditar;

  bool get estaDisponible => estado.estaDisponible;

  /// El reloj entra como parámetro, no se lee dentro.
  ///
  /// Con `DateTime.now()` dentro, esta regla no se puede probar: el
  /// resultado depende del día en que se corra la prueba.
  Duration antiguedad(DateTime ahora) => ahora.difference(creadoEn);

  /// Un servicio publicado hace más de 30 días sin contratar se considera
  /// desactualizado: probablemente el precio o la disponibilidad cambiaron.
  bool estaVencido(DateTime ahora) =>
      estado is Publicado && antiguedad(ahora) > const Duration(days: 30);

  // ── Copia ───────────────────────────────────────────────────────────────

  Servicio copyWith({
    String? titulo,
    String? descripcion,
    String? categoria,
    Precio? precioBase,
    EstadoServicio? estado,
    List<String>? palabrasClave,
  }) =>
      Servicio(
        id: id, // la identidad NO se copia con cambios
        titulo: titulo ?? this.titulo,
        descripcion: descripcion ?? this.descripcion,
        categoria: categoria ?? this.categoria,
        oferenteId: oferenteId, // el oferente tampoco cambia con una copia
        precioBase: precioBase ?? this.precioBase,
        creadoEn: creadoEn, // ni la fecha de creación
        estado: estado ?? this.estado,
        palabrasClave: palabrasClave ?? this.palabrasClave,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Servicio &&
          other.id == id &&
          other.titulo == titulo &&
          other.descripcion == descripcion &&
          other.categoria == categoria &&
          other.oferenteId == oferenteId &&
          other.precioBase == precioBase &&
          other.creadoEn == creadoEn &&
          other.estado == estado &&
          listasIguales(other.palabrasClave, palabrasClave);

  @override
  int get hashCode => Object.hash(
        id,
        titulo,
        descripcion,
        categoria,
        oferenteId,
        precioBase,
        creadoEn,
        estado,
        Object.hashAll(palabrasClave), // NO Object.hash(palabrasClave):
      ); // eso hashea la referencia, no el contenido

  @override
  String toString() => 'Servicio($id, $titulo, ${estado.etiqueta})';
}
