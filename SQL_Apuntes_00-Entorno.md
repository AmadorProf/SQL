# Módulo 00 — Qué es SQL y cómo ejecutar tu primera consulta

SQL es el idioma para hablar con las bases de datos. Con él pides datos ("dame los clientes de Madrid"), los guardas, los modificas y los borras. Casi cualquier aplicación que use datos por debajo habla SQL: una tienda online, un banco, tu gestor académico. Este módulo te monta el entorno y te deja ejecutando consultas en cinco minutos.

## SQL no es un lenguaje de programación normal

Cuando programas en Python, le dices al ordenador *cómo* hacer cada paso. En SQL le dices *qué* quieres, y el motor de la base de datos decide cómo conseguirlo. Por eso una sola línea de SQL puede recorrer un millón de filas: tú describes el resultado, el motor hace el trabajo.

```sql
SELECT nombre FROM clientes WHERE ciudad = 'Madrid';
```

Esa frase se lee casi como inglés: "selecciona el nombre de los clientes donde la ciudad sea Madrid". Esa cercanía al lenguaje natural es la gran virtud de SQL.

## Por qué empezamos con SQLite

Hay muchos motores de bases de datos: MySQL, MariaDB, PostgreSQL, SQL Server, Oracle. Todos hablan SQL, con pequeñas diferencias de dialecto. Empezamos con **SQLite** por una razón práctica: no hay que instalar ni configurar un servidor. Toda la base de datos vive en un único archivo `.db`, y el motor es una librería diminuta. Cero fricción para aprender.

Lo que aprendas aquí se transfiere casi tal cual a MariaDB o MySQL, que es lo que usarás en entornos profesionales. Las diferencias las iré marcando así:

> **En MariaDB/MySQL:** los recuadros como este señalan qué cambia respecto a SQLite. Cuando no haya recuadro, la sintaxis es idéntica.

## Instalar SQLite: tres caminos

Elige el que menos pereza te dé:

**Opción cómoda — DB Browser for SQLite.** Descárgalo de [sqlitebrowser.org](https://sqlitebrowser.org). Es un programa con ventanas donde ves las tablas, escribes consultas en una pestaña ("Execute SQL") y miras los resultados en una rejilla. Para aprender, es la mejor opción.

**Opción sin instalar nada — SQLite Online.** Entra en [sqliteonline.com](https://sqliteonline.com) y escribe SQL directamente en el navegador. Útil para probar rápido o si trabajas en un ordenador donde no puedes instalar programas.

**Opción terminal — sqlite3.** En macOS y Linux ya viene instalado. Comprueba con:

```bash
sqlite3 --version
```

Para crear o abrir una base de datos y entrar en su consola:

```bash
sqlite3 tienda.db
```

Aparece el prompt `sqlite>`. Ahí escribes SQL. Para salir, `.quit`.

> **En MariaDB/MySQL:** instalas un *servidor* que corre de fondo, creas un usuario y te conectas con `mysql -u root -p`. La base de datos no es un archivo suelto, sino que la gestiona ese servidor. Más potente, pero más que montar. Lo vemos en el módulo 10.

## Tu primera consulta, sin tablas todavía

`SELECT` no siempre necesita una tabla. Puedes usarlo como calculadora para ver que el motor responde:

```sql
SELECT 2 + 2;
-- 4

SELECT 'Hola, ' || 'mundo';
-- Hola, mundo      (|| concatena texto en SQL estándar y SQLite)

SELECT UPPER('amador');
-- AMADOR
```

El `;` final cierra cada instrucción. En la mayoría de herramientas es obligatorio para indicar dónde termina la consulta.

Los comentarios se escriben con `--` (una línea) o `/* ... */` (varias):

```sql
-- Esto es un comentario de una línea
SELECT 10 * 5;  /* esto es un comentario al final */
```

> **En MariaDB/MySQL:** la concatenación con `||` no funciona por defecto; allí se usa la función `CONCAT('Hola, ', 'mundo')`. La función `CONCAT` también existe en SQLite moderno, así que si quieres escribir código portable, úsala en ambos.

## El flujo de trabajo del curso

A partir del módulo 02 tendrás una base de datos de ejemplo (una tienda). El ciclo de trabajo será siempre el mismo: escribes una consulta, la ejecutas, miras el resultado, la ajustas. SQL se aprende probando, no memorizando. Ten la herramienta abierta mientras lees y ejecuta cada ejemplo.

## Mayúsculas, espacios y estilo

SQL no distingue mayúsculas en las palabras clave: `SELECT`, `select` y `Select` son lo mismo. Por convención, las **palabras clave van en MAYÚSCULAS** y los nombres de tablas y columnas en minúsculas. No es obligatorio, pero hace el código legible:

```sql
SELECT nombre, ciudad
FROM clientes
WHERE ciudad = 'Madrid';
```

Partir la consulta en varias líneas (una por cláusula) es buena costumbre desde el principio. Una consulta de tres líneas se lee mejor que la misma apelotonada en una.

---

## Ejercicios

**00.1** — Instala una de las tres opciones (DB Browser recomendado) y comprueba que puedes ejecutar `SELECT 1;`.

**00.2** — Usa `SELECT` como calculadora: averigua cuántos segundos tiene una semana.

**00.3** — Concatena tu nombre y tu apellido en una sola cadena con `||` (o `CONCAT` si usas el dialecto portable).

**00.4** — Muestra tu nombre en mayúsculas y su número de caracteres. Pista: existe la función `LENGTH()`.

---

<details markdown="1">
<summary>Soluciones</summary>

**00.1**
```sql
SELECT 1;
```
Si devuelve `1`, el entorno funciona.

---

**00.2**
```sql
SELECT 60 * 60 * 24 * 7;
-- 604800
```

---

**00.3**
```sql
SELECT 'Ada' || ' ' || 'Lovelace';
-- Ada Lovelace

-- Versión portable a MariaDB/MySQL:
SELECT CONCAT('Ada', ' ', 'Lovelace');
```

---

**00.4**
```sql
SELECT UPPER('amador'), LENGTH('amador');
-- AMADOR | 6
```

</details>
