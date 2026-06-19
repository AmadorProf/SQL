# Módulo 03 — SELECT: pedir datos a la base de datos

`SELECT` es la consulta que más vas a escribir en tu vida. Sirve para pedir datos: qué columnas quieres, de qué tabla, con qué filtro y en qué orden. Este módulo cubre la estructura básica. A partir de aquí, todo es ampliar el `SELECT`.

> Todos los ejemplos y ejercicios usan la base de datos `tienda` del módulo 02. Tenla cargada.

## La forma básica: SELECT ... FROM

Pides columnas (`SELECT`) de una tabla (`FROM`):

```sql
SELECT nombre, ciudad FROM clientes;
```

Devuelve dos columnas de todas las filas de `clientes`. Para pedir **todas** las columnas, usa el asterisco:

```sql
SELECT * FROM clientes;
```

El `*` es cómodo para explorar, pero en consultas de verdad nombra solo las columnas que necesitas: es más claro y más eficiente. Pedir lo que no usas es desperdicio.

## El orden de las cláusulas es fijo

Una consulta completa sigue siempre este orden. No te lo saltes ni lo cambies:

```sql
SELECT   columnas
FROM     tabla
WHERE    condición
ORDER BY columna
LIMIT    número;
```

Puedes omitir las que no necesites, pero las que pongas deben ir en ese orden. `WHERE` siempre antes de `ORDER BY`, y `ORDER BY` antes de `LIMIT`.

## WHERE: filtrar filas

`WHERE` se queda solo con las filas que cumplen una condición:

```sql
SELECT nombre, ciudad FROM clientes WHERE ciudad = 'Madrid';

SELECT nombre, precio FROM productos WHERE precio > 100;

SELECT * FROM pedidos WHERE estado = 'entregado';
```

Para comparar usas estos operadores:

```sql
=    -- igual (en SQL es UN solo signo, no dos como en otros lenguajes)
<>   -- distinto (también vale != en muchos motores)
>    -- mayor
<    -- menor
>=   -- mayor o igual
<=   -- menor o igual
```

El texto va entre comillas simples (`'Madrid'`), los números sin comillas (`100`). Y ojo: en SQL la igualdad se escribe con un solo `=`, a diferencia de Python que usa `==`.

## ORDER BY: ordenar el resultado

```sql
SELECT nombre, precio FROM productos ORDER BY precio;          -- de menor a mayor
SELECT nombre, precio FROM productos ORDER BY precio DESC;     -- de mayor a menor
SELECT nombre FROM clientes ORDER BY nombre ASC;               -- alfabético (ASC es el defecto)
```

`ASC` ordena ascendente (es el comportamiento por defecto, no hace falta escribirlo); `DESC`, descendente. Puedes ordenar por varias columnas: primero por una, y dentro de los empates, por otra:

```sql
SELECT nombre, ciudad, fecha_alta
FROM clientes
ORDER BY ciudad, fecha_alta DESC;
```

Esto agrupa visualmente por ciudad y, dentro de cada ciudad, pone primero los clientes más recientes.

## LIMIT: cuántas filas quieres

`LIMIT` corta el resultado a un número de filas. Combinado con `ORDER BY`, responde a "los N mejores/peores":

```sql
SELECT nombre, precio FROM productos ORDER BY precio DESC LIMIT 3;
-- los 3 productos más caros
```

Para saltarte las primeras filas (paginación), `OFFSET`:

```sql
SELECT nombre FROM productos ORDER BY precio DESC LIMIT 3 OFFSET 3;
-- del 4º al 6º producto más caro
```

> **En MariaDB/MySQL:** `LIMIT` y `OFFSET` funcionan igual; también admite la forma abreviada `LIMIT 3, 3` (offset, cantidad). SQL Server usa `TOP` en lugar de `LIMIT`, pero eso ya es otro motor.

## DISTINCT: eliminar duplicados

`DISTINCT` quita filas repetidas del resultado. Útil para ver qué valores distintos existen en una columna:

```sql
SELECT DISTINCT ciudad FROM clientes;
-- Madrid, Sevilla, Bilbao  (cada una una vez, aunque haya varios de Madrid)

SELECT DISTINCT categoria FROM productos;
-- las categorías que existen, sin repetir
```

## Alias: renombrar columnas con AS

`AS` da un nombre temporal a una columna o a un cálculo en el resultado. Hace las salidas legibles, sobre todo cuando calculas:

```sql
SELECT nombre AS producto, precio AS precio_euros
FROM productos;

SELECT nombre, precio * 1.21 AS precio_con_iva
FROM productos;
```

Sin el alias, esa columna calculada saldría con un nombre feo como `precio * 1.21`. El `AS` es opcional (puedes escribir `precio AS p` o solo `precio p`), pero ponerlo se lee mejor.

## Columnas calculadas: SQL también opera

`SELECT` no se limita a devolver columnas tal cual: puede calcular sobre ellas. Aritmética, concatenación, funciones:

```sql
SELECT nombre,
       precio,
       precio * 0.9 AS precio_rebajado,
       stock * precio AS valor_inventario
FROM productos;
```

Cada fila se calcula por separado. Es la misma idea que las columnas calculadas de Pandas, pero en SQL.

## El orden de ejecución no es el de escritura

Un detalle que aclara muchas dudas: aunque escribes `SELECT` primero, la base de datos ejecuta antes el `FROM` (de dónde saco los datos), luego el `WHERE` (qué filas), luego el `SELECT` (qué columnas) y por último `ORDER BY` y `LIMIT`. Por eso a veces un alias definido en el `SELECT` no se puede usar en el `WHERE`: cuando se evalúa el `WHERE`, ese alias todavía no existe. Tenlo en mente cuando una consulta no haga lo que esperas.

---

## Ejercicios

**03.1** — Muestra el nombre y la ciudad de todos los clientes.

**03.2** — Muestra todos los productos cuyo precio supere los 50 €, ordenados de más caro a más barato.

**03.3** — Lista las ciudades distintas en las que hay clientes.

**03.4** — Muestra el nombre y el precio de los productos, añadiendo una columna calculada con el precio con IVA (21%), con un alias claro.

**03.5** — Muestra los 3 productos con más stock.

**03.6** — Lista los pedidos que NO están en estado 'entregado'.

**03.7** — Muestra el nombre de los productos de la categoría 'Periféricos' ordenados alfabéticamente.

**03.8** — Muestra el valor total del inventario de cada producto (precio × stock), llamando a esa columna `valor_inventario`, ordenado de mayor a menor.

---

<details>
<summary>Soluciones</summary>

**03.1**
```sql
SELECT nombre, ciudad FROM clientes;
```

**03.2**
```sql
SELECT nombre, precio FROM productos
WHERE precio > 50
ORDER BY precio DESC;
-- Portátil (899), Tablet (349), Monitor (199), Auriculares (79.90), Webcam (60)
```

**03.3**
```sql
SELECT DISTINCT ciudad FROM clientes;
-- Madrid, Sevilla, Bilbao
```

**03.4**
```sql
SELECT nombre, precio, precio * 1.21 AS precio_con_iva
FROM productos;
```

**03.5**
```sql
SELECT nombre, stock FROM productos ORDER BY stock DESC LIMIT 3;
-- Cargador (300), Ratón (200), Teclado (120)
```

**03.6**
```sql
SELECT * FROM pedidos WHERE estado <> 'entregado';
-- los pedidos 12, 13, 15, 16
```

**03.7**
```sql
SELECT nombre FROM productos
WHERE categoria = 'Periféricos'
ORDER BY nombre;
-- Ratón, Teclado, Webcam
```

**03.8**
```sql
SELECT nombre, precio * stock AS valor_inventario
FROM productos
ORDER BY valor_inventario DESC;
-- Portátil: 13485, Tablet: 8725, Monitor: 5970, ...
```

</details>
