# Módulo 02 — Crear tablas y poblarlas con datos

Toca construir la base de datos de prácticas que usarás el resto del curso. Aprenderás a crear tablas (`CREATE TABLE`) y a meterles datos (`INSERT`). Al final tendrás una tienda funcionando con clientes, productos y pedidos. Ejecuta el script completo: lo necesitas para todos los módulos siguientes.

## CREATE TABLE: definir la estructura

Crear una tabla es declarar sus columnas, cada una con su tipo, y marcar la clave primaria:

```sql
CREATE TABLE clientes (
    id          INTEGER PRIMARY KEY,
    nombre      TEXT NOT NULL,
    ciudad      TEXT,
    fecha_alta  TEXT
);
```

Tres cosas que mirar:

- Cada columna es `nombre TIPO [restricciones]`.
- `PRIMARY KEY` marca la columna que identifica cada fila de forma única.
- `NOT NULL` obliga a que esa columna siempre tenga valor: no puedes crear un cliente sin nombre.

En SQLite, una columna `INTEGER PRIMARY KEY` se autoincrementa sola: si no le das valor al insertar, asigna el siguiente número libre. Es la forma estándar de generar ids.

> **En MariaDB/MySQL:** para autoincrementar se escribe explícitamente `id INT PRIMARY KEY AUTO_INCREMENT`. Y los textos llevan longitud: `nombre VARCHAR(100) NOT NULL`. El resto es igual.

## Restricciones: las reglas que protegen tus datos

Las restricciones (constraints) impiden que entren datos inválidos. Las que usarás desde ya:

```sql
CREATE TABLE productos (
    id        INTEGER PRIMARY KEY,
    nombre    TEXT NOT NULL,
    categoria TEXT,
    precio    REAL NOT NULL CHECK (precio >= 0),   -- no se admiten precios negativos
    stock     INTEGER DEFAULT 0                     -- si no se indica, vale 0
);
```

- `NOT NULL` — obligatoria.
- `CHECK (condición)` — solo acepta valores que cumplan la condición.
- `DEFAULT valor` — si no se da valor, usa este.
- `UNIQUE` — el valor no puede repetirse (útil para emails, DNIs).

## FOREIGN KEY: declarar las relaciones

La clave foránea conecta una tabla con otra, y además impide referencias rotas (un pedido apuntando a un cliente que no existe):

```sql
CREATE TABLE pedidos (
    id         INTEGER PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    fecha      TEXT,
    estado     TEXT DEFAULT 'pendiente',
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);
```

La última línea dice: "`cliente_id` debe corresponder a un `id` existente en `clientes`". Si intentas crear un pedido para el cliente 999, que no existe, la base de datos lo rechaza (siempre que las claves foráneas estén activadas).

> **En SQLite** las claves foráneas vienen desactivadas por defecto por motivos históricos. Actívalas al principio de cada sesión con `PRAGMA foreign_keys = ON;`. En MariaDB/MySQL están activas por defecto.

## INSERT: meter datos

Para añadir filas, `INSERT INTO`. Indicas las columnas y luego los valores:

```sql
INSERT INTO clientes (nombre, ciudad, fecha_alta)
VALUES ('Ada', 'Madrid', '2025-01-10');
```

No damos el `id`: SQLite lo genera solo. Los textos van entre comillas simples; los números, sin comillas.

Puedes insertar varias filas de una vez separándolas por comas:

```sql
INSERT INTO clientes (nombre, ciudad, fecha_alta) VALUES
    ('Luis',  'Sevilla', '2025-03-22'),
    ('Marta', 'Madrid',  '2025-06-01'),
    ('Juan',  'Bilbao',  '2025-02-14');
```

## El script completo de la tienda

Copia y ejecuta esto entero en tu herramienta. Crea las cuatro tablas y las llena. Es la base de datos que usarán todos los ejercicios del curso (también lo tienes suelto en `SQL_Apuntes_99-Script-BBDD.sql`).

```sql
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS lineas_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS clientes;

CREATE TABLE clientes (
    id          INTEGER PRIMARY KEY,
    nombre      TEXT NOT NULL,
    ciudad      TEXT,
    fecha_alta  TEXT
);

CREATE TABLE productos (
    id        INTEGER PRIMARY KEY,
    nombre    TEXT NOT NULL,
    categoria TEXT,
    precio    REAL NOT NULL CHECK (precio >= 0),
    stock     INTEGER DEFAULT 0
);

CREATE TABLE pedidos (
    id         INTEGER PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    fecha      TEXT,
    estado     TEXT DEFAULT 'pendiente',
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE lineas_pedido (
    id          INTEGER PRIMARY KEY,
    pedido_id   INTEGER NOT NULL,
    producto_id INTEGER NOT NULL,
    cantidad    INTEGER NOT NULL CHECK (cantidad > 0),
    FOREIGN KEY (pedido_id)   REFERENCES pedidos(id),
    FOREIGN KEY (producto_id) REFERENCES productos(id)
);

INSERT INTO clientes (id, nombre, ciudad, fecha_alta) VALUES
    (1, 'Ada',   'Madrid',  '2025-01-10'),
    (2, 'Luis',  'Sevilla', '2025-03-22'),
    (3, 'Marta', 'Madrid',  '2025-06-01'),
    (4, 'Juan',  'Bilbao',  '2025-02-14'),
    (5, 'Eva',   'Sevilla', '2025-09-05'),
    (6, 'Iván',  'Madrid',  '2025-11-20');

INSERT INTO productos (id, nombre, categoria, precio, stock) VALUES
    (1, 'Portátil',    'Informática', 899.00, 15),
    (2, 'Ratón',       'Periféricos',  19.90, 200),
    (3, 'Teclado',     'Periféricos',  45.00, 120),
    (4, 'Monitor',     'Pantallas',   199.00, 30),
    (5, 'Webcam',      'Periféricos',  60.00, 0),
    (6, 'Auriculares', 'Audio',        79.90, 50),
    (7, 'Tablet',      'Informática', 349.00, 25),
    (8, 'Cargador',    'Accesorios',   24.90, 300);

INSERT INTO pedidos (id, cliente_id, fecha, estado) VALUES
    (10, 1, '2025-07-01', 'entregado'),
    (11, 1, '2025-07-15', 'entregado'),
    (12, 2, '2025-08-03', 'enviado'),
    (13, 3, '2025-08-20', 'pendiente'),
    (14, 4, '2025-09-10', 'entregado'),
    (15, 2, '2025-10-05', 'cancelado'),
    (16, 5, '2025-11-01', 'enviado');

INSERT INTO lineas_pedido (pedido_id, producto_id, cantidad) VALUES
    (10, 1, 1),
    (10, 2, 2),
    (11, 4, 2),
    (11, 3, 1),
    (12, 6, 1),
    (12, 2, 3),
    (13, 7, 1),
    (14, 1, 1),
    (14, 8, 4),
    (15, 4, 1),
    (16, 6, 2),
    (16, 3, 1);
```

Fíjate en el cliente Iván (id 6): no tiene ningún pedido. No es un descuido, es a propósito. En el módulo 07 (JOINs) verás por qué importa tener un cliente sin pedidos y un producto sin ventas.

## Comprobar que ha funcionado

Ejecuta estas consultas para verificar que las tablas tienen los datos:

```sql
SELECT COUNT(*) FROM clientes;   -- debe dar 6
SELECT COUNT(*) FROM productos;  -- debe dar 8
SELECT COUNT(*) FROM pedidos;    -- debe dar 7
SELECT * FROM clientes;          -- mira todas las filas
```

## Modificar la estructura después: ALTER TABLE

Si necesitas añadir una columna a una tabla que ya existe, sin recrearla:

```sql
ALTER TABLE clientes ADD COLUMN email TEXT;
```

SQLite tiene un `ALTER TABLE` limitado (puede añadir y renombrar columnas, pero borrar o cambiar tipos es más engorroso). MariaDB es mucho más flexible aquí. Al empezar, lo normal es ajustar el `CREATE TABLE` y volver a crear la tabla.

---

## Ejercicios

**02.1** — Crea una tabla `categorias` con `id` (clave primaria) y `nombre` (texto, obligatorio y único). Insértale tres categorías.

**02.2** — Añade a la tabla `clientes` una columna `email` con `ALTER TABLE`. Luego intenta entender por qué no puedes ponerle `NOT NULL` directamente si ya hay filas sin email.

**02.3** — Crea una tabla `empleados` con: `id` (PK autoincremental), `nombre` (obligatorio), `salario` (real, que no admita valores negativos con un `CHECK`) y `departamento` (con valor por defecto `'General'`). Inserta dos empleados, uno indicando departamento y otro dejándolo por defecto.

**02.4** — Inserta un nuevo producto en la tabla `productos` (por ejemplo un "Micrófono", categoría Audio, 39.90 €, 40 de stock) y comprueba con un `SELECT` que se ha añadido y qué `id` recibió.

**02.5** — Intenta insertar un pedido con `cliente_id = 99` (un cliente que no existe), con las claves foráneas activadas. ¿Qué ocurre y por qué es bueno que ocurra?

---

<details markdown="1">
<summary>Soluciones</summary>

**02.1**
```sql
CREATE TABLE categorias (
    id     INTEGER PRIMARY KEY,
    nombre TEXT NOT NULL UNIQUE
);
INSERT INTO categorias (nombre) VALUES ('Informática'), ('Audio'), ('Periféricos');
```

---

**02.2**
```sql
ALTER TABLE clientes ADD COLUMN email TEXT;
```
No puedes ponerle `NOT NULL` de golpe porque las filas existentes quedarían con `email` vacío, lo que violaría la restricción. Primero rellenarías los emails y luego, si quieres, aplicarías la restricción. Una columna nueva `NOT NULL` necesita un `DEFAULT` para las filas que ya existen.

---

**02.3**
```sql
CREATE TABLE empleados (
    id           INTEGER PRIMARY KEY,
    nombre       TEXT NOT NULL,
    salario      REAL CHECK (salario >= 0),
    departamento TEXT DEFAULT 'General'
);
INSERT INTO empleados (nombre, salario, departamento) VALUES ('Ana', 2200, 'Ventas');
INSERT INTO empleados (nombre, salario) VALUES ('Luis', 1900);
-- Luis queda en el departamento 'General' por defecto
```

---

**02.4**
```sql
INSERT INTO productos (nombre, categoria, precio, stock)
VALUES ('Micrófono', 'Audio', 39.90, 40);
SELECT * FROM productos WHERE nombre = 'Micrófono';
-- Recibe el id 9 (el siguiente libre tras el 8)
```

---

**02.5**
```sql
INSERT INTO pedidos (cliente_id, fecha) VALUES (99, '2025-12-01');
-- Error: FOREIGN KEY constraint failed
```
La base de datos rechaza la inserción porque no existe ningún cliente con `id = 99`. Es bueno: la restricción evita "pedidos huérfanos" que apuntan a clientes inexistentes, manteniendo los datos coherentes. Sin ella, acabarías con pedidos imposibles de rastrear.

</details>
