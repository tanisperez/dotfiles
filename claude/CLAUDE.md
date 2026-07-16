# CLAUDE.md (Global)

## Idioma

Responde siempre en español, salvo cuando el contexto técnico (código, nombres de variables, mensajes de error) lo requiera en inglés.

## Comportamiento

Antes de añadir algo nuevo a este archivo CLAUDE.md global, pregúntame primero.

Pedir permiso explícito antes de hacer `git push`. No hacerlo de forma autónoma salvo que el usuario lo indique expresamente en ese momento. `git commit` no requiere confirmación previa.

## Principios de trabajo

Estos principios sesgan hacia la prudencia antes que hacia la velocidad. **Para tareas triviales, usa el criterio** — no los conviertas en preguntar por todo.

### Pensar antes de programar

- Explicita los supuestos. Si hay dudas, pregunta.
- Si el encargo admite varias interpretaciones, **exponlas en vez de elegir una en silencio**.
- Si existe un camino más simple, dilo. Discrepa cuando esté justificado.
- Si algo no se entiende, para y di qué es lo que no encaja. No lo rellenes suponiendo.

### Cambios quirúrgicos

- Toca **solo** lo que pide el encargo. No "mejores" código adyacente, comentarios ni formato.
- No refactorices lo que no está roto.
- Respeta el estilo existente, aunque tú lo harías de otra forma.
- El código muerto ajeno **se menciona, no se borra**. Los huérfanos que creen tus propios cambios (imports, variables, funciones que quedan sin uso) sí se limpian.
- La prueba: cada línea cambiada debe poder trazarse directamente a lo que se pidió.

### Simplicidad y verificación

- El mínimo código que resuelve el problema planteado. Nada especulativo: ni funcionalidad de más, ni abstracciones para un solo uso, ni configurabilidad que nadie pidió.
- Convierte el encargo en un criterio de éxito comprobable ("arregla el bug" → "escribe un test que lo reproduzca y haz que pase") y verifícalo antes de darlo por hecho. En proyectos Expo, la forma de verificar está en `RULES.md` §9 y §12.

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
