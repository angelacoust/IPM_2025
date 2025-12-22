# Informe del Curador–Traductor
- Ángela Costa Trigo


Lista de objetivos de aprendizaje definidos por el traductor
------------------------------------------------------------
1, Comprender los fundamentos de la implementación de interfaces gráficas en Python con GTK 4.
2. Aplicar patrones arquitectónicos adecuados (en este caso elegimos MVP) para separar la vista del modelo
3. Manejar el lenguaje python y entender su influencia en el manejo de interfaces graficas.
4. Colaborar en equipo para mantener coherencia documental y técnica durante el desarrollo del proyecto

Lista de recursos:
-------------------
1. Documentación oficial de GTK y ejemplos en python.
Cómo usarlo: consultar la sección de widgets y señales para construir la interfaz gráfica.
Enlace: https://docs.gtk.org/gtk4/
Cómo ayuda: nos apoyamos en esto para entender la estructura de la interfaz y resolver dudas sobre la implementación práctica.

3. Materiales de la asignatura IPM sobre diseño de interfaces y patrones arquitectónicos.
Cómo usarlo: revisar los apuntes de teoria para reforzar la aplicación de los patrones en el codigo
Enlace: no hay enlace, son apuntes tomados en clase
Cómo ayuda: sirvió como base conceptual para comprender los fundamentos de los patrones de diseño.

4. Guías de GitHub y Mermaid para documentación técnica.
Cómo usarlo: seguir los ejemplos de sintaxis Mermaid para realizar los diagramas UML en Markdown.
Enlace: https://mermaid.js.org/ 
Cómo ayuda: Nos ayudo a crear los diagramas incluidos en el diseño sw

5. Repositorio de la práctica.
Cómo usarlo: utilizarlo como espacio común para subir, revisar y coordinar el trabajo de cada miembro
Enlace: https://github.com/GEI-IPM-614G010222526/practica-de-escritorio-red-hot-chili-peppers
Cómo ayuda: Nos permitio gestionar versiones del código y mantener la documentación organizada

6. Ejemplos de código en Python-GTK.
Cómo usarlo: consultar ejemplos de clase para adaptar fragmentos útiles a la práctica.
Enlace: Tampoco hay enlace
Cómo ayuda: ayudó a entender la logica de los componentes gráficos y su comunicación con el modelo



Objetivos de aprendizaje de la semana 1
---------------------------------------
Concepto, herramientas:
Durante la primera semana el objetivo fue comprender los fundamentos de la implementación de interfaces graficas en Python con GTK 4, así como los patrones arquitectónicos que podíamos usar y empezar a programar en un lenguaje al que no estábamos acostumbrados.

Recursos identificados para su estudio:
- Documentación de GTK y ejemplos en python
- Materiales de la asignatura IPM sobre diseño de interfaces y patrones arquitectónicos
- revisión del código base y del servidor disponible en el repositorio.

Recursos empleados en la semana 1
---------------------------------
Descripción del recurso:
El grupo revisó la práctica indiviidual anterior y discutió la estructura general del proyecto. Para las tres primeras partes de la tarea, yo modifiqué la práctica individual para reutilizarla en este trabajo, Joel escogió el patrón MVP (Modelo Vista Presentador) y Lucas se encargó de hacer los diagramas correspondientes. Para la parte de implementación, a pesar de que tratamos de hacerlo todo en conjunto para facilitar el proceso, el progreso técnico fue limitado por problemas iniciales de configuracion y coordinación.

Utilidad y aplicación a la práctica
Esta fase sirvió para afianzar conceptos teóricos y preparar el entorno de trabajo compartido, estableciendo la base para avanzar en la implementación


Objetivos de aprendizaje de la semana 2
---------------------------------------
Concepto, herramientas:
En la segunda semana comenzamos la implementación del diseño software y la aplicación práctica del patrón arquitectónico seleccionado. Se trabajó en la definicon de casos de uso, la documentación en Markdown con diagramas UML (Mermaid) y la organización del código

Recursos identificados para su estudio:
- repositorio de la práctica
- Guías de GitHub y Mermaid para documentación tecnica
- Ejemplos de código en Python-GTK.

Recursos empleados en la semana 2
---------------------------------
Descripción del recurso:
Se utilizó GitHub como herramienta de control de versiones y Visual Studio Code como entorno de desarrollo. Como curador–traductor colabore en la revisión lingüística y técnica de la documentación y la verificación de la coherencia terminológica. También participé en la depuración de código.

Utilidad y aplicación a la práctica:
La revisión y traducción facilitaron la comunicación interna y la claridad del repositorio, contribuyendo a mantener una documentación coherente y comprensible para todos los miembros del equipo

Conclusion:
-----------
En estas dos primeras semanas se establecieron los fundamentos teóricos y técnicos del proyecto. Aunque la primera semana tuvo avances limitados, en la segunda se logró consolidar el trabajo colaborativo y comenzar la implementación.
Desde el rol de curador–traductor, mi aporte se centró en la coherencia documental y lingüitica, apoyando el desarrollo y la comprensión general del código y la documentación del proyecto.



Objetivos de aprendizaje de la semana 3
---------------------------------------

Concepto, herramientas:
Durante la tercera semana el objetivo fue comprender la gestión de la concurrencia y la E/S en interfaces gráficas, así como la implementación de mecanismos de control de errores para mejorar la experiencia del usuario. Buscamos reforzar el manejo de operaciones concurrentes que eviten bloqueos en la interfaz y la integraicon de mensajes informativos ante errores o peticiones fallidas al servidor.

Recursos identificados para su estudio:
- Documentación de GTK y su manejo de eventos y concurrencia.
- Ejemplos de código en Python sobre manejo de errores y comunicación cliente-servidor
- repositorio de la practica para revisar y actualizar la implementación.
- Indicaciones de la profesora sobre buenas prácticas en la gestión de errores y E/S concurrente


Recursos empleados en la semana 3
---------------------------------
Descripcion del recurso:
Durante esta semana trabajamos principalmente la implementacion de validaciones y mensajes de error, añadiendo widgets específicos para mostrar feedback a la usuaria. También se incorporaron nuevas funcionalidades en la gestión de gastos, como añadir amigos, eliminación de gastos y la actualización automática de creditos en el apartado de gastos. Además, se revisó parte del código para mejorar su estructura mediante herencia, favoreciendo la reutilización y organización del mismo

Utilidad y aplicación a la práctica:
Estas mejoras permitieron aumentar la robustez y usabilidad de la aplicación, evitando fallos por entradas erroneas y garantizando un funcionamiento fluido incluso durante las operaciones de E/S. Desde mi rol como curadora–traductora, participe en la revisión terminológica y documental, asegurando la claridad de los mensajes de error y la coherencia entre los nombres de los componentes y su documentación.


Conclusion:
----------
En esta tercera semana se consolidó la parte funcional del proyecto, logrando una interfaz más estable y responsiva. Se avanzó en el manejo de concurrencia y la gestión de errores, acercando el sistema a su versión final. Desde mi rol, continué apoyando la coherencia documental y lingüística, contribuyendo a mantener un código claro y una documentación precisa y alineada con los objetivos del equipo



Objetivos de aprendizaje de la semana 4
---------------------------------------

Concepto, herramientas:
Durante la cuarta semana, el objetivo fue comprender y aplicar los princiipios de internacionalización (i18n) en interfaces graficas de usuario, adaptando la aplicación a distintos entornos linguísticos y regionales. Además, se buscó afianzar el manejo correcto de la concurrencia y la gestión de errores, completando los aspectos que la semana anterior habian quedado pendientes. El propósito fue lograr una aplicación más versatil, robusta y accesible para diferentes usuarias

Recursos identificados para su estudio
- Documentación sobre internacionalización en Python (módulo gettext y configuración de locale)
- Ejemplos y materiales complementarios proporcionados por la profesora
- Código base de la práctica para integrar la internacionalización y adaptar el formato de números y fechas


Recursos empleados en la semana 4
---------------------------------
Descripción del recurso:
Durante esta semana, se completó la correcta gestion de la concurrencia y la detección de errores pendientes de la semana anterior, logrando que la aplicación muestre mensajes claros cuando el servidor no se encuentra en ejecución. Tambien desarrollamos el apartado de la internacionalización completa de la interfaz, permitiendo que esta se adapte automáticamente a la configuración regional del usuairo. Se localizo la aplicación a un idioma distinto del original, validando la funcionalidad del sistema de traducción para que se muestren conforme al formato local.
Además, se realizaron pequeñas mejoras funcionales, como la eliminación de duplicados en la función de añadir amigos, evitando que aparezca la opción de añadir participantes que ya forman parte de un gasto. Finalmente, se llevó a cabo una documentación exhaustiva del código, añadiendo comentarios explicativos para facilitar la comprensión y mantenimiento del proyecto por personas ajenas al equipo.

Utilidad y aplicación a la practica:
La incorporación de la internacionalización amplía significativamente el alcance de la aplicación, permitiendo su uso en distintos contextos culturales y lingüísticos. La mejora en la gestión de concurrencia y errores contribuye a una experiencia de usuario más fluida y confiable. Desde mi rol como curadora–traductora, participé activamente en la revisión lingüística y documental, asegurando la coherencia terminológica entre las versiones de la interfaz y la claridad de los mensajes en distintos idiomas


Conclusión
----------
En esta cuarta semana se completaron los aspectos técnicos pendientes y se alcanzó un hito importante con la internacionalización de la aplicación. El sistema ahora es más estable, adaptable y comprensible, tanto para usuarias de diferentes locales como para futuras personas desarrolladoras. La mejora en la gestión de errores y la documentación refuerza la mantenibilidad y profesionalidad del proyecto. Desde mi función, consolidé la parte lingüística y documental, garantizando una comunicación clara, coherente y alineada con los objetivos generales del equipo
