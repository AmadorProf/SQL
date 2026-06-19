# Módulo 08 — Subconsultas: una consulta dentro de otra

Una subconsulta es un `SELECT` metido dentro de otro `SELECT`. Sirve para preguntas que necesitan un paso intermedio: "los productos más caros que la media" (primero calcula la media, luego compara), "los clientes que han pedido algo" (primero averigua quiénes, luego fíltralos). Es la forma de encadenar razonamientos en una sola consulta.

> Base de datos `tienda`.

## La idea: el resultado de una consulta alimenta a otra

"¿Qué productos cuestan más que la media?" no se puede hacer de un tirón, porque primero necesitas saber cuál es la media. La subconsulta calcula ese valor y la consulta exterior lo usa:

```sql
SELECT nombre, precio
FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos);
```

La parte entre paréntesis, `(SELECT AVG(precio) FROM productos)`, se ejecuta primero y devuelve un número (el precio medio). Luego la consulta de fuera compara cada producto contra ese número. Léelo de dentro hacia fuera.

## Subconsulta que devuelve un solo valor

Cuando la subconsulta devuelve un único valor (un número, una fecha), la usas con operadores de comparación normales (`=`, `>`, `<`):

```sql
-- El producto más caro
SELECT nombre, precio
FROM productos
WHERE precio = (SELECT MAX(precio) FROM productos);

-- Clientes dados de alta antes que Marta
SELECT nombre
FROM clientes
WHERE fecha_alta < (SELECT fecha_alta FROM clientes WHERE nombre = 'Marta');
```

## Subconsulta que devuelve una lista: IN

Cuando la subconsulta devuelve varios valores (una columna entera), la combinas con `IN`. "¿Qué clientes han hecho algún pedido?":

```sql
SELECT nombre
FROM clientes
WHERE id IN (SELECT cliente_id FROM pedidos);
-- Ada, Luis, Marta, Juan, Eva  (todos menos Iván)
```

La subconsulta `(SELECT cliente_id FROM pedidos)` devuelve la lista de ids que han pedido algo; la consulta exterior se queda con los clientes cuyo id está en esa lista.

Y su negación, `NOT IN`, para lo contrario. "¿Qué clientes NO han pedido nada?":

```sql
SELECT nombre
FROM clientes
WHERE id NOT IN (SELECT cliente_id FROM pedidos);
-- Iván
```

> **Cuidado con NOT IN y los NULL:** si la subconsulta puede devolver algún `NULL`, `NOT IN` se comporta de forma rara y puede no devolver filas. Por seguridad, cuando uses `NOT IN` asegúrate de que la columna no tiene nulos, o usa `NOT EXISTS` (más abajo), que no tiene ese problema.

## EXISTS: comprobar si hay coincidencias

`EXISTS` devuelve verdadero si la subconsulta produce al menos una fila. Es la forma más robusta de preguntar "¿existe algo relacionado?". Se usa con una subconsulta *correlacionada*, que hace referencia a la consulta exterior:

```sql
-- Clientes que tienen al menos un pedido
SELECT nombre
FROM clientes AS c
WHERE EXISTS (SELECT 1 FROM pedidos AS p WHERE p.cliente_id = c.id);
```

Fíjate en `p.cliente_id = c.id`: la subconsulta menciona `c`, la tabla de fuera. Eso la hace *correlacionada*: se evalúa una vez por cada cliente, comprobando si ese cliente concreto tiene pedidos. El `SELECT 1` es una convención: con `EXISTS` da igual qué columnas pidas, solo importa si hay filas o no.

Su negación detecta huérfanos, igual que el `LEFT JOIN ... IS NULL` del módulo 07:

```sql
-- Clientes sin ningún pedido
SELECT nombre
FROM clientes AS c
WHERE NOT EXISTS (SELECT 1 FROM pedidos AS p WHERE p.cliente_id = c.id);
-- Iván
```

## Subconsulta en el FROM: una tabla temporal

Una subconsulta puede ir en el `FROM`, comportándose como una tabla temporal sobre la que sigues consultando. Útil cuando necesitas agregar y luego filtrar o agregar de nuevo:

```sql
-- A partir del gasto por cliente, quedarte con los que gastaron más de 200 €
SELECT *
FROM (
    SELECT p.cliente_id, SUM(lp.cantidad * pr.precio) AS gasto
    FROM pedidos AS p
    JOIN lineas_pedido AS lp ON p.id = lp.pedido_id
    JOIN productos AS pr     ON lp.producto_id = pr.id
    GROUP BY p.cliente_id
) AS gastos
WHERE gasto > 200;
```

La subconsulta del `FROM` calcula el gasto por cliente; la consulta exterior filtra ese resultado. Toda subconsulta en el `FROM` necesita un alias (aquí `gastos`), aunque no lo uses explícitamente.

## Subconsulta en el SELECT: un valor calculado por fila

También puede ir en la lista de columnas, devolviendo un valor calculado para cada fila. "Cada cliente con su número de pedidos":

```sql
SELECT c.nombre,
       (SELECT COUNT(*) FROM pedidos AS p WHERE p.cliente_id = c.id) AS num_pedidos
FROM clientes AS c;
```

Para cada cliente, la subconsulta cuenta sus pedidos. Es correlacionada (usa `c.id`). Muchas veces lo mismo se logra con un `LEFT JOIN` + `GROUP BY`, y suele ser más eficiente; pero la subconsulta en el `SELECT` se lee bien para un cálculo puntual.

## Subconsulta vs JOIN: ¿cuál uso?

A menudo puedes resolver lo mismo con un JOIN o con una subconsulta. Reglas prácticas:

- Si necesitas **mostrar columnas de las dos tablas**, usa JOIN. Una subconsulta con `IN` solo filtra; no te trae columnas de la otra tabla.
- Si solo necesitas **filtrar por existencia o pertenencia**, una subconsulta con `IN`/`EXISTS` suele leerse mejor.
- Para **comparar contra un valor agregado** (la media, el máximo), la subconsulta es el camino natural.

No hay una respuesta única. Escribe la versión que se entienda mejor y, si el rendimiento importa con muchos datos, prueba las dos.

---

## Ejercicios

**08.1** — Muestra los productos cuyo precio sea mayor que el precio medio de todos los productos.

**08.2** — Muestra el producto (o productos) más barato de la tabla.

**08.3** — Lista los nombres de los clientes que han hecho al menos un pedido, usando una subconsulta con `IN`.

**08.4** — Lista los clientes que no han hecho ningún pedido, usando `NOT EXISTS`.

**08.5** — Muestra los productos cuyo precio sea mayor que el precio medio de su MISMA categoría. (Pista: subconsulta correlacionada que calcula el `AVG` filtrando por la categoría del producto exterior.)

**08.6** — Para cada cliente, muestra su nombre y, mediante una subconsulta en el `SELECT`, cuántos pedidos ha hecho.

**08.7** — Usando una subconsulta en el `FROM`, calcula cuántas unidades se vendieron por categoría de producto y muestra solo las categorías que superan las 3 unidades.

**08.8** — Muestra los clientes dados de alta después del cliente con `id = 3` (Marta), comparando contra su fecha de alta con una subconsulta.

---

<details>
<summary>Soluciones</summary>

**08.1**
```sql
SELECT nombre, precio FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos);
-- La media es ~209.59: Portátil (899) y Tablet (349) la superan
```

**08.2**
```sql
SELECT nombre, precio FROM productos
WHERE precio = (SELECT MIN(precio) FROM productos);
-- Ratón (19.90)
```

**08.3**
```sql
SELECT nombre FROM clientes
WHERE id IN (SELECT cliente_id FROM pedidos);
```

**08.4**
```sql
SELECT nombre FROM clientes AS c
WHERE NOT EXISTS (SELECT 1 FROM pedidos AS p WHERE p.cliente_id = c.id);
-- Iván
```

**08.5**
```sql
SELECT nombre, categoria, precio
FROM productos AS p1
WHERE precio > (
    SELECT AVG(precio) FROM productos AS p2
    WHERE p2.categoria = p1.categoria
);
```
Para cada producto, la subconsulta calcula la media de su propia categoría y lo compara.

**08.6**
```sql
SELECT c.nombre,
       (SELECT COUNT(*) FROM pedidos AS p WHERE p.cliente_id = c.id) AS num_pedidos
FROM clientes AS c;
```

**08.7**
```sql
SELECT categoria, unidades
FROM (
    SELECT pr.categoria, SUM(lp.cantidad) AS unidades
    FROM lineas_pedido AS lp
    JOIN productos AS pr ON lp.producto_id = pr.id
    GROUP BY pr.categoria
) AS t
WHERE unidades > 3;
```

**08.8**
```sql
SELECT nombre, fecha_alta FROM clientes
WHERE fecha_alta > (SELECT fecha_alta FROM clientes WHERE id = 3);
-- Eva (2025-09-05), Iván (2025-11-20)
```

</details>
