# Módulo 07 — JOINs: combinar datos de varias tablas

Los datos están repartidos en tablas: los nombres de cliente en `clientes`, sus pedidos en `pedidos`. Para responder "¿qué pedidos hizo Ada?" necesitas juntar ambas. Eso es un JOIN: combinar filas de varias tablas según una columna común. Es la operación que da sentido al modelo relacional y la que más distingue a quien sabe SQL. Tómate este módulo con calma.

> Base de datos `tienda`. Recuerda el esquema: `clientes` → `pedidos` → `lineas_pedido` → `productos`.

## El problema que resuelve el JOIN

La tabla `pedidos` guarda `cliente_id`, no el nombre:

```sql
SELECT * FROM pedidos;
-- id | cliente_id | fecha      | estado
-- 10 |     1      | 2025-07-01 | entregado    <- ¿quién es el cliente 1?
```

Para saber que el cliente 1 es Ada, hay que cruzar con `clientes`. El JOIN hace justo eso: empareja cada pedido con su cliente usando la relación `pedidos.cliente_id = clientes.id`.

## INNER JOIN: la unión básica

`INNER JOIN` combina filas de dos tablas donde la condición de enlace se cumple. Solo aparecen las filas que encuentran pareja en ambas tablas:

```sql
SELECT pedidos.id, clientes.nombre, pedidos.fecha
FROM pedidos
INNER JOIN clientes ON pedidos.cliente_id = clientes.id;
-- id | nombre | fecha
-- 10 | Ada    | 2025-07-01
-- 11 | Ada    | 2025-07-15
-- 12 | Luis   | 2025-08-03
-- ...
```

La línea clave es `ON pedidos.cliente_id = clientes.id`: dice por qué columnas se emparejan las dos tablas. Es casi siempre clave foránea contra clave primaria.

La palabra `INNER` es opcional: `JOIN` a secas significa `INNER JOIN`. Pero escribirla deja claras tus intenciones.

## Alias de tabla: escribir menos y leer mejor

Repetir `pedidos.` y `clientes.` cansa. Dale un alias corto a cada tabla y úsalo:

```sql
SELECT p.id, c.nombre, p.fecha, p.estado
FROM pedidos AS p
JOIN clientes AS c ON p.cliente_id = c.id;
```

`p` y `c` son alias de tabla. Con dos tablas casi da igual, pero cuando unas cuatro lo agradecerás. Es la forma estándar de escribir JOINs.

## Cuándo cualificar los nombres de columna

Si una columna existe en las dos tablas (como `id`), debes decir de cuál hablas: `p.id` o `c.id`. Si el nombre es único entre las tablas unidas (como `nombre`, que solo está en `clientes`), puedes escribirlo sin prefijo. Por claridad, muchos prefijan siempre. No es obligatorio, pero ayuda.

## LEFT JOIN: conservar las filas sin pareja

`INNER JOIN` descarta las filas que no encuentran pareja. A veces eso es justo lo que NO quieres. ¿Cuántos pedidos tiene cada cliente, **incluidos los que no tienen ninguno**? Con `INNER JOIN`, Iván (que no ha pedido nada) desaparecería. Con `LEFT JOIN`, se conserva:

```sql
SELECT c.nombre, p.id AS pedido
FROM clientes AS c
LEFT JOIN pedidos AS p ON c.id = p.cliente_id;
-- Ada   | 10
-- Ada   | 11
-- ...
-- Iván  | NULL    <- aparece, con NULL en pedido porque no tiene
```

`LEFT JOIN` conserva **todas** las filas de la tabla izquierda (la del `FROM`), y rellena con `NULL` las columnas de la derecha cuando no hay coincidencia. Es el JOIN que usarás para preguntas del tipo "todos los X, tengan o no Y".

Para encontrar precisamente a los que no tienen pareja, filtra por el `NULL`:

```sql
-- Clientes que nunca han hecho un pedido
SELECT c.nombre
FROM clientes AS c
LEFT JOIN pedidos AS p ON c.id = p.cliente_id
WHERE p.id IS NULL;
-- Iván
```

Este patrón ("LEFT JOIN + WHERE ... IS NULL") es la forma clásica de detectar huérfanos: clientes sin pedidos, productos sin ventas, alumnos sin matrícula.

## INNER vs LEFT: la diferencia en una frase

`INNER JOIN` se queda solo con las coincidencias. `LEFT JOIN` conserva todo lo de la izquierda aunque no haya coincidencia. Elige según la pregunta: si quieres "los que tienen relación", inner; si quieres "todos, completando donde se pueda", left.

> **RIGHT JOIN y FULL JOIN:** `RIGHT JOIN` es como `LEFT` pero conservando la tabla derecha (rara vez se usa: basta con dar la vuelta a las tablas y usar `LEFT`). `FULL OUTER JOIN` conserva todas las filas de ambas. **SQLite añadió soporte para ambos en la versión 3.39 (2022)**; en versiones anteriores no existían. MariaDB/MySQL soportan `RIGHT JOIN` desde siempre, pero MySQL no tiene `FULL JOIN` (se simula con `UNION`). En la práctica, el 95% de los JOINs son `INNER` o `LEFT`.

## Unir tres o más tablas

Para responder "¿qué productos compró Ada?" hay que recorrer la cadena entera: `clientes` → `pedidos` → `lineas_pedido` → `productos`. Encadenas un JOIN tras otro:

```sql
SELECT c.nombre AS cliente,
       p.id     AS pedido,
       pr.nombre AS producto,
       lp.cantidad
FROM clientes AS c
JOIN pedidos AS p        ON c.id = p.cliente_id
JOIN lineas_pedido AS lp ON p.id = lp.pedido_id
JOIN productos AS pr     ON lp.producto_id = pr.id
WHERE c.nombre = 'Ada';
```

Cada `JOIN` añade una tabla y dice cómo se enlaza con lo anterior. Lee la cadena de arriba abajo: de un cliente saco sus pedidos, de cada pedido sus líneas, de cada línea su producto. Así reconstruyes la información completa que el modelo guardó repartida.

## JOIN + GROUP BY: el combo de los informes

La potencia real aparece al combinar JOINs con agregación. "¿Cuánto ha gastado cada cliente en total?":

```sql
SELECT c.nombre,
       ROUND(SUM(lp.cantidad * pr.precio), 2) AS total_gastado
FROM clientes AS c
JOIN pedidos AS p        ON c.id = p.cliente_id
JOIN lineas_pedido AS lp ON p.id = lp.pedido_id
JOIN productos AS pr     ON lp.producto_id = pr.id
GROUP BY c.id
ORDER BY total_gastado DESC;
```

Une las cuatro tablas, multiplica cantidad por precio en cada línea, suma por cliente y ordena. Una pregunta de negocio respondida en una consulta. Este patrón (JOIN para reunir, GROUP BY para resumir) es el pan de cada día del análisis con SQL.

Un detalle: agrupamos por `c.id` y no por `c.nombre`. Si dos clientes se llamaran igual, agrupar por nombre los mezclaría; agrupar por la clave primaria nunca falla.

## Self-join: una tabla consigo misma

A veces una tabla se relaciona consigo misma (empleados con su jefe, categorías con su categoría padre). Se une la tabla a sí misma con dos alias distintos. No aparece en nuestra tienda, pero tenlo en el radar: si ves una tabla unida consigo misma con alias diferentes, eso es un self-join.

---

## Ejercicios

**07.1** — Muestra cada pedido junto al nombre del cliente que lo hizo (id de pedido, nombre, fecha, estado).

**07.2** — Muestra el nombre del cliente y la ciudad para cada pedido en estado 'entregado'.

**07.3** — Lista todos los clientes y, al lado, el id de sus pedidos. Asegúrate de que aparezcan también los clientes sin pedidos (usa `LEFT JOIN`).

**07.4** — Encuentra los clientes que nunca han hecho un pedido.

**07.5** — Muestra el detalle completo de cada línea de pedido: nombre del producto, cantidad y precio unitario.

**07.6** — Calcula el importe de cada línea de pedido (cantidad × precio) mostrando también el producto y el pedido al que pertenece.

**07.7** — ¿Cuánto ha gastado cada cliente en total? Ordénalos de mayor a menor gasto.

**07.8** — ¿Cuántas unidades se han vendido de cada producto? Incluye los productos que no se han vendido nunca (la Webcam no aparece en ningún pedido). Pista: parte de `productos` con un `LEFT JOIN`.

---

<details>
<summary>Soluciones</summary>

**07.1**
```sql
SELECT p.id, c.nombre, p.fecha, p.estado
FROM pedidos AS p
JOIN clientes AS c ON p.cliente_id = c.id;
```

**07.2**
```sql
SELECT c.nombre, c.ciudad
FROM pedidos AS p
JOIN clientes AS c ON p.cliente_id = c.id
WHERE p.estado = 'entregado';
-- Ada (Madrid) x2, Juan (Bilbao)
```

**07.3**
```sql
SELECT c.nombre, p.id AS pedido
FROM clientes AS c
LEFT JOIN pedidos AS p ON c.id = p.cliente_id;
```

**07.4**
```sql
SELECT c.nombre
FROM clientes AS c
LEFT JOIN pedidos AS p ON c.id = p.cliente_id
WHERE p.id IS NULL;
-- Iván
```

**07.5**
```sql
SELECT pr.nombre, lp.cantidad, pr.precio
FROM lineas_pedido AS lp
JOIN productos AS pr ON lp.producto_id = pr.id;
```

**07.6**
```sql
SELECT lp.pedido_id, pr.nombre, lp.cantidad,
       ROUND(lp.cantidad * pr.precio, 2) AS importe
FROM lineas_pedido AS lp
JOIN productos AS pr ON lp.producto_id = pr.id;
```

**07.7**
```sql
SELECT c.nombre, ROUND(SUM(lp.cantidad * pr.precio), 2) AS total
FROM clientes AS c
JOIN pedidos AS p        ON c.id = p.cliente_id
JOIN lineas_pedido AS lp ON p.id = lp.pedido_id
JOIN productos AS pr     ON lp.producto_id = pr.id
GROUP BY c.id
ORDER BY total DESC;
-- Ada lidera (compró un portátil de 899 y más)
```

**07.8**
```sql
SELECT pr.nombre, COALESCE(SUM(lp.cantidad), 0) AS unidades_vendidas
FROM productos AS pr
LEFT JOIN lineas_pedido AS lp ON pr.id = lp.producto_id
GROUP BY pr.id
ORDER BY unidades_vendidas DESC;
-- La Webcam aparece con 0 gracias al LEFT JOIN y al COALESCE
```
Sin el `LEFT JOIN`, la Webcam (que nunca se vendió) no saldría. El `COALESCE` convierte su `SUM` nulo en 0.

</details>
