# Módulo 10 — Diseñar bien: normalización, índices y vistas

Saber consultar es la mitad. La otra mitad es diseñar la base de datos para que las consultas sean posibles, rápidas y los datos no se corrompan. Este módulo cubre la normalización (cómo repartir los datos en tablas), los índices (cómo acelerar las búsquedas) y las vistas (cómo guardar consultas para reutilizarlas). Es el módulo que separa a quien usa bases de datos de quien las diseña, y donde MariaDB empieza a brillar sobre SQLite.

## El problema: una tabla gigante es una mala idea

Imagina que guardas todo en una sola tabla:

```
pedidos_todo
┌────┬──────────┬─────────┬──────────┬───────────┬────────┐
│ id │ cliente  │ ciudad  │ producto │ categoria │ precio │
├────┼──────────┼─────────┼──────────┼───────────┼────────┤
│ 10 │ Ada      │ Madrid  │ Portátil │ Informát. │ 899    │
│ 10 │ Ada      │ Madrid  │ Ratón    │ Periféric.│ 19.90  │
│ 11 │ Ada      │ Madrid  │ Monitor  │ Pantallas │ 199    │
└────┴──────────┴─────────┴──────────┴───────────┴────────┘
```

Tres problemas, los tres graves:

- **Redundancia:** "Ada" y "Madrid" se repiten en cada fila. Desperdicias espacio y, peor, si Ada se muda tienes que cambiarlo en mil sitios.
- **Anomalías de actualización:** si corriges la ciudad de Ada en una fila y olvidas otra, tienes a Ada viviendo en dos ciudades a la vez. Datos incoherentes.
- **Anomalías de inserción/borrado:** no puedes registrar un cliente nuevo hasta que haga un pedido, ni un producto hasta que se venda, porque cada fila mezcla todo.

La normalización resuelve esto repartiendo los datos en tablas relacionadas, que es justo el diseño de nuestra tienda.

## Normalización: tres formas normales

La normalización es un proceso con reglas (las "formas normales"). Las tres primeras cubren el 99% de los casos prácticos.

**Primera Forma Normal (1FN): valores atómicos.** Cada celda contiene un solo valor, no listas. Mal: una columna `productos` con el texto "Portátil, Ratón, Monitor". Bien: una fila por producto. Nada de meter varios valores separados por comas en una celda.

**Segunda Forma Normal (2FN): sin dependencias parciales.** Estás en 1FN y, además, cada columna depende de la clave primaria completa, no de una parte. Esto importa cuando la clave es compuesta (varias columnas). Si una columna depende solo de parte de la clave, va a otra tabla.

**Tercera Forma Normal (3FN): sin dependencias transitivas.** Estás en 2FN y ninguna columna depende de otra columna que no sea la clave. Ejemplo: si en `productos` guardaras `categoria_id` y `categoria_nombre`, el nombre depende del id de categoría, no del producto. La solución: una tabla `categorias` aparte, y en `productos` solo el `categoria_id`.

La regla intuitiva que resume las tres: **cada dato debe estar en un solo sitio, y cada tabla debe hablar de una sola cosa.** Clientes en `clientes`, productos en `productos`, y las relaciones en tablas que las conecten. Si te encuentras copiando el mismo dato en muchas filas, probablemente falta una tabla.

## Cuándo desnormalizar a propósito

La normalización reduce errores, pero a veces obliga a muchos JOINs, que cuestan tiempo. En sistemas con millones de lecturas, a veces se *desnormaliza* a conciencia: se duplica algún dato para evitar un JOIN costoso. Es una decisión de ingeniería, no una excusa para diseñar mal desde el principio. Primero normaliza; desnormaliza solo cuando midas un problema real de rendimiento.

## Índices: acelerar las búsquedas

Sin índice, buscar `WHERE ciudad = 'Madrid'` obliga a la base de datos a revisar todas las filas una por una (un *full scan*). Con pocas filas da igual; con millones, es lentísimo. Un índice es como el índice alfabético de un libro: una estructura ordenada que permite encontrar filas sin recorrer toda la tabla.

```sql
CREATE INDEX idx_clientes_ciudad ON clientes(ciudad);
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
```

Ahora las consultas que filtran o unen por esas columnas vuelan. La clave primaria ya tiene un índice automático; los que sueles añadir a mano son sobre las **claves foráneas** (se usan en cada JOIN) y sobre las **columnas por las que filtras o buscas mucho**.

Los índices no son gratis: ocupan espacio y ralentizan un poco las inserciones y actualizaciones (hay que mantenerlos al día). La regla práctica: indexa las columnas que aparecen en `WHERE`, `JOIN` y `ORDER BY` de tus consultas frecuentes, y no indexes por indexar. Un índice que nadie usa solo estorba.

```sql
DROP INDEX idx_clientes_ciudad;   -- así se elimina uno que no aporta
```

## Vistas: guardar una consulta con nombre

Una vista es una consulta guardada que se comporta como si fuera una tabla. No almacena datos: cada vez que la consultas, ejecuta su `SELECT` por debajo. Sirve para encapsular consultas complejas y reutilizarlas sin reescribirlas:

```sql
CREATE VIEW resumen_clientes AS
SELECT c.id, c.nombre, c.ciudad,
       COUNT(p.id) AS num_pedidos
FROM clientes AS c
LEFT JOIN pedidos AS p ON c.id = p.cliente_id
GROUP BY c.id;
```

A partir de ahí, la consultas como a una tabla normal:

```sql
SELECT * FROM resumen_clientes WHERE num_pedidos > 1;
SELECT * FROM resumen_clientes ORDER BY num_pedidos DESC;
```

Las vistas tienen dos grandes usos: simplificar (esconder un JOIN de cuatro tablas detrás de un nombre claro) y dar acceso controlado (mostrar a ciertos usuarios solo algunas columnas, sin enseñarles la tabla entera). Para eliminar una vista: `DROP VIEW resumen_clientes;`.

> **En MariaDB/MySQL:** las vistas funcionan igual y son muy usadas en producción. Allí, además, tienes herramientas de las que SQLite carece: usuarios con permisos granulares (`GRANT`/`REVOKE`), procedimientos almacenados, triggers más completos y el comando `EXPLAIN` para ver cómo el motor ejecuta una consulta y si está usando tus índices. Cuando pases a un proyecto real, MariaDB es el entorno donde todo esto cobra sentido.

## Diagnóstico: ¿está usando mi índice?

Para saber si una consulta aprovecha un índice o hace un escaneo completo, antepón `EXPLAIN QUERY PLAN`:

```sql
EXPLAIN QUERY PLAN
SELECT * FROM clientes WHERE ciudad = 'Madrid';
```

Si ves "SCAN" recorre toda la tabla; si ves "SEARCH ... USING INDEX" está usando el índice. Es la forma de comprobar que tus índices sirven para algo. En MariaDB el comando es `EXPLAIN` a secas y da mucho más detalle.

---

## Ejercicios

**10.1** — Tienes una tabla mal diseñada `matriculas(alumno, dni_alumno, curso, profesor_curso)` donde cada matrícula repite el profesor del curso. Identifica qué problemas de redundancia tiene y propón cómo separarla en tablas normalizadas.

**10.2** — Crea un índice sobre la columna `categoria` de la tabla `productos`. Explica en qué tipo de consulta ayudaría.

**10.3** — Crea una vista llamada `productos_caros` que muestre el nombre, la categoría y el precio de los productos que cuestan más de 100 €. Luego consúltala ordenando por precio.

**10.4** — Crea una vista `ventas_por_producto` que muestre, para cada producto, el total de unidades vendidas (incluyendo los no vendidos con 0). Consúltala para ver el producto más vendido.

**10.5** — Usa `EXPLAIN QUERY PLAN` sobre una consulta que filtre `pedidos` por `cliente_id`, antes y después de crear un índice sobre `cliente_id`. Observa la diferencia.

**10.6** — Razona: ¿por qué guardar `categoria_nombre` repetido en la tabla `productos` (en vez de un `categoria_id` que apunte a una tabla `categorias`) viola la 3FN? ¿Qué problema concreto causaría al renombrar una categoría?

---

<details markdown="1">
<summary>Soluciones</summary>

**10.1** — La tabla repite `dni_alumno` en cada matrícula del mismo alumno y `profesor_curso` en cada matrícula del mismo curso: redundancia. Si un curso cambia de profesor, hay que actualizar muchas filas (anomalía de actualización). Normalizada:
```
alumnos (id PK, nombre, dni)
cursos  (id PK, nombre, profesor)
matriculas (id PK, alumno_id FK, curso_id FK)
```
Cada dato vive en un solo sitio: el profesor de un curso se cambia en una fila de `cursos`.

---

**10.2**
```sql
CREATE INDEX idx_productos_categoria ON productos(categoria);
```
Ayuda en consultas como `SELECT * FROM productos WHERE categoria = 'Periféricos'` y en los `GROUP BY categoria`, porque evita recorrer toda la tabla.

---

**10.3**
```sql
CREATE VIEW productos_caros AS
SELECT nombre, categoria, precio FROM productos WHERE precio > 100;

SELECT * FROM productos_caros ORDER BY precio DESC;
-- Portátil, Tablet, Monitor
```

---

**10.4**
```sql
CREATE VIEW ventas_por_producto AS
SELECT pr.nombre, COALESCE(SUM(lp.cantidad), 0) AS unidades
FROM productos AS pr
LEFT JOIN lineas_pedido AS lp ON pr.id = lp.producto_id
GROUP BY pr.id;

SELECT * FROM ventas_por_producto ORDER BY unidades DESC;
```

---

**10.5**
```sql
EXPLAIN QUERY PLAN SELECT * FROM pedidos WHERE cliente_id = 1;
-- antes: SCAN pedidos
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
EXPLAIN QUERY PLAN SELECT * FROM pedidos WHERE cliente_id = 1;
-- después: SEARCH pedidos USING INDEX idx_pedidos_cliente
```

---

**10.6** — Viola la 3FN porque `categoria_nombre` no depende del producto, sino de la categoría: es una dependencia transitiva (producto → categoría → nombre de categoría). El problema concreto: al renombrar una categoría ("Periféricos" → "Accesorios de entrada"), tendrías que actualizar todas las filas de productos de esa categoría, y si te dejas una, quedarían dos nombres para la misma categoría. Con una tabla `categorias` aparte, el nombre se cambia en una sola fila.

</details>
