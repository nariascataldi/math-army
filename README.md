# Math Army 🧮⚔️

**Math Army** es una aplicación móvil multiplataforma (iOS y Android) desarrollada con Flutter, inspirada en las mecánicas de runners multiplicadores pero adaptada como una herramienta pedagógica de cálculo mental rápido para niños de 10 años.

El jugador controla al líder **"Leo"**, quien comienza su aventura con solo 1 soldado. A lo largo del trayecto, Leo deberá calcular rápidamente las operaciones de los portales matemáticos para multiplicar su ejército y derrotar al jefe enemigo en la meta, el cual defiende su fuerte con un ejército de **70 soldados**.

---

## 🎨 Características Principales

*   **Clean Architecture**: Lógica de negocio (motor matemático) 100% aislada de la renderización y vistas de Flutter.
*   **Generador Dinámico Garantizado**: Algoritmos matemáticos que aseguran que el nivel solo se supera tomando decisiones perfectas. Si el jugador comete un solo error, el total de soldados final será menor a 70.
*   **Visuales 2D Premium**: Renderizado personalizado con `CustomPainter` que posiciona a los soldados dinámicamente en formaciones compactas alrededor del héroe, con animaciones de carrera orgánicas.
*   **Diseño Pedagógico**: Portales con colores neón neutros antes del cruce para evitar que el niño resuelva por descarte de colores.

---

## 🛠️ Instalación y Requisitos

Asegúrate de contar con el SDK de Flutter instalado en tu sistema.

1.  **Clonar el repositorio y situarse en él**:
    ```bash
    cd math-army
    ```
2.  **Instalar las dependencias de Flutter**:
    ```bash
    flutter pub get
    ```
3.  **Ejecutar análisis estático (Lints)**:
    ```bash
    flutter analyze
    ```
4.  **Ejecutar pruebas unitarias y de widgets**:
    ```bash
    flutter test
    ```
5.  **Iniciar la aplicación**:
    ```bash
    flutter run
    ```

---

## 🕹️ Cómo Jugar

1.  **Inicio**: Presiona **JUGAR AHORA** en la pantalla de bienvenida.
2.  **Movimiento**: Desliza el dedo horizontalmente en la pantalla (o presiona los laterales de la pista) para mover a Leo a la izquierda o derecha.
3.  **Cálculo Mental**: Lee las operaciones de los portales dobles flotantes (Ej: `+15` vs `x3`) y muévete hacia el portal que te otorgue el mayor número de soldados.
4.  **La Gran Batalla**: Al final de la pista, tu ejército chocará uno a uno contra los 70 soldados del jefe enemigo. ¡Si te queda al menos un soldado en pie, habrás ganado!

---

## ☁️ Integración en la Nube (Stitch)

El proyecto está vinculado al entorno de **Stitch** para el control de interfaces y el sistema de diseño:
*   **Stitch Project ID**: `1698190024553260247`
*   **Design System Asset ID**: `0f381c9721b340b1bf7a27d1e3c45704`
