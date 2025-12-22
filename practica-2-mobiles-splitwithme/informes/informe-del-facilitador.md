# Informe del Facilitador–Administrador
- Ángela Costa Trigo


## Semana 1

### Registro de tareas llevadas a cabo durante la semana 1

#### Descripción de la tarea
Durante la primera semana el grupo se centro en planificar el trabajo de la práctica 2 y preparar el entorno de desarrollo.
Revisamos la prctica anterior para recuperar los casos de uso relevantes y analizamos los requisitos de esta nueva práctica, que consiste en diesñar una interfaz gráfica adaptativa para dispositivos moviles.
Además, se realizaron las instalaciones y configuraciones necesarias de las herramientas de desarrollo (Flutter, Dart, Android Studio, etc), con el objetivo de dejar todo preparado para la siguiente fase.
Decidimos extender esta tarea a dos semanas para poder organizar el trabajo con más calma y mantener un ritmo sostenible tras la práctica anterior

#### Asignacion de responsables
 - Facilitador–Administrador: Ángela Costa Trigo
 - Analista: Joel Candal Gómez
 - Curador–Traductor: Lucas Marqués Núñez

#### Estado de completitud
La planificación se completó con éxito. Se definió la estructura de trabajo, se repartieron las responsabilidades y se prepararon los entornos técnicos.
No realizamos aportaciones significativas al repositorio porque nos enfocamos en la organizacion inciial

#### Conflictos, desviaciones, etc.
No se registraron conflictos internos.
La única desviación que contemplamos es la falta de la semana de margen en las próximas tareas por si se nos empieza a complicar alguna en particular


### Estado del repositorio en la semana 1

Durante la primera semana no se realizaron commits relevantes.
El repositorio se mantuvo estable mientras el grupo preparaba el entorno y definía la planificación general de la practica



## Semana 2

### Registro de tareas llevadas a cabo durante la semana 2

#### Descripción de la tarea
Durante la segunda semana se avanzó en la Tarea 1: Diseño de la interfaz.
El equipo elaboró los bocetos de la aplicación para móvil y tablet, optando por un diseño vertical en móviles y horizontal en tablets para optimizar el trabajo manteniendo coherencia entre formatos.
Además, se seleccionó el patrón arquitectónico MVVM para la gestión del estado, y se elaboraron los diagramas UML
El diseño final garantiza una separación clara entre vista, lógica y datos, y está preparado para ser implementado con Flutter.

#### Asignacion de responsables
 - Facilitador–Administrador: Ángela Costa Trigo
 - Analista: Joel Candal Gómez
 - Curador–Traductor: Lucas Marqués Núñez

#### Estado de completitud
Consideramos que hemos completadado la tarea satisfactoriamente
El diseño de interfaz y el diseño software fueron finalizados y subidos al repositorio según los requisitos de la practica.

#### Conflictos, desviaciones, etc.
No se presentaron conflictos significativos.
El grupo mantuvo buena comunicacion y coordinación en la distribuciion de tareas



### Estado del repositorio en la semana 2

Durante esta semana el repositorio se actualizó con los documentos principales del diseño:
 - diseño-iu.pdf con los bocetos de la interfaz
 - diseño_sw.md con los diagramas UML y la descripción del patrón MVVM

El proyecto muestra una estructura clara y bien organizada, cumpliendo los objetivos marcados para esta primera tarea


## Semana 3

### Registro de tareas llevadas a cabo durante la semana 3

#### Descripción de la tarea
Durante esta tercera semana trabajamos en la Tarea 2: Implementación de la aplicación, dando comienzo al desarrollo en Flutter a partir de los diseños ya definidos. El grupo se centró en construir la estructura base de la aplicación y en empezar a integrar las distintas pantallas con su lógica correspondiente.

Además, se revisaron aspectos clave del enunciado, especialmente la gestión de errores de E/S, el manejo de procesos asíncronos y la necesidad de asegurar que la aplicación funciona correctamente en dispositivos móviles reales. Tambieen se fueron actualizando ciertos fragmentos del diseño cuando surgieron pequeños ajustes necesarios durante la implementación, manteniendo los documentos alineados con el codigo

El trabajo de esta semana se enfoco en avanzar de manera sólida sin descuidar la calidad del desarrollo ni la coherencia con el diseño previo. Cada miembro participó en mayor o menor medida en la implementacion y en la revisión de los cambios, ayudando a mantener una estructura común del proyecto y a resolver dudas de arquitectura o de adaptaci0n de los bocetos a Flutter

#### Asignacion de responsables
 - Facilitador–Administrador: Ángela Costa Trigo
 - Analista: Joel Candal Gómez
 - Curador–Traductor: Lucas Marqués Núñez

#### Estado de completitud
El equipo considera que la implementación ha avanzado de forma adecuada. Se completó la base de la aplicación, se comenzaron a integrar pantallas y se aseguraron las primeras operaciones asincronas y manejo de errores. Aunque queda trabajo por realizar, el progreso es consistente y está alineado con los objetivos de la práctica

#### Conflictos, desviaciones, etc
No se registraron conflictos dentro del grupo.
La principal desviación es que algunos componentes requerirán mas tiempo del previsto inicialmente, sobre todo por la necesidad de ajustar el diseño sobre la marcha, pero la planificación sigue siendo manejable.

### Estado del repositorio en la semana 3

Durante esta semana el repositorio se actualizó con los primeros archivos de implementación en Flutter. Se añadieron la estructura inicial de carpetas, las pantallas principales y parte de la lógica asociada, junto con pequeñas actualizaciones en los documentos de diseño para reflejar los cambios surgidos durante el desarrollo. El proyecto ya cuenta con una base funcional sobre la que continuar la implementación durante las próximas semanas.



## Semana 4

### Registro de tareas llevadas a cabo durante la semana 4

#### Descripción de la tarea
Durante esta semana el grupo se centró en completar tercera tarea, implementando pruebas a través de la interfaz grafica siguiendo la documentación de diseño y utilizando las librerias de testing de Flutter.
Se desarrollaron test para los distintos casos de uso definidos previamente y también para situaciones de error, tanto de E/S como de interacción de la usuaria. Fue necesario depurar varios fallos e iterar varias veces hasta conseguir que todos los tests pasaran correctamente

Además, aprovechamos esta semana para finalizar las funcionalidades que estaban pendientes en la aplicación, asegurando que la implementación coincidiese con lo previsto en el diseño. También se incorporó concurrencia asíncrona, necesaria para gestionar operaciones que implican E/S y para mejorar la fluidez general de la aplicación durante la ejecución de determinadas acciones.

#### Asignación de responsables
- Facilitador–Administrador: Ángela Costa Trigo
- Analista: Joel Candal Gómez
- Curador–Traductor: Lucas Marqués Núñez

El trabajo se repartió de forma equilibrada: mientras una parte del equipo se centró en desarrollar y ajustar los tests end2end, el resto completó las funcionalidades que faltaban y revisó la integración de la concurrencia asíncrona. La colaboración fue continua y permitio avanzar de manera estable

#### Estado de completitud
Consideramos que la tarea de esta semana está completada satisfactoriamente.
Los tests end2end funcionan correctamente, la aplicación incluye las funcionalidades previstas y se integraron los mecanismos de concurrencia necesarios

#### Conflictos, desviaciones, etc
No se registraron conflictos dentro del grupo. La única dificultad reseñable fue el tiempo extra que requirió la depuración de pruebas que fallaban sin motivo aparente, lo que nos llevó a iterar y comprobar cuidadosamente la configuración de los tests. Aun asi, se resolvió dentro del plazo previsto


### Estado del repositorio en la semana 4

Durante esta semana el repositorio se actualizó con:
-	Los archivos correspondientes a los tests end-to-end en la carpeta integration_test/.
-	Las funcionalidades completadas en la carpeta lib/
-	Ajustes menores relacionados con la concurrencia asincrona y la gestión de errores

El estado actual del proyecto refleja el avance hacia una versión funcional y testeada de la aplicacion
