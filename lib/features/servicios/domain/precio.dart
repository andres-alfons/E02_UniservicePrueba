import 'package:uniservice/core/json.dart';

/// Cuánto cuesta un servicio.
///
/// Es un **objeto de valor**: dos precios de \$25.000 COP son el mismo
/// precio, así que no lleva `id` y se compara por contenido, no por
/// identidad.
class Precio {
  const Precio({required this.monto, this.moneda = 'COP'});

  factory Precio.fromJson(Map<String, dynamic> json) => Precio(
        monto: leerDecimal(json, 'monto'),
        moneda: leerTextoOpcional(json, 'moneda') ?? 'COP',
      );

  final double monto;
  final String moneda;

  Map<String, dynamic> toJson() => {'monto': monto, 'moneda': moneda};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Precio && other.monto == monto && other.moneda == moneda;

  @override
  int get hashCode => Object.hash(monto, moneda);

  @override
  String toString() => 'Precio($monto $moneda)';
}
