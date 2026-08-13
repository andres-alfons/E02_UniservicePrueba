import 'package:flutter/material.dart';
import 'package:uniservice/features/servicios/data/servicios_locales.dart';
import 'package:uniservice/features/servicios/domain/servicio.dart';

void main() => runApp(const UniServiceApp());

class UniServiceApp extends StatelessWidget {
  const UniServiceApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'UniService',
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        home: const PantallaServicios(),
      );
}

class PantallaServicios extends StatefulWidget {
  const PantallaServicios({super.key});

  @override
  State<PantallaServicios> createState() => _PantallaServiciosState();
}

class _PantallaServiciosState extends State<PantallaServicios> {
  // `late final` en el campo: el Future se crea UNA vez. Crearlo dentro de
  // build() lo relanza en cada reconstrucción.
  late final Future<List<Servicio>> _servicios =
      ServiciosLocales().obtenerTodos();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('UniService')),
        body: FutureBuilder<List<Servicio>>(
          future: _servicios,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              // El mensaje de CampoInvalido dice el campo exacto que falló.
              return Center(child: Text('No se pudo leer:\n${snapshot.error}'));
            }

            final servicios = snapshot.data ?? const <Servicio>[];
            return ListView.separated(
              itemCount: servicios.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final servicio = servicios[i];
                return ListTile(
                  title: Text(servicio.titulo),
                  subtitle: Text(
                      '${servicio.categoria} · ${servicio.estado.etiqueta}'),
                  trailing:
                      Text('\$${servicio.precioBase.monto.toStringAsFixed(0)}'),
                );
              },
            );
          },
        ),
      );
}
