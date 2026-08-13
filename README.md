# UniService

En las instituciones de educación superior de Valledupar, los estudiantes
intercambian servicios académicos (tutorías, proyectos, logística) sobre todo
en grupos informales de redes sociales, sin verificación, reputación ni forma
de resolver conflictos. UniService centraliza esa oferta y demanda en un
entorno seguro y estructurado.

## El dominio

- **`Servicio`** — entidad principal. Identidad: `id`. Representa una oferta
  publicada por un estudiante (tutoría, diseño, transporte, etc.).
- **`Precio`** — objeto de valor (`monto` + `moneda`). Dos precios con el
  mismo monto y moneda son el mismo precio; no necesita identidad propia.
- **`EstadoServicio`** — clase sellada con cinco estados, cada uno con los
  datos que solo tienen sentido en ese momento de la vida del servicio:
  - `Borrador` — sin datos adicionales.
  - `Publicado(publicadoEn)`
  - `Contratado(estudianteId, precioAcordado, contratadoEn)`
  - `Completado(completadoEn, calificacion)`
  - `Cancelado(motivo)`

Un servicio `Contratado` sin `estudianteId`, o un `Cancelado` sin `motivo`,
no se pueden ni escribir: el compilador lo impide, no una validación que
alguien podría olvidar.

**Decisión sobre freezed:** el modelo se dejó escrito a mano y no generado.
La razón concreta es el manejo de errores: `Servicio.fromJson` usa
`CampoInvalido`, que dice exactamente qué campo del JSON falló y por qué
(por ejemplo `CampoInvalido: 'titulo' debe ser un texto no vacío`). La
versión generada con `json_serializable` perdería ese mensaje y volvería al
genérico `type 'Null' is not a subtype of type 'String'`, que no dice cuál
de los ocho campos fue. A cambio se escribieron a mano `==`, `hashCode` y
`copyWith` (~110 líneas mecánicas), que es el costo aceptado por conservar
errores útiles en la frontera con datos externos.

## Cómo correrlo

```bash
flutter pub get
flutter test
flutter run
```

## Estructura

```
lib/
├─ core/                          # lectores defensivos de JSON, comparaciones
└─ features/servicios/
   ├─ domain/                     # Servicio, Precio, EstadoServicio, la interfaz
   │                              # del repositorio — sin imports de Flutter
   └─ data/                       # ServiciosLocales: lee assets/data/servicios.json
assets/data/servicios.json        # datos de ejemplo
test/
├─ domain/servicio_test.dart      # 14 pruebas: serialización, igualdad, reglas
└─ data/servicios_locales_test.dart  # 5 pruebas del repositorio
```
