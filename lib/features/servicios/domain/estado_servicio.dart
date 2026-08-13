import 'package:uniservice/core/json.dart';
import 'package:uniservice/features/servicios/domain/precio.dart';

/// En qué punto de su vida está un servicio publicado en UniService.
///
/// `sealed` significa dos cosas: nadie fuera de este archivo puede añadir un
/// estado nuevo, y el compilador conoce la lista completa. Eso es lo que
/// permite que los `switch` de abajo sean exhaustivos sin `default`.
sealed class EstadoServicio {
  const EstadoServicio();

  /// El ÚNICO sitio donde un texto del JSON se convierte en un tipo.
  factory EstadoServicio.fromJson(Map<String, dynamic> json) {
    final tipo = leerTexto(json, 'tipo');
    return switch (tipo) {
      'borrador' => const Borrador(),
      'publicado' => Publicado(leerFecha(json, 'publicadoEn')),
      'contratado' => Contratado(
          leerTexto(json, 'estudianteId'),
          Precio.fromJson(leerMapa(json, 'precioAcordado')),
          leerFecha(json, 'contratadoEn'),
        ),
      'completado' => Completado(
          leerFecha(json, 'completadoEn'),
          leerEntero(json, 'calificacion'),
        ),
      'cancelado' => Cancelado(leerTexto(json, 'motivo')),
      _ => throw CampoInvalido('estado.tipo', 'no es un estado conocido', tipo),
    };
  }

  /// Y el único sitio donde vuelve a ser texto. Simétrico a fromJson: si
  /// añades un estado arriba y olvidas añadirlo aquí, esto no compila.
  Map<String, dynamic> toJson() => switch (this) {
        Borrador() => {'tipo': 'borrador'},
        Publicado(:final publicadoEn) => {
            'tipo': 'publicado',
            'publicadoEn': publicadoEn.toIso8601String(),
          },
        Contratado(
          :final estudianteId,
          :final precioAcordado,
          :final contratadoEn
        ) =>
          {
            'tipo': 'contratado',
            'estudianteId': estudianteId,
            'precioAcordado': precioAcordado.toJson(),
            'contratadoEn': contratadoEn.toIso8601String(),
          },
        Completado(:final completadoEn, :final calificacion) => {
            'tipo': 'completado',
            'completadoEn': completadoEn.toIso8601String(),
            'calificacion': calificacion,
          },
        Cancelado(:final motivo) => {'tipo': 'cancelado', 'motivo': motivo},
      };

  /// Regla de negocio, no de interfaz: quién puede seguir editando la oferta.
  bool get sePuedeEditar => switch (this) {
        Borrador() || Publicado() => true,
        Contratado() || Completado() || Cancelado() => false,
      };

  /// Si el servicio sigue abierto a que alguien lo tome.
  bool get estaDisponible => switch (this) {
        Publicado() => true,
        Borrador() || Contratado() || Completado() || Cancelado() => false,
      };

  /// Texto para la pantalla.
  String get etiqueta => switch (this) {
        Borrador() => 'Borrador',
        Publicado() => 'Publicado',
        Contratado(:final estudianteId) => 'Contratado por $estudianteId',
        Completado(:final calificacion) => 'Completado · $calificacion★',
        Cancelado(:final motivo) => 'Cancelado: $motivo',
      };
}

final class Borrador extends EstadoServicio {
  const Borrador();

  @override
  bool operator ==(Object other) => other is Borrador;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Borrador()';
}

final class Publicado extends EstadoServicio {
  const Publicado(this.publicadoEn);

  final DateTime publicadoEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Publicado && other.publicadoEn == publicadoEn;

  @override
  int get hashCode => Object.hash(runtimeType, publicadoEn);

  @override
  String toString() => 'Publicado($publicadoEn)';
}

final class Contratado extends EstadoServicio {
  const Contratado(this.estudianteId, this.precioAcordado, this.contratadoEn);

  final String estudianteId;
  final Precio precioAcordado;
  final DateTime contratadoEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Contratado &&
          other.estudianteId == estudianteId &&
          other.precioAcordado == precioAcordado &&
          other.contratadoEn == contratadoEn;

  @override
  int get hashCode =>
      Object.hash(runtimeType, estudianteId, precioAcordado, contratadoEn);

  @override
  String toString() =>
      'Contratado($estudianteId, $precioAcordado, $contratadoEn)';
}

final class Completado extends EstadoServicio {
  // El assert documenta la regla y la caza en depuración. La GARANTÍA es
  // leerEntero + esta comprobación, que rechazan una calificación fuera de
  // rango también en producción... salvo que quieras dejarlo solo como aviso
  // de desarrollo: aquí se deja como assert a propósito, ver README.
  const Completado(this.completadoEn, this.calificacion)
      : assert(
            calificacion >= 1 && calificacion <= 5, 'calificación entre 1 y 5');

  final DateTime completadoEn;
  final int calificacion;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Completado &&
          other.completadoEn == completadoEn &&
          other.calificacion == calificacion;

  @override
  int get hashCode => Object.hash(runtimeType, completadoEn, calificacion);

  @override
  String toString() => 'Completado($completadoEn, $calificacion★)';
}

final class Cancelado extends EstadoServicio {
  const Cancelado(this.motivo) : assert(motivo != '', 'cancelar exige motivo');

  final String motivo; // cancelar SIN motivo no se puede ni escribir

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Cancelado && other.motivo == motivo;

  @override
  int get hashCode => Object.hash(runtimeType, motivo);

  @override
  String toString() => 'Cancelado($motivo)';
}
