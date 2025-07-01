# FontPer - App de Gestión de Tareas de Fontanería 🚿📋

Aplicación móvil desarrollada en Flutter, diseñada para facilitar el trabajo diario de los fontaneros mediante una gestión ágil de tareas y piezas.

## 🛠️ Funcionalidades

- Visualización de tareas con datos del cliente (nombre, dirección, teléfono).
- Base de datos completa con piezas de fontanería clasificadas por tipo y material.
- Asociación de piezas a cada tarea, con control de cantidad.
- Envío de piezas por WhatsApp:
  - Desde una tarea específica.
  - Desde varias tareas seleccionadas.
  - Desde todas las piezas marcadas.

## 📦 Tecnologías Utilizadas

- **Flutter** con **Provider** para el frontend y gestión de estado.
- **SQLite** como base de datos local, precargada desde `assets/fontper.db`.

## 🧱 Base de Datos

El esquema incluye:

- `material`: tipos de material y su prioridad.
- `tipoPiezas`: clasificación de piezas.
- `pieza`: catálogo de piezas con múltiples atributos (medida, conexión, tipo, etc.).
- `tareas`: tareas asignadas con datos del cliente.
- `piezasTarea`: relación entre piezas y tareas.

> La base de datos viene prellenada con piezas reales del mercado valenciano.

## 📱 Pantallas Incluidas

- **TareaGeneralScreen**: listado de tareas.
- **TareaScreen**: creación de nuevas tareas.
- **TareaDetalleScreen**: gestión de piezas de una tarea y envío por WhatsApp.
- **SelectorPiezasScreen**: selección de piezas reutilizable.

## ▶️ Instalación

```bash
git clone https://github.com/JPerpi/fontper.git
cd fontper
flutter pub get
flutter run
