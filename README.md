Aquí tienes un archivo **`README.md`** completo, profesional y estructurado específicamente para tu proyecto (**Gestor de Ingresos y Gastos con Metas**). Está diseñado con un formato limpio para que solo tengas que copiarlo, pegarlo en la raíz de tu proyecto y lucirlo en tu repositorio (por ejemplo, en GitHub).

---

```markdown
# 💰 Gestor de Ingresos y Gastos V2

¡Bienvenido a **Gestor de Ingresos**! Una aplicación móvil moderna, intuitiva y potente desarrollada en **Flutter** para el control total de tus finanzas personales. Este proyecto permite registrar transacciones diarias (ingresos y egresos), clasificarlas por categorías, monitorear presupuestos mediante un sistema de metas y analizar la salud financiera con gráficos avanzados en tiempo real.

---

## ✨ Características Principales

- **📊 Reportes Financieros Avanzados:**
  - Gráfico de dona dinámico para comparar el **Porcentaje de Ahorro frente a Gastos**.
  - Histograma de barras para visualizar la tendencia de consumos de la **Semana Actual**.
  - Distribución analítica de **Gastos por Categoría** mediante diagramas de pastel.
- **👁️ Modo Privacidad (Anti-Espías):** Un botón interactivo de "ojo" en la pantalla de *Insights* que enmascara instantáneamente todos tus saldos y montos (`••••`) para proteger tu información en entornos públicos.
- **🎯 Sistema de Metas (Goals):** Configuración de límites presupuestarios o metas financieras vinculadas a tus categorías.
- **🗄️ Persistencia de Datos:** Arquitectura robusta con **SQLite** para el almacenamiento local rápido, seguro y sin necesidad de internet.
- **🎨 Interfaz Premium:** Diseño limpio, tipografía legible y paleta de colores desaturada orientada a la experiencia de usuario (UX).

---

## 🏗️ Arquitectura y Tecnologías Utilizadas

El proyecto sigue las mejores prácticas de desarrollo en Flutter, separando la lógica de negocio de la interfaz de usuario:

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Gestión de Estado:** [Provider](https://pub.dev/packages/provider) para una reactividad eficiente y desacoplada.
* **Base de Datos Local:** [SQFlite](https://pub.dev/packages/sqflite) con control de versiones y relaciones de clave foránea (`ON DELETE CASCADE`).
* **Gráficos Estéticos:** [FL Chart](https://pub.dev/packages/fl_chart) para la renderización nativa y fluida de estadísticas.

---

## 📂 Estructura del Proyecto

```text
lib/
│
├── database/
│   └── database_helper.dart      # Inicialización de SQLite, tablas (categories, transactions, goals) y CRUD
│
├── models/
│   ├── category_model.dart       # Modelo de datos para las Categorías
│   ├── transaction_model.dart    # Modelo de datos para Ingresos/Gastos
│   └── goal_model.dart           # Modelo de datos para los Objetivos Financieros
│
├── providers/
│   └── transaction_provider.dart # Lógica de negocio, cálculos de totales y comunicación con la DB
│
├── screens/
│   ├── insights_screen.dart      # Resumen financiero con botón de privacidad (Ojo)
│   ├── reports_screen.dart       # Pantalla de gráficos (Dona, Barras Semanales, Pastel)
│   └── add_transaction_screen.dart # Formulario de registro de flujos monetarios
│
└── main.dart                     # Punto de entrada de la aplicación e inyección de Providers

```

---

## 🚀 Instalación y Configuración Local

Sigue estos pasos para clonar el proyecto y ejecutarlo en tu máquina de desarrollo:

### Prerrequisitos

* Tener instalado **Flutter SDK** (versión estable).
* Un emulador (Android/iOS) o dispositivo físico conectado.

### Pasos

1. **Clonar el repositorio:**
```bash
git clone [https://github.com/TU_USUARIO/gestor_ingresos.git](https://github.com/TU_USUARIO/gestor_ingresos.git)
cd gestor_ingresos

```


2. **Instalar las dependencias de Pub:**
```bash
flutter pub get

```


3. **Ejecutar la aplicación:**
```bash
flutter run

```



---

## 📱 Compilación para Producción / Pruebas

### 🤖 Android (Generar APK)

Para compilar la versión final instalable en dispositivos Android:

```bash
flutter build apk --release

```

El archivo resultante se guardará en `build/app/outputs/flutter-apk/app-release.apk`.

### 🍏 iOS (Sin Mac - Vía Cloud)

Dado que el entorno requiere herramientas de Apple, si desarrollas desde Windows/Linux puedes compilar usando servicios en la nube:

1. Sube este repositorio a tu cuenta de **GitHub**.
2. Conéctalo a [Codemagic.io](https://codemagic.io/) (Plan gratuito).
3. Configura el entorno para **iOS** en modo **Release** para obtener tu instalador `.ipa`.
4. Instala el `.ipa` en tu iPhone usando herramientas como **Sideloadly** o **AltStore**.

---

## ⚙️ Base de Datos e Inicialización

La aplicación cuenta con un sistema de inicialización automática. Al abrirse por primera vez, se genera la base de datos `gestor_ingresos_v3.db` e inserta de forma predeterminada las siguientes categorías esenciales:

* `Salary/Income` (Ingresos)
* `Groceries` (Abarrotes/Comida)
* `Transport` (Transporte)
* `Shopping` (Compras)
* `Entertainment` (Entretenimiento)
* `Utilities` (Servicios básicos)
* `Others` (Otros)

---

## 📝 Notas de Versión Recientes

* **Fix (Layout):** Corrección del error de desbordamiento de pantalla (`Right Overflowed`) en la sección de reportes mediante la implementación de `Expanded` y formateo inteligente de cifras macro (`$10.0M`, `$15.5K`).
* **Feature (Privacy):** Se migró la pantalla de *Insights* a un componente con estado (`StatefulWidget`) para dar soporte al ocultamiento dinámico de información financiera.

```

***

### 💡 Consejo para agregarlo:
1. En la carpeta raíz de tu proyecto de Flutter (donde está el archivo `pubspec.yaml`), crea un archivo llamado **`README.md`**.
2. Copia todo el bloque de texto gris de arriba y pégalo dentro de ese archivo.
3. Guarda los cambios. ¡Listo! Al subirlo a GitHub o abrirlo en editores de código como VS Code, se formateará automáticamente con negritas, títulos y listas.

```