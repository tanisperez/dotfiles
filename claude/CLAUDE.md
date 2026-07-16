# CLAUDE.md (Global)

## Idioma

Responde siempre en español, salvo cuando el contexto técnico (código, nombres de variables, mensajes de error) lo requiera en inglés.

## Comportamiento

Antes de añadir algo nuevo a este archivo CLAUDE.md global, pregúntame primero.

Pedir permiso explícito antes de hacer `git push`. No hacerlo de forma autónoma salvo que el usuario lo indique expresamente en ese momento. `git commit` no requiere confirmación previa.

## Desarrollo web — CSS primero

En desarrollo web, el diseño responsivo y los cambios visuales deben hacerse **siempre en CSS** (media queries, flex, grid). Nunca usar JavaScript para detectar el ancho de ventana y cambiar estilos — eso produce flashes de layout durante la hidratación.

## Repositorio de documentación

La carpeta `~/dev/doc` es el repositorio global de documentación. Cuando el usuario lo pida o cuando lo consideres necesario, crea ahí ficheros Markdown con documentación sobre algún tema o una sesión de trabajo. Tienes permisos de lectura y escritura totales sobre esa carpeta.

## Proyectos de negocio (apps Expo)

El objetivo a medio plazo es crear N aplicaciones con Expo + React Native para monetizarlas como idea de negocio, buscando una fuente de ingresos recurrente, abundante o incluso un pelotazo.

Proyectos actuales:
- `~/dev/seqix`
- `~/dev/pairix`

Tienes permiso de lectura total sobre ambos sin pedir permiso, aunque no sean el directorio de trabajo activo.

`~/dev/chess-counter` está aparcado temporalmente para centrar el foco en `pairix`. Sigue siendo un proyecto Expo válido y sus convenciones son las mismas, pero no se trabaja en él por ahora.

Se irán creando nuevos proyectos de este tipo en el futuro. La base de código de los proyectos existentes sirve como punto de partida (boilerplate) para arrancarlos rápido, así que cuando el usuario inicie uno nuevo, considera reutilizar patrones, configuración y estructura ya validados en `seqix` y `pairix`.
