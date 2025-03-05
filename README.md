# WeatherApp
Elixir
Se requiere una version superior a la 1.15.

Phoenix:
Es necesario Phoenix 1.7 o superior.

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).



### Descripción del Problema y la Solución
Problema Resuelto:
El objetivo era desarrollar un sistema que permita consultar el clima de cualquier ciudad del mundo y gestionar una lista de ciudades favoritas. La solución debía mostrar la información del clima actual (temperatura, mínima, máxima y descripción) y los pronósticos:

* Por hora: para las próximas 24 horas.
* Diario: el clima mínimo y máximo para el resto de la semana.

Solución:
Se implementó una aplicación web utilizando Elixir y Phoenix LiveView. La aplicación integra la API de OpenWeather para obtener datos en tiempo real, utiliza un contexto de Ecto para persistir las ciudades favoritas en una base de datos PostgreSQL y ofrece una interfaz interactiva que actualiza la información sin recargar la página.


### Explicación de la Arquitectura Elegida Backend y API:

Se eligió Phoenix y Elixir ya que al ser la BEAM su maquina virtual puede cubrir los siguientes requierimientos no funcionales que son parte de las caracteristicas arquitecnicas de un sistema robusto:

* Performance
* Scalabilidad
* Fiabilidad
* Tolerancia a fallos
* Seguridad
* Alta disponibilidad
* Baja latencia 

Este proyecto incorpora varios principios de diseño y un estilo arquitectónico que facilitan su mantenimiento y escalabilidad:

Principios de Diseño:

### Separación de Concerns y Responsabilidad Única:
Cada módulo se encarga de una tarea específica. Por ejemplo, el módulo ***WeatherAPI*** se dedica a interactuar con la API externa, el contexto Favorites se ocupa de la persistencia de datos y la LiveView gestiona la interacción y la presentación. Esto hace que cada parte sea más fácil de entender, testear y modificar sin afectar a otras.

### Modularidad y Programación Funcional:
El uso de funciones puras y la transformación de datos mediante structs tipados (con TypedStruct) refuerzan la claridad y reducen los efectos secundarios, lo que es típico en la programación funcional.


### Inyección de Dependencias:
Aunque en un entorno dinámico se usa la configuración en tiempo de ejecución, la estructura permite sustituir o simular dependencias (por ejemplo, con mocks o Bypass en los tests).

Se creó el módulo ***Weather.WeatherAPI*** para centralizar todas las llamadas a la API de OpenWeather (obtener clima actual, forecast por nombre y por coordenadas, y búsqueda de ciudades mediante geocoding).


* Persistencia:
Se utiliza Ecto y PostgreSQL para almacenar los favoritos. El contexto Favorites (junto con el esquema City) gestiona el almacenamiento del nombre de la ciudad y la información completa (clima actual y forecast).

* Interfaz en Tiempo Real:
La aplicación utiliza Phoenix LiveView para ofrecer una experiencia interactiva. Las funciones del LiveView gestionan eventos para búsqueda, agregar a favoritos y seleccionar ciudades, actualizando la vista en tiempo real.
Supervisor y Librerías:
Finch se integra en el árbol de supervisión para manejar las peticiones HTTP. Además, se utilizan Jason para el manejo de JSON y otras dependencias estándar de Phoenix.
Esta arquitectura modular permite separar las responsabilidades y facilita la extensión o modificación de funcionalidades sin afectar otros componentes.

### Trade-offs en la Implementación Actual:

Persistencia vs. Consulta Directa:
Se persisten los datos del clima y forecast al agregar una ciudad a favoritos para evitar llamadas redundantes a la API. Sin embargo, esta estrategia puede resultar en información obsoleta si no se refresca periódicamente.

### Si Tuviera Más Tiempo, Mejoraría:

* Caché y Actualización de Datos:
Implementar mecanismos de caché y refresco de datos para mantener la información actualizada sin hacer llamadas excesivas a la API.

* Validaciones y Seguridad:
Añadir validaciones más robustas en la entrada del usuario y mejorar la gestión de errores para prevenir posibles problemas de seguridad.

* UX/UI:
Mejorar la interfaz gráfica y la experiencia de usuario, incorporando estilos CSS avanzados y feedback visual en cada acción.

* Manejo de Errores:
Refinar el manejo de errores tanto en la API como en la interfaz, mostrando mensajes claros y ofreciendo reintentos en caso de fallos.


Beneficios de Usar TypedStruct
Documentación y Tipado:
Permite documentar claramente la forma de los datos y, junto con herramientas de análisis estático, puede ayudar a detectar errores en tiempo de compilación.

Mantenibilidad:
Al tener estructuras bien definidas, es más sencillo razonar sobre el código y realizar cambios sin afectar otras partes del sistema.

Claridad en la Lógica de Negocio:
Al convertir las respuestas de la API a estructuras tipadas, se garantiza que el resto de la aplicación trabaje con datos consistentes.


### Documentación

Hay documentación adicional de la arquitectura y flujos del proyecto en ./weather_app/documentacion/
