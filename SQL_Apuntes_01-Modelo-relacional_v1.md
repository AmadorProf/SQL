# Módulo 01 — El modelo relacional: tablas, claves y relaciones

Antes de escribir consultas hay que entender cómo se organizan los datos. Una base de datos relacional guarda la información en tablas conectadas entre sí. Comprender esa estructura es lo que separa a quien copia consultas de quien las diseña. Este módulo es teoría, pero teoría que necesitas. No la saltes.

## Una tabla es una rejilla de filas y columnas

Una tabla representa un tipo de cosa: clientes, productos, pedidos. Cada **columna** es un atributo (nombre, precio, fecha) y cada **fila** es un registro concreto (un cliente, un producto). Igual que una hoja de cálculo, pero con reglas estrictas sobre qué puede ir en cada sitio.

```
Tabla: clientes
┌────┬──────────┬──────────┬─────────────┐
│ id │ nombre   │ ciudad   │ fecha_alta  │   <- columnas (atributos)
├────┼──────────┼──────────┼─────────────┤
│  1 │ Ada      │ Madrid   │ 2025-01-10  │   <- una fila (un cliente)
│  2 │ Luis     │ Sevilla  │ 2025-03-22  │
│  3 │ Marta    │ Madrid   │ 2025-06-01  │
└────┴──────────┴──────────┴─────────────┘
```

Cada columna tiene un **tipo de dato** fijo: `id` y los textos no se mezclan. Esa rigidez es una ventaja: la base de datos garantiza que un precio sea siempre un número y una fecha siempre una fecha.

## La clave primaria identifica cada fila sin ambigüedad

Necesitas una forma de señalar una fila concreta sin confundirla con otra. Para eso está la **clave primaria** (primary key): una columna cuyo valor es único e irrepetible en toda la tabla. Lo habitual es una columna `id` numérica que crece sola.

Dos reglas de la clave primaria: nunca se repite y nunca está vacía. Si dos clientes se llaman "Ada Lovelace", sus `id` los distinguen. Por eso no usamos el nombre como identificador: los nombres se repiten, los `id` no.

## La clave foránea conecta tablas

Aquí está la idea central del modelo relacional. En vez de meter toda la información en una tabla gigante, la repartes en tablas pequeñas y las conectas. Una **clave foránea** (foreign key) es una columna que apunta a la clave primaria de otra tabla.

```
Tabla: pedidos
┌────┬────────────┬─────────────┐
│ id │ cliente_id │ fecha       │
├────┼────────────┼─────────────┤
│ 10 │     1      │ 2025-07-01  │   <- cliente_id = 1 -> es de Ada
│ 11 │     1      │ 2025-07-15  │   <- otro pedido de Ada
│ 12 │     2      │ 2025-08-03  │   <- este es de Luis
└────┴────────────┴─────────────┘
```

La columna `cliente_id` en `pedidos` es una clave foránea: apunta al `id` de `clientes`. Así sabes de quién es cada pedido sin repetir su nombre, ciudad y fecha de alta en cada pedido. Si Ada cambia de ciudad, lo corriges en un solo sitio.

Este "no repetir datos" es la razón de ser de las bases de datos relacionales. La duplicación es la fuente de casi todos los errores de datos.

## Tipos de relación entre tablas

**Uno a muchos (1:N)** — la más común. Un cliente tiene muchos pedidos, pero cada pedido pertenece a un solo cliente. La clave foránea va en el lado "muchos" (en `pedidos`).

**Muchos a muchos (N:M)** — un pedido contiene muchos productos, y un producto aparece en muchos pedidos. Esto no se puede resolver con una sola clave foránea: necesitas una **tabla intermedia** (llamada `lineas_pedido` o `detalle`) que conecte ambos lados:

```
pedidos  <---  lineas_pedido  --->  productos
              (pedido_id, producto_id, cantidad)
```

Cada fila de `lineas_pedido` dice "en el pedido X hay Y unidades del producto Z". Es el patrón que usarás una y otra vez.

**Uno a uno (1:1)** — menos frecuente. Un empleado tiene una ficha de nómina y viceversa. Se resuelve con una clave foránea que además es única.

## Tipos de datos: qué cabe en cada columna

Al crear una tabla declaras el tipo de cada columna. Los esenciales en SQLite:

| Tipo | Para qué | Ejemplo |
|------|----------|---------|
| `INTEGER` | Números enteros, ids | `42`, `-7` |
| `REAL` | Números con decimales | `19.99` |
| `TEXT` | Texto de cualquier longitud | `'Madrid'` |
| `BLOB` | Datos binarios (imágenes, etc.) | (raro al empezar) |
| `NUMERIC` | Números, fechas, booleanos | `2025-01-10` |

SQLite es flexible con los tipos (los trata como sugerencias), lo que perdona errores pero también los esconde. Acostúmbrate a declarar el tipo correcto igualmente.

> **En MariaDB/MySQL:** hay muchos más tipos y son estrictos. Los que más usarás: `INT`, `VARCHAR(n)` (texto con longitud máxima, como `VARCHAR(100)`), `DECIMAL(10,2)` (ideal para dinero), `DATE`, `DATETIME`, `BOOLEAN`. Allí declarar `VARCHAR(100)` reserva espacio para 100 caracteres; SQLite ignora esa longitud pero la acepta, así que puedes escribirla para que tu código sea portable.

## Las fechas son un caso especial

SQLite no tiene un tipo de fecha dedicado: las guarda como texto en formato `'AAAA-MM-DD'` (o `'AAAA-MM-DD HH:MM:SS'`). Ese formato no es capricho: ordenado alfabéticamente coincide con el orden cronológico, así que funciona perfectamente para comparar y ordenar. Usa siempre ese formato.

## NULL: la ausencia de valor

`NULL` significa "no hay valor" / "se desconoce". No es cero ni una cadena vacía: es la nada. Un cliente sin teléfono registrado tiene el teléfono a `NULL`. Trabajar con `NULL` tiene reglas propias que veremos en el módulo 04, porque se comporta de forma sorprendente (por ejemplo, `NULL = NULL` no es verdadero).

## El esquema: el plano de la base de datos

El conjunto de todas las tablas, sus columnas, tipos y relaciones se llama **esquema**. Diseñar bien el esquema antes de meter datos te ahorra meses de dolor después. El módulo 10 entra a fondo en cómo diseñarlo bien (normalización). Por ahora, quédate con el plano de nuestra tienda de prácticas:

```
clientes (id PK, nombre, ciudad, fecha_alta)
   │ 1
   │
   │ N
pedidos (id PK, cliente_id FK, fecha, estado)
   │ 1
   │
   │ N
lineas_pedido (id PK, pedido_id FK, producto_id FK, cantidad)
                                        │ N
                                        │
                                        │ 1
                              productos (id PK, nombre, categoria, precio, stock)
```

Léelo así: un cliente tiene muchos pedidos; un pedido tiene muchas líneas; cada línea apunta a un producto. Es el modelo que poblarás en el módulo 02 y consultarás durante todo el curso.

---

## Ejercicios

Estos ejercicios son de diseño y comprensión, no de escribir SQL todavía. Responde en papel o en un comentario.

**01.1** — En la tabla `clientes`, ¿por qué `id` es mejor clave primaria que `nombre`? Da un caso concreto donde usar el nombre daría problemas.

**01.2** — Tienes una tabla `cursos` y una tabla `alumnos`. Un alumno se matricula en varios cursos y un curso tiene varios alumnos. ¿Qué tipo de relación es? ¿Cómo la representarías con tablas?

**01.3** — Dibuja (en texto) el esquema de una biblioteca con libros, socios y préstamos. ¿Dónde van las claves foráneas?

**01.4** — Para una columna que guarda el precio de un producto en euros con céntimos, ¿qué tipo de dato usarías en SQLite y cuál en MariaDB? ¿Por qué `DECIMAL` es preferible a `REAL` para dinero?

---

<details markdown="1">
<summary>Soluciones</summary>

**01.1** — Los nombres se repiten y pueden cambiar; un `id` es único e inmutable. Caso concreto: si hay dos clientes llamados "Ana García", al hacer un pedido "de Ana García" no sabrías a cuál de las dos asignarlo. Con `id` (1 y 2) no hay ambigüedad. Además, si una clienta cambia de apellido al casarse, su `id` sigue igual y no rompes las referencias de sus pedidos.

---

**01.2** — Es una relación **muchos a muchos**. Se representa con tres tablas: `alumnos`, `cursos` y una tabla intermedia `matriculas (alumno_id, curso_id, fecha)`. Cada fila de `matriculas` conecta a un alumno con un curso.

---

**01.3**
```
socios (id PK, nombre, email)
libros (id PK, titulo, autor, isbn)
prestamos (id PK, socio_id FK, libro_id FK, fecha_prestamo, fecha_devolucion)
```
Las claves foráneas van en `prestamos`: `socio_id` apunta a `socios.id` y `libro_id` a `libros.id`. Un préstamo conecta un socio con un libro. Es el patrón de tabla intermedia: un socio toma prestados muchos libros y un libro lo toman prestado muchos socios a lo largo del tiempo.

---

**01.4** — En SQLite usarías `REAL` o `NUMERIC`; en MariaDB, `DECIMAL(10,2)`. `DECIMAL` es preferible para dinero porque guarda el número exacto. `REAL` (coma flotante) puede introducir errores diminutos —el clásico `0.1 + 0.2 = 0.30000000000000004`— que en cálculos de dinero se acumulan y descuadran cuentas. `DECIMAL` no tiene ese problema.

</details>
