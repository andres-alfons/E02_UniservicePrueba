import 'package:uniservice/features/servicios/domain/servicio.dart';

/// Lo que la aplicación necesita saber de los servicios.
///
/// `abstract interface class` = solo contrato: nadie puede heredar de aquí,
/// solo implementarlo. Hoy la implementación lee un JSON local; en semanas
/// futuras leerá de un backend, y esta interfaz no cambia.
abstract interface class ServiciosRepository {
  Future<List<Servicio>> obtenerTodos();

  Future<Servicio?> obtenerPorId(String id);

  Future<List<Servicio>> buscarPorCategoria(String categoria);
}
