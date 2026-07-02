# Módulo 06 — Agregar y agrupar: COUNT, SUM, AVG, GROUP BY y HAVING

Hasta ahora cada consulta devolvía filas individuales. La agregación da el salto: resume muchas filas en un número. "¿Cuántos clientes hay?", "¿cuánto suman las ventas?", "¿cuál es el precio medio por categoría?". Aquí SQL deja de ser una lupa para ser una calculadora. Es uno de los módulos que más se usa en informes reales.

> Base de datos `tienda`.

## Funciones de agregación: muchas filas, un resultado

Estas funciones toman una columna entera y devuelven un solo valor:

```sql
SELECT COUNT(*)     FROM clientes;   -- cuántas filas hay -> 6
SELECT COUNT(ciudad) FROM clientes;  -- cuántas tienen ciudad (ignora NULL)
SELECT SUM(stock)   FROM productos;  -- suma total de stock
SELECT AVG(precio)  FROM productos;  -- precio medio
SELECT MAX(precio)  FROM productos;  -- el más caro
SELECT MIN(precio)  FROM productos;  -- el más barato
```

Diferencia importante entre `COUNT(*)` y `COUNT(columna)`: `COUNT(*)` cuenta todas las filas; `COUNT(columna)` cuenta solo las que tienen valor (no nulo) en esa columna. Y `COUNT(DISTINCT columna)` cuenta valores distintos:

```sql
SELECT COUNT(DISTINCT ciudad) FROM clientes;   -- cuántas ciudades distintas -> 3
```

Puedes pedir varias agregaciones a la vez y redondear el resultado:

```sql
SELECT COUNT(*)            AS total,
       ROUND(AVG(precio),2) AS precio_medio,
       MAX(precio)         AS mas_caro,
       MIN(precio)         AS mas_barato
FROM productos;
```

## GROUP BY: agregar por grupos

Aquí está la idea central. `GROUP BY` divide las filas en grupos según una columna y aplica la agregación a cada grupo por separado. "¿Cuántos clientes hay en cada ciudad?":

```sql
SELECT ciudad, COUNT(*) AS num_clientes
FROM clientes
GROUP BY ciudad;
-- Madrid   3
-- Sevilla  2
-- Bilbao   1
```

La regla mental: `GROUP BY ciudad` crea un grupo por cada ciudad distinta, y `COUNT(*)` cuenta dentro de cada uno. Más ejemplos:

```sql
-- Precio medio y número de productos por categoría
SELECT categoria, COUNT(*) AS n, ROUND(AVG(precio), 2) AS precio_medio
FROM productos
GROUP BY categoria;

-- Stock total por categoría
SELECT categoria, SUM(stock) AS stock_total
FROM productos
GROUP BY categoria;

-- Número de pedidos por estado
SELECT estado, COUNT(*) AS n
FROM pedidos
GROUP BY estado;
```

## La regla de oro del GROUP BY

En un `SELECT` con `GROUP BY`, cada columna del `SELECT` debe ser, o bien una de las columnas por las que agrupas, o bien una función de agregación. No puedes pedir una columna "suelta" que no esté en el `GROUP BY`, porque dentro de cada grupo esa columna tiene muchos valores y la base de datos no sabría cuál mostrar.

```sql
-- MAL: nombre no está agrupado ni agregado, ¿qué nombre mostraría por ciudad?
SELECT ciudad, nombre, COUNT(*) FROM clientes GROUP BY ciudad;

-- BIEN: solo la columna agrupada y la agregación
SELECT ciudad, COUNT(*) FROM clientes GROUP BY ciudad;
```

SQLite es permisivo y a veces deja pasar el caso "MAL" devolviendo un valor cualquiera, lo que esconde el error. MariaDB en modo estricto lo rechaza. Acostúmbrate a la regla correcta desde el principio.

## Agrupar por varias columnas

Pasa varias columnas para agrupar por combinaciones. "¿Cuántos pedidos hizo cada cliente en cada estado?":

```sql
SELECT cliente_id, estado, COUNT(*) AS n
FROM pedidos
GROUP BY cliente_id, estado;
```

Crea un grupo por cada combinación distinta de cliente y estado.

## HAVING: filtrar grupos (no filas)

`WHERE` filtra filas *antes* de agrupar. `HAVING` filtra grupos *después* de agregar. Esta distinción confunde, así que fíjate bien: si quieres condiciones sobre el resultado de un `COUNT` o un `SUM`, necesitas `HAVING`, porque esos valores no existen todavía cuando se evalúa el `WHERE`.

```sql
-- Ciudades con más de un cliente
SELECT ciudad, COUNT(*) AS n
FROM clientes
GROUP BY ciudad
HAVING COUNT(*) > 1;
-- Madrid (3), Sevilla (2)  -- Bilbao queda fuera

-- Categorías cuyo precio medio supera los 100 €
SELECT categoria, ROUND(AVG(precio), 2) AS medio
FROM productos
GROUP BY categoria
HAVING AVG(precio) > 100;
```

## WHERE y HAVING juntos: filtrar antes y después

Puedes usar los dos en la misma consulta. `WHERE` reduce las filas que entran en los grupos; `HAVING` descarta grupos del resultado:

```sql
-- De los productos que cuestan más de 20 €, qué categorías suman más de 2 productos
SELECT categoria, COUNT(*) AS n
FROM productos
WHERE precio > 20          -- primero quita los baratos
GROUP BY categoria
HAVING COUNT(*) >= 2;      -- luego deja solo categorías con 2+ productos
```

El orden de ejecución real: `WHERE` → `GROUP BY` → `HAVING` → `SELECT` → `ORDER BY`. Tenerlo claro evita la mitad de los errores con agregación.

## Ordenar resultados agregados

Combina con `ORDER BY` para rankings. "Categorías ordenadas por número de productos":

```sql
SELECT categoria, COUNT(*) AS n
FROM productos
GROUP BY categoria
ORDER BY n DESC;
```

Puedes ordenar por el alias de la agregación (`n`) o repetir la función (`ORDER BY COUNT(*) DESC`). Las dos valen.

---

## Ejercicios

**06.1** — ¿Cuántos clientes hay en total? ¿Cuántas ciudades distintas?

**06.2** — Calcula el precio medio, el máximo y el mínimo de todos los productos, en una sola consulta y redondeados.

**06.3** — Cuenta cuántos productos hay en cada categoría.

**06.4** — Calcula el stock total por categoría, ordenado de mayor a menor.

**06.5** — ¿Cuántos pedidos hay en cada estado?

**06.6** — Muestra las ciudades que tienen 2 o más clientes (usa `HAVING`).

**06.7** — Muestra las categorías cuyo precio medio sea superior a 50 €, ordenadas por ese precio medio.

**06.8** — De los productos con precio mayor que 30 €, ¿cuántos hay por categoría? Muestra solo las categorías con al menos 2 (combina `WHERE` y `HAVING`).

**06.9** — Para cada cliente (por su `cliente_id`), cuenta cuántos pedidos ha hecho. Ordénalos de más pedidos a menos. (Nota: solo aparecerán los clientes que tengan pedidos; el módulo 07 explica cómo incluir también a los que no tienen.)

---

<details markdown="1">
<summary>Soluciones</summary>

**06.1**
```sql
SELECT COUNT(*) AS total_clientes, COUNT(DISTINCT ciudad) AS ciudades FROM clientes;
-- 6 clientes, 3 ciudades
```

---

**06.2**
```sql
SELECT ROUND(AVG(precio),2) AS medio, MAX(precio) AS maximo, MIN(precio) AS minimo
FROM productos;
-- medio 209.59, max 899, min 19.90
```

---

**06.3**
```sql
SELECT categoria, COUNT(*) AS n FROM productos GROUP BY categoria;
```

---

**06.4**
```sql
SELECT categoria, SUM(stock) AS stock_total
FROM productos
GROUP BY categoria
ORDER BY stock_total DESC;
```

---

**06.5**
```sql
SELECT estado, COUNT(*) AS n FROM pedidos GROUP BY estado;
```

---

**06.6**
```sql
SELECT ciudad, COUNT(*) AS n
FROM clientes
GROUP BY ciudad
HAVING COUNT(*) >= 2;
-- Madrid (3), Sevilla (2)
```

---

**06.7**
```sql
SELECT categoria, ROUND(AVG(precio),2) AS medio
FROM productos
GROUP BY categoria
HAVING AVG(precio) > 50
ORDER BY medio DESC;
```

---

**06.8**
```sql
SELECT categoria, COUNT(*) AS n
FROM productos
WHERE precio > 30
GROUP BY categoria
HAVING COUNT(*) >= 2;
```

---

**06.9**
```sql
SELECT cliente_id, COUNT(*) AS num_pedidos
FROM pedidos
GROUP BY cliente_id
ORDER BY num_pedidos DESC;
-- cliente 1 (Ada): 2, cliente 2 (Luis): 2, resto: 1
```

</details>
