# Módulo 04 — Filtrar con precisión: AND, OR, IN, BETWEEN, LIKE y NULL

El `WHERE` del módulo anterior filtraba con una condición simple. Los datos reales piden condiciones combinadas: "clientes de Madrid dados de alta este año", "productos entre 20 y 100 euros", "nombres que empiecen por A". Este módulo te da todas las herramientas para filtrar como un profesional.

> Sigue usando la base de datos `tienda`.

## Combinar condiciones con AND y OR

`AND` exige que se cumplan **todas** las condiciones; `OR`, que se cumpla **al menos una**:

```sql
-- Productos de Periféricos que además cuesten menos de 50 €
SELECT nombre, precio FROM productos
WHERE categoria = 'Periféricos' AND precio < 50;

-- Clientes de Madrid o de Bilbao
SELECT nombre, ciudad FROM clientes
WHERE ciudad = 'Madrid' OR ciudad = 'Bilbao';
```

Cuando mezclas `AND` y `OR`, usa paréntesis para dejar claro qué va con qué. Sin paréntesis, `AND` se evalúa antes que `OR`, y eso puede no ser lo que quieres:

```sql
-- "(Madrid o Sevilla) y además alta en 2025": los paréntesis son obligatorios aquí
SELECT nombre FROM clientes
WHERE (ciudad = 'Madrid' OR ciudad = 'Sevilla')
  AND fecha_alta >= '2025-01-01';
```

Quita los paréntesis y la consulta significa otra cosa. Cuando combines los dos operadores, agrupa siempre con paréntesis.

## NOT: negar una condición

`NOT` invierte:

```sql
SELECT nombre FROM productos WHERE NOT categoria = 'Audio';
SELECT * FROM pedidos WHERE NOT estado = 'cancelado';
```

## IN: pertenecer a una lista

Cuando comparas una columna contra varios valores, `IN` es más limpio que encadenar `OR`:

```sql
-- En vez de: ciudad = 'Madrid' OR ciudad = 'Sevilla' OR ciudad = 'Bilbao'
SELECT nombre, ciudad FROM clientes
WHERE ciudad IN ('Madrid', 'Sevilla');

SELECT nombre FROM productos
WHERE categoria IN ('Audio', 'Pantallas');
```

Y su negación, `NOT IN`, para "que no esté en la lista":

```sql
SELECT * FROM pedidos WHERE estado NOT IN ('cancelado', 'pendiente');
```

## BETWEEN: dentro de un rango

`BETWEEN` filtra valores dentro de un rango, **incluyendo los dos extremos**:

```sql
SELECT nombre, precio FROM productos
WHERE precio BETWEEN 20 AND 100;
-- equivale a: precio >= 20 AND precio <= 100
```

Funciona también con fechas, gracias a que el formato `'AAAA-MM-DD'` se ordena bien:

```sql
SELECT nombre, fecha_alta FROM clientes
WHERE fecha_alta BETWEEN '2025-01-01' AND '2025-06-30';
-- altas del primer semestre
```

Recuerda: `BETWEEN` incluye ambos límites. Si no quieres incluir el extremo superior, usa `>=` y `<` por separado.

## LIKE: buscar patrones en texto

`LIKE` busca coincidencias parciales en cadenas, usando dos comodines:

- `%` representa cualquier secuencia de caracteres (incluida ninguna).
- `_` representa exactamente un carácter.

```sql
SELECT nombre FROM clientes WHERE nombre LIKE 'A%';     -- empieza por A
SELECT nombre FROM clientes WHERE nombre LIKE '%a';     -- termina en a
SELECT nombre FROM productos WHERE nombre LIKE '%or%';  -- contiene "or"
SELECT nombre FROM clientes WHERE nombre LIKE '_va';    -- 3 letras, acaba en "va" (Eva)
```

En SQLite, `LIKE` no distingue mayúsculas para letras ASCII (`'a%'` y `'A%'` dan igual), pero esto varía entre motores. Para búsquedas sensibles a mayúsculas, SQLite ofrece `GLOB`, que sí distingue.

> **En MariaDB/MySQL:** `LIKE` por defecto tampoco distingue mayúsculas (depende de la *collation* de la columna). El comodín y la sintaxis son idénticos. Para insensibilidad total a acentos y mayúsculas, allí se ajusta la collation de la tabla.

## Trabajar con NULL: el filtro que rompe las reglas

`NULL` es "valor desconocido", y se comporta distinto a todo lo demás. La trampa: **no puedes compararlo con `=`**. `columna = NULL` nunca es verdadero, ni siquiera cuando el valor es nulo, porque "desconocido = desconocido" no se puede afirmar. Para filtrar nulos hay operadores propios:

```sql
SELECT nombre FROM clientes WHERE ciudad IS NULL;       -- sin ciudad
SELECT nombre FROM clientes WHERE ciudad IS NOT NULL;   -- con ciudad
```

Memoriza esto: para nulos, `IS NULL` e `IS NOT NULL`, nunca `= NULL`. Es uno de los errores más comunes y más difíciles de detectar, porque no da error: simplemente devuelve cero filas en silencio.

`NULL` también contagia los cálculos: cualquier operación con `NULL` da `NULL` (`precio + NULL` es `NULL`). Para sustituir nulos por un valor por defecto en una consulta, usa `COALESCE`:

```sql
SELECT nombre, COALESCE(ciudad, 'Sin ciudad') AS ciudad
FROM clientes;
```

`COALESCE(a, b)` devuelve `a` si no es nulo, y `b` si lo es. Lo verás más en el módulo 05.

## Juntarlo todo: una consulta realista

Las consultas de verdad combinan varias de estas piezas:

```sql
SELECT nombre, categoria, precio
FROM productos
WHERE categoria IN ('Periféricos', 'Audio')
  AND precio BETWEEN 20 AND 80
  AND nombre LIKE '%a%'
ORDER BY precio DESC;
```

Léela por partes: productos de dos categorías, con precio entre 20 y 80, cuyo nombre contenga una "a", ordenados de más caro a más barato. Construir consultas así, condición a condición, es el día a día de quien trabaja con datos.

---

## Ejercicios

**04.1** — Muestra los clientes que son de Madrid o de Sevilla, usando `IN`.

**04.2** — Muestra los productos cuyo precio esté entre 30 y 200 € (ambos incluidos).

**04.3** — Muestra los clientes cuyo nombre empiece por la letra "M" o por la "J".

**04.4** — Muestra los productos cuyo nombre contenga la cadena "or" (como Monitor o Cargador).

**04.5** — Muestra los pedidos que no estén cancelados ni pendientes, ordenados por fecha.

**04.6** — Muestra los clientes dados de alta en el segundo semestre de 2025 (de julio a diciembre).

**04.7** — Muestra los productos de la categoría 'Periféricos' que cuesten más de 40 € (combina dos condiciones con `AND`).

**04.8** — Imagina que algún cliente tuviera la ciudad a `NULL`. Escribe la consulta que mostraría solo a esos clientes. ¿Por qué no funcionaría `WHERE ciudad = NULL`?

---

<details>
<summary>Soluciones</summary>

**04.1**
```sql
SELECT * FROM clientes WHERE ciudad IN ('Madrid', 'Sevilla');
```

**04.2**
```sql
SELECT nombre, precio FROM productos WHERE precio BETWEEN 30 AND 200;
-- Teclado (45), Monitor (199), Auriculares (79.90), Webcam (60)
```

**04.3**
```sql
SELECT nombre FROM clientes WHERE nombre LIKE 'M%' OR nombre LIKE 'J%';
-- Marta, Juan
```

**04.4**
```sql
SELECT nombre FROM productos WHERE nombre LIKE '%or%';
-- Monitor, Cargador
```

**04.5**
```sql
SELECT * FROM pedidos
WHERE estado NOT IN ('cancelado', 'pendiente')
ORDER BY fecha;
-- pedidos 10, 11, 12, 14, 16
```

**04.6**
```sql
SELECT nombre, fecha_alta FROM clientes
WHERE fecha_alta BETWEEN '2025-07-01' AND '2025-12-31';
-- Eva (2025-09-05), Iván (2025-11-20)
```

**04.7**
```sql
SELECT nombre, precio FROM productos
WHERE categoria = 'Periféricos' AND precio > 40;
-- Teclado (45), Webcam (60)
```

**04.8**
```sql
SELECT * FROM clientes WHERE ciudad IS NULL;
```
`WHERE ciudad = NULL` no funcionaría porque `NULL` representa un valor desconocido, y SQL no puede afirmar que "desconocido = NULL" sea verdadero. La comparación con `=` siempre da un resultado nulo (ni verdadero ni falso), así que la consulta no devolvería ninguna fila aunque las hubiera. Por eso existe `IS NULL`.

</details>
