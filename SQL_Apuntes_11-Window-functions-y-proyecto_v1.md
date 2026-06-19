# Módulo 11 — Funciones de ventana, CTEs y proyecto final

El último módulo cubre las dos herramientas que marcan el nivel avanzado de SQL: las funciones de ventana (cálculos que miran un grupo de filas sin colapsarlas) y las CTEs (`WITH`, para partir consultas complejas en pasos legibles). Después, un proyecto que junta todo el curso. Si lo completas, manejas SQL de verdad.

> Base de datos `tienda`. Las funciones de ventana requieren SQLite 3.25 o superior (2018); cualquier instalación reciente las tiene.

## El problema que resuelven las funciones de ventana

`GROUP BY` resume y colapsa: de seis clientes te deja tres ciudades. Pero a veces quieres el resumen **y** las filas individuales a la vez. "Muéstrame cada pedido junto al total gastado por su cliente", o "numera los productos por precio dentro de su categoría". Eso `GROUP BY` no lo hace, porque destruye las filas. Las funciones de ventana sí: calculan sobre un conjunto de filas (la "ventana") sin colapsarlas.

## La sintaxis: OVER y PARTITION BY

Una función de ventana se escribe con `OVER (...)`. Dentro, `PARTITION BY` define los grupos (como un `GROUP BY` que no colapsa) y `ORDER BY` ordena dentro de cada grupo:

```sql
SELECT nombre, categoria, precio,
       AVG(precio) OVER (PARTITION BY categoria) AS precio_medio_categoria
FROM productos;
-- Cada producto conserva su fila, y al lado aparece la media de SU categoría
```

Compáralo con `GROUP BY`: aquel te habría dado una fila por categoría. Aquí tienes las ocho filas de productos, cada una con la media de su categoría pegada al lado. Esa es la diferencia esencial.

## Numerar y rankear: ROW_NUMBER, RANK, DENSE_RANK

Estas funciones asignan un número de orden a cada fila dentro de su ventana. Sirven para "el más caro de cada categoría", "los 3 primeros de cada grupo":

```sql
SELECT nombre, categoria, precio,
       ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY precio DESC) AS posicion
FROM productos;
```

Para cada categoría, numera los productos del más caro al más barato: el más caro recibe 1, el siguiente 2, etc. Diferencias entre las tres funciones de ranking:

- `ROW_NUMBER()` — numera 1, 2, 3... sin repetir, aunque haya empates.
- `RANK()` — empates comparten número, y deja huecos (1, 1, 3).
- `DENSE_RANK()` — empates comparten número, sin huecos (1, 1, 2).

Para quedarte solo con "el primero de cada grupo", envuelves esto en una subconsulta o CTE y filtras `posicion = 1` (lo verás en el proyecto).

## Totales acumulados y comparar con la fila anterior

`ORDER BY` dentro del `OVER` también permite cálculos acumulados y mirar filas vecinas:

```sql
-- Suma acumulada de pedidos por fecha
SELECT fecha, id,
       COUNT(*) OVER (ORDER BY fecha) AS pedidos_hasta_aqui
FROM pedidos;

-- Comparar cada pedido con el anterior del mismo cliente
SELECT cliente_id, fecha,
       LAG(fecha) OVER (PARTITION BY cliente_id ORDER BY fecha) AS pedido_anterior
FROM pedidos;
```

`LAG()` trae el valor de la fila anterior; `LEAD()`, el de la siguiente. Son perfectas para calcular diferencias entre periodos ("¿cuántos días entre un pedido y el siguiente?"). No las memorices ahora; basta con saber que existen y para qué sirven.

## CTE: partir una consulta en pasos con WITH

Cuando una consulta se vuelve un monstruo de subconsultas anidadas, una CTE (Common Table Expression) la ordena. `WITH` define un resultado temporal con nombre, que usas después como si fuera una tabla. Hace el código legible de arriba abajo:

```sql
WITH gasto_cliente AS (
    SELECT c.id, c.nombre, SUM(lp.cantidad * pr.precio) AS gasto
    FROM clientes AS c
    JOIN pedidos AS p        ON c.id = p.cliente_id
    JOIN lineas_pedido AS lp ON p.id = lp.pedido_id
    JOIN productos AS pr     ON lp.producto_id = pr.id
    GROUP BY c.id
)
SELECT nombre, gasto
FROM gasto_cliente
WHERE gasto > 200
ORDER BY gasto DESC;
```

La CTE `gasto_cliente` calcula el gasto por cliente; la consulta final la filtra y ordena. Es lo mismo que una subconsulta en el `FROM`, pero se lee mucho mejor: defines los pasos arriba y los combinas abajo. Puedes encadenar varias CTEs separadas por comas, construyendo un razonamiento por etapas.

> **En MariaDB/MySQL:** las CTEs (`WITH`) y las funciones de ventana existen desde MySQL 8.0 y MariaDB 10.2. En versiones anteriores no, así que en sistemas antiguos tendrás que usar subconsultas. La sintaxis es idéntica a la de SQLite.

## CTE + función de ventana: el patrón "top N por grupo"

Juntando ambas herramientas resuelves uno de los problemas clásicos de SQL: "el producto más caro de cada categoría". Numeras con una función de ventana dentro de una CTE y filtras la posición 1:

```sql
WITH ranking AS (
    SELECT nombre, categoria, precio,
           ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY precio DESC) AS pos
    FROM productos
)
SELECT nombre, categoria, precio
FROM ranking
WHERE pos = 1;
```

Guárdate este patrón: aparece constantemente en informes reales.

---

## Proyecto final

Vas a analizar la base de datos de la tienda de principio a fin, como haría un analista. Usa la base `tienda` del módulo 02 (reejecútala para partir de datos limpios). Resuelve cada pregunta; las soluciones están al final, pero pelea cada una antes de mirar.

### Tareas

**P1 — Inventario.** Lista todos los productos con su valor de inventario (precio × stock), ordenados de mayor a menor.

**P2 — Clientes activos.** Muestra cada cliente con su número de pedidos, incluyendo a los que no han hecho ninguno (deben aparecer con 0).

**P3 — Facturación por cliente.** ¿Cuánto ha facturado la tienda por cada cliente? Ordena de mayor a menor. Incluye solo clientes con pedidos.

**P4 — Producto estrella.** ¿Cuál es el producto más vendido en unidades?

**P5 — Ticket medio por ciudad.** Calcula el importe medio por pedido agrupado por la ciudad del cliente. (Necesitas el importe total de cada pedido y luego promediar por ciudad.)

**P6 — Ranking por categoría.** Usando una función de ventana, muestra el producto más caro de cada categoría.

**P7 — Facturación mensual.** Calcula la facturación total por mes (usa `STRFTIME('%Y-%m', fecha)` sobre la fecha del pedido).

**P8 — Clientes VIP.** Con una CTE, identifica los clientes que han gastado más de 300 € en total.

**P9 — Productos sin vender.** Lista los productos que no se han vendido nunca.

**P10 — Informe con vista.** Crea una vista `informe_ventas` que reúna, por producto: categoría, unidades vendidas e ingresos totales. Consúltala ordenando por ingresos.

---

<details>
<summary>Soluciones del proyecto</summary>

**P1**
```sql
SELECT nombre, precio * stock AS valor_inventario
FROM productos
ORDER BY valor_inventario DESC;
```

**P2**
```sql
SELECT c.nombre, COUNT(p.id) AS num_pedidos
FROM clientes AS c
LEFT JOIN pedidos AS p ON c.id = p.cliente_id
GROUP BY c.id
ORDER BY num_pedidos DESC;
-- Iván aparece con 0
```

**P3**
```sql
SELECT c.nombre, ROUND(SUM(lp.cantidad * pr.precio), 2) AS facturado
FROM clientes AS c
JOIN pedidos AS p        ON c.id = p.cliente_id
JOIN lineas_pedido AS lp ON p.id = lp.pedido_id
JOIN productos AS pr     ON lp.producto_id = pr.id
GROUP BY c.id
ORDER BY facturado DESC;
```

**P4**
```sql
SELECT pr.nombre, SUM(lp.cantidad) AS unidades
FROM lineas_pedido AS lp
JOIN productos AS pr ON lp.producto_id = pr.id
GROUP BY pr.id
ORDER BY unidades DESC
LIMIT 1;
```

**P5**
```sql
WITH importe_pedido AS (
    SELECT p.id, p.cliente_id, SUM(lp.cantidad * pr.precio) AS importe
    FROM pedidos AS p
    JOIN lineas_pedido AS lp ON p.id = lp.pedido_id
    JOIN productos AS pr     ON lp.producto_id = pr.id
    GROUP BY p.id
)
SELECT c.ciudad, ROUND(AVG(ip.importe), 2) AS ticket_medio
FROM importe_pedido AS ip
JOIN clientes AS c ON ip.cliente_id = c.id
GROUP BY c.ciudad
ORDER BY ticket_medio DESC;
```

**P6**
```sql
WITH ranking AS (
    SELECT nombre, categoria, precio,
           ROW_NUMBER() OVER (PARTITION BY categoria ORDER BY precio DESC) AS pos
    FROM productos
)
SELECT nombre, categoria, precio FROM ranking WHERE pos = 1;
```

**P7**
```sql
SELECT STRFTIME('%Y-%m', p.fecha) AS mes,
       ROUND(SUM(lp.cantidad * pr.precio), 2) AS facturacion
FROM pedidos AS p
JOIN lineas_pedido AS lp ON p.id = lp.pedido_id
JOIN productos AS pr     ON lp.producto_id = pr.id
GROUP BY mes
ORDER BY mes;
```

**P8**
```sql
WITH gasto AS (
    SELECT c.id, c.nombre, SUM(lp.cantidad * pr.precio) AS total
    FROM clientes AS c
    JOIN pedidos AS p        ON c.id = p.cliente_id
    JOIN lineas_pedido AS lp ON p.id = lp.pedido_id
    JOIN productos AS pr     ON lp.producto_id = pr.id
    GROUP BY c.id
)
SELECT nombre, total FROM gasto WHERE total > 300 ORDER BY total DESC;
```

**P9**
```sql
SELECT pr.nombre
FROM productos AS pr
LEFT JOIN lineas_pedido AS lp ON pr.id = lp.producto_id
WHERE lp.id IS NULL;
-- la Webcam
```

**P10**
```sql
CREATE VIEW informe_ventas AS
SELECT pr.nombre, pr.categoria,
       COALESCE(SUM(lp.cantidad), 0) AS unidades,
       ROUND(COALESCE(SUM(lp.cantidad * pr.precio), 0), 2) AS ingresos
FROM productos AS pr
LEFT JOIN lineas_pedido AS lp ON pr.id = lp.producto_id
GROUP BY pr.id;

SELECT * FROM informe_ventas ORDER BY ingresos DESC;
```

</details>

---

## Hasta aquí llega el curso

Empezaste sin saber qué era una tabla y terminas escribiendo funciones de ventana y CTEs sobre una base de datos con cuatro tablas relacionadas. Lo que falta ya no es SQL básico: es practicar con datos reales y, si sigues, dar el salto a un motor profesional.

El siguiente paso natural: monta MariaDB (o MySQL), importa un conjunto de datos que te interese y hazle las mismas preguntas que al proyecto. Ahí verás de cerca lo que SQLite te ocultaba —usuarios y permisos, `EXPLAIN` detallado, procedimientos almacenados— y consolidarás todo lo de este curso en un entorno de verdad.
