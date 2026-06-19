# Módulo 05 — Funciones de texto, números, fechas y CASE

SQL no solo filtra y ordena: transforma. Pone texto en mayúsculas, redondea precios, calcula la antigüedad de un cliente, clasifica filas en categorías. Este módulo reúne las funciones que más usarás y termina con `CASE`, la forma de meter lógica de "si esto, entonces aquello" dentro de una consulta.

> Base de datos `tienda` cargada, como siempre.

## Funciones de texto

Aplican transformaciones a cadenas, columna a columna:

```sql
SELECT UPPER(nombre)        FROM clientes;   -- MAYÚSCULAS
SELECT LOWER(nombre)        FROM clientes;   -- minúsculas
SELECT LENGTH(nombre)       FROM clientes;   -- número de caracteres
SELECT SUBSTR(nombre, 1, 3) FROM clientes;   -- 3 caracteres desde la posición 1
SELECT TRIM('  hola  ')                  ;   -- quita espacios -> 'hola'
SELECT REPLACE(ciudad, 'Madrid', 'MAD')  FROM clientes;  -- sustituye
```

Concatenar con `||` (o `CONCAT` para código portable):

```sql
SELECT nombre || ' (' || ciudad || ')' AS etiqueta FROM clientes;
-- Ada (Madrid), Luis (Sevilla), ...
```

> **En MariaDB/MySQL:** `SUBSTR` y `SUBSTRING` son equivalentes. La posición empieza en 1 en ambos motores. La concatenación con `||` no funciona; usa `CONCAT(nombre, ' (', ciudad, ')')`.

## Funciones numéricas

```sql
SELECT ROUND(precio, 1)   FROM productos;   -- redondea a 1 decimal
SELECT ROUND(precio * 1.21, 2) AS con_iva FROM productos;
SELECT ABS(-15)                         ;   -- valor absoluto: 15
SELECT precio % 10        FROM productos;   -- resto de la división (módulo)
SELECT CAST(precio AS INTEGER) FROM productos;  -- convierte a entero (trunca)
```

`ROUND` es el que más usarás, sobre todo para presentar precios e importes con dos decimales.

## Funciones de fecha

SQLite guarda las fechas como texto, pero trae funciones para operar con ellas. La clave es `DATE()` y `STRFTIME()`:

```sql
SELECT DATE('now');                    -- la fecha de hoy
SELECT STRFTIME('%Y', fecha_alta) AS anio FROM clientes;   -- extrae el año
SELECT STRFTIME('%m', fecha_alta) AS mes  FROM clientes;   -- el mes
SELECT DATE('now', '-30 days');        -- hace 30 días
SELECT JULIANDAY('now') - JULIANDAY(fecha_alta) AS dias_antiguedad FROM clientes;
```

`STRFTIME` formatea fechas: `%Y` año, `%m` mes, `%d` día, `%w` día de la semana. `JULIANDAY` convierte una fecha en un número, lo que te permite restar dos fechas para saber cuántos días pasaron.

> **En MariaDB/MySQL:** las funciones de fecha son distintas y más directas: `YEAR(fecha)`, `MONTH(fecha)`, `DAY(fecha)`, `NOW()`, `CURDATE()`, y `DATEDIFF(fecha1, fecha2)` para la diferencia en días. Es uno de los puntos donde más difieren los dialectos, así que cuando pases a MariaDB revisa estas funciones.

## COALESCE: sustituir nulos

Ya lo viste en el módulo 04. Devuelve el primer valor no nulo de la lista, ideal para rellenar huecos en la salida:

```sql
SELECT nombre, COALESCE(ciudad, 'Desconocida') AS ciudad FROM clientes;
```

## CASE: lógica condicional dentro del SELECT

`CASE` es el `if/elif/else` de SQL. Examina condiciones en orden y devuelve un valor según cuál se cumpla. Sirve para crear categorías a partir de valores:

```sql
SELECT nombre, precio,
       CASE
           WHEN precio >= 300 THEN 'Caro'
           WHEN precio >= 50  THEN 'Medio'
           ELSE 'Barato'
       END AS gama
FROM productos;
```

Lee de arriba abajo y devuelve el primer `THEN` cuya condición se cumpla. Si ninguna se cumple, devuelve el `ELSE` (y si no hay `ELSE`, devuelve `NULL`). El `END` cierra el bloque; el `AS` le da nombre a la columna.

`CASE` también clasifica por valores concretos de texto:

```sql
SELECT id, estado,
       CASE estado
           WHEN 'entregado' THEN 'Completado'
           WHEN 'cancelado' THEN 'Anulado'
           ELSE 'En curso'
       END AS situacion
FROM pedidos;
```

Esta segunda forma (`CASE columna WHEN valor`) es más corta cuando comparas siempre la misma columna contra valores fijos.

## CASE para contar condicionalmente

Un truco potente que reaparece en el módulo 06: combinar `CASE` con funciones de agregación para contar cuántas filas cumplen algo. Adelanto un ejemplo:

```sql
SELECT
    SUM(CASE WHEN precio >= 100 THEN 1 ELSE 0 END) AS caros,
    SUM(CASE WHEN precio < 100  THEN 1 ELSE 0 END) AS baratos
FROM productos;
```

Cada `CASE` produce 1 o 0 por fila, y `SUM` los acumula. Así cuentas dos grupos en una sola consulta, sin recorrer la tabla dos veces.

## Anidar y combinar funciones

Las funciones se pueden meter unas dentro de otras. El resultado de una alimenta a la siguiente:

```sql
SELECT UPPER(SUBSTR(nombre, 1, 1)) || LOWER(SUBSTR(nombre, 2)) AS normalizado
FROM clientes;
-- pone la primera letra en mayúscula y el resto en minúscula
```

No te pases con el anidamiento: si una expresión se vuelve ilegible, suele convenir partirla. Pero saber que se puede te da mucha flexibilidad.

---

## Ejercicios

**05.1** — Muestra el nombre de cada cliente en mayúsculas y su número de letras.

**05.2** — Muestra el nombre y el precio de cada producto con el precio con IVA (21%) redondeado a 2 decimales.

**05.3** — Crea una etiqueta para cada cliente con el formato `Nombre - Ciudad` usando concatenación.

**05.4** — Extrae el año de alta de cada cliente con `STRFTIME` y muéstralo junto a su nombre.

**05.5** — Clasifica cada producto con un `CASE` en 'Premium' (precio ≥ 300), 'Estándar' (entre 50 y 299) o 'Económico' (menos de 50).

**05.6** — Para cada pedido, muestra su estado y una columna `activo` que diga 'Sí' si el estado es 'enviado' o 'pendiente', y 'No' en caso contrario.

**05.7** — Cuenta, en una sola consulta con `CASE` y `SUM`, cuántos productos hay con stock (stock > 0) y cuántos sin stock (stock = 0).

**05.8** — Muestra el nombre de los clientes con la primera letra en mayúscula y el resto en minúscula, aunque ya lo estén (normalízalos por si acaso).

---

<details markdown="1">
<summary>Soluciones</summary>

**05.1**
```sql
SELECT UPPER(nombre) AS nombre, LENGTH(nombre) AS letras FROM clientes;
```

---

**05.2**
```sql
SELECT nombre, ROUND(precio * 1.21, 2) AS precio_con_iva FROM productos;
```

---

**05.3**
```sql
SELECT nombre || ' - ' || ciudad AS etiqueta FROM clientes;
-- En MariaDB: SELECT CONCAT(nombre, ' - ', ciudad) AS etiqueta FROM clientes;
```

---

**05.4**
```sql
SELECT nombre, STRFTIME('%Y', fecha_alta) AS anio_alta FROM clientes;
-- En MariaDB: SELECT nombre, YEAR(fecha_alta) AS anio_alta FROM clientes;
```

---

**05.5**
```sql
SELECT nombre, precio,
       CASE
           WHEN precio >= 300 THEN 'Premium'
           WHEN precio >= 50  THEN 'Estándar'
           ELSE 'Económico'
       END AS gama
FROM productos;
```

---

**05.6**
```sql
SELECT id, estado,
       CASE WHEN estado IN ('enviado', 'pendiente') THEN 'Sí' ELSE 'No' END AS activo
FROM pedidos;
```

---

**05.7**
```sql
SELECT
    SUM(CASE WHEN stock > 0 THEN 1 ELSE 0 END) AS con_stock,
    SUM(CASE WHEN stock = 0 THEN 1 ELSE 0 END) AS sin_stock
FROM productos;
-- con_stock: 7, sin_stock: 1 (la Webcam)
```

---

**05.8**
```sql
SELECT UPPER(SUBSTR(nombre, 1, 1)) || LOWER(SUBSTR(nombre, 2)) AS nombre
FROM clientes;
```

</details>
