# Guía del Agente (AGENT.md)

Este documento está diseñado para que futuros agentes de IA o herramientas de refactorización comprendan instantáneamente el contexto del proyecto y puedan expandir o mantener la aplicación sin fricciones.

---

## 🚀 Contexto Técnico Rápido

*   **Tecnología**: Flutter (iOS/Android) compatible con Dart 3.x.
*   **Gestión de Estado**: `provider` (reactividad básica en widgets) + `ChangeNotifier` para el control de físicas.
*   **Inyección de Dependencias**: `get_it` (Service Locator) configurado en `main.dart`.
*   **Integración Stitch Cloud**: Vinculado al proyecto `projects/1698190024553260247` con el Design System asset `0f381c9721b340b1bf7a27d1e3c45704`.
*   **Aislamiento del Core**: La lógica matemática (`lib/features/math_engine`) es pura en Dart y no importa ningún widget o paquete de Flutter.

---

## 📂 Arquitectura de Carpetas y Responsabilidades

```
lib/
├── core/
│   ├── theme.dart            # Estilo visual neón (variables estáticas para CustomPainter).
│   └── audio_utils.dart      # Abstracción de audio (MockAudioSystem para no añadir binarios nativos).
├── features/
│   ├── math_engine/          # Reglas del negocio matemático.
│   │   ├── domain/           # Entidades (MathOperation, MathProblem) y firma del repositorio.
│   │   └── data/             # Generador de problemas (ProblemGenerator) y repositorio concreto.
│   └── game/                 # Lógica de renderizado y Game Loop.
│       ├── domain/           # Modelos de escena (Soldier, Leo, EnemyBoss).
│       └── presentation/     # GameController (físicas), GameScreen (UI), GamePainter (dibujo Canvas).
```

---

## 🧠 Funcionamiento de Componentes Clave

### 1. Invariante del `ProblemGenerator`
El generador utiliza un conjunto controlado de operaciones dinámicas. Las operaciones óptimas en secuencia garantizan llegar a la meta con $\ge 70$ soldados. Las operaciones incorrectas aplican restas de gran tamaño o divisiones de factor 2 o 3. 
*   **Para verificar la lógica matemática**: Consulta e introduce nuevas validaciones en `test/features/math_engine/math_engine_test.dart`.

### 2. Algoritmo de formación concéntrica
En `GameController._recalculateSoldierFormations()`, los soldados clonados se organizan en capas espirales circulares alrededor de Leo para lograr un comportamiento visual orgánico tipo bandada. Cada soldado rastrea coordenadas `targetOffsetX/Y` y se desplaza suavemente hacia ellas mediante interpolaciones lineales en su método `update(dt)`.

### 3. Pintado en Canvas (`GamePainter`)
Dibuja tanto los portales como los soldados y los efectos de scroll. Para simular velocidad en carrera, se aplica un desplazamiento al patrón de líneas del carril central basado en una función sinusoidal dependiente del progreso.

---

## 🛠️ Cómo Extender el Proyecto (Directivas para la IA)

### Agregar un nuevo tipo de Operación Matemática (Ej: Potencias)
1.  Crea una subclase de `MathOperation` en [math_operation.dart](file:///Users/nestorariascataldi/Projects/math-army/lib/features/math_engine/domain/entities/math_operation.dart) (Ej: `PowerOperation`).
2.  Añade el tipo en `MathOperationType` (enum).
3.  Actualiza la factoría `MathOperation.create` y `MathOperation.fromString` para retornar tu nueva clase.
4.  Modifica [problem_generator.dart](file:///Users/nestorariascataldi/Projects/math-army/lib/features/math_engine/data/data_sources/problem_generator.dart) para integrar tu nueva operación en niveles más altos.

### Integrar Audio Real (Stitch / Plugins de Terceros)
1.  Implementa la interfaz abstracta `AudioSystem` en `lib/core/audio_utils.dart` utilizando el plugin `audioplayers` o `soundpool`.
2.  Modifica la inicialización del Service Locator en `lib/main.dart` para registrar tu nueva implementación en lugar de `MockAudioSystem`.
