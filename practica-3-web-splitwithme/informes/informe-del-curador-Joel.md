# Informe del Curador-Traductor  
**Curador–traductor: Joel Candal Gómez**

---

## Objetivos de aprendizaje de la semana 1

- **Concepto, herramienta, …**  
  Durante la primera semana el objetivo principal fue comprender las pautas de diseño requeridas para la Tarea 1 de la práctica: enfoque *mobile-first*, diseño adaptativo, uso exclusivo de HTML5 y CSS3 sin frameworks, semántica correcta y aplicación de criterios básicos de accesibilidad. También se buscó establecer una estructura clara del informe de gastos que serviría como base para el diseño de la interfaz.

  **Recursos identificados para su estudio.**  
  - Enunciado de la práctica (Tarea 1).  
  - Material previo de la aplicación de gastos usada en prácticas anteriores.  
  - Referencias de interfaces mobile-first y diseño semántico.

---

## Recursos empleados en la semana 1

- **Descripción del recurso.**  
  El grupo revisó qué información debía incluir el informe de gastos (lista de gastos, participantes, cantidades totales y reparto). Con esa base se elaboró el documento `diseño-iu.pdf` siguiendo un enfoque mobile-first. Se propuso también una estructura inicial en HTML semántico con secciones, encabezados y elementos organizados.  
  Desde mi rol como curador–traductor, revisé la coherencia terminológica del diseño, la claridad de los textos, y la consistencia entre el PDF y la estructura HTML planteada, además de verificar que el planteamiento cumpliera los requisitos formales del enunciado.

  **Utilidad y aplicación a la práctica.**  
  Este trabajo permitió sentar la base del proyecto, organizar el contenido del informe y asegurar que el diseño cumpliera los estándares requeridos. La revisión documental garantizó coherencia y claridad, facilitando que la siguiente fase (implementación completa del HTML/CSS) se pueda abordar con una estructura sólida y alineada con los objetivos de la práctica.

---

## Objetivos de aprendizaje de la semana 2

- **Concepto, herramienta, …**  
  En esta segunda semana el objetivo principal fue extender la implementación realizada previamente, incorporando no solo la visualización estática de los gastos sino la capacidad de **modificar los datos mostrados en la interfaz**.  
  Para ello se trabajó con **JavaScript en el navegador y manipulación del DOM**, añadiendo controladores de eventos y actualizaciones dinámicas sobre la información ya renderizada.

  Además, se abordaron funcionalidades adicionales necesarias para el correcto funcionamiento del sistema de reparto:
  - **Actualización del crédito de amigos** cuando un gasto era modificado.
  - **Incorporación de nuevos amigos a un gasto existente**.
  - **Corrección de fallos detectados** en la semana 1 relacionados con inconsistencias numéricas y refresco de la interfaz tras cambios.

---

## Recursos empleados en la semana 2

- **Descripción del recurso.**  
  Durante esta semana se revisó de nuevo el material de la práctica, específicamente el apartado relativo a la Tarea 2 donde se indica que debían añadirse capacidades de edición sin necesidad de envío a servidor.  
  También se ampliaron los controles de la interfaz incorporando nuevos elementos (botones, campos de entrada y selectores) para permitir la modificación directa de los datos.

  Desde mi rol como curador–traductor verifiqué la terminología de los nuevos componentes añadidos y la consistencia de los mensajes comunicados al usuario en la interfaz, así como la claridad de los textos asociados a créditos, participantes y totales.

  **Utilidad y aplicación a la práctica.**  
  La manipulación dinámica del DOM permitió que la aplicación dejase de ser meramente informativa y pasara a ser **interactiva y editable**, aumentando su fidelidad respecto a un sistema real.  
  La capacidad de ajustar créditos y sumar participantes permitió validar los cálculos automáticos del reparto y detectar errores que se corrigieron (tanto visuales como lógicos), lo cual mejora el flujo interno de la aplicación y prepara el terreno para la futura simulación de envío de datos.

---

## Resultado de la semana

La aplicación ahora permite:
- Editar los datos de un gasto ya existente sin recargar la página.
- Añadir amigos a un gasto previamente registrado.
- Actualizar de forma inmediata el crédito resultante del reparto entre los participantes.
- Mostrar en la interfaz los cambios sin inconsistencias numéricas.
- Garantizar coherencia visual y textual entre los componentes y acciones mostradas.

Todo ello se mantiene dentro de los criterios marcados: **no envío real de datos**, uso exclusivo de **JavaScript en el navegador**, y actualización de la interfaz mediante **DOM**.
