# SQL desde cero hasta nivel avanzado

Curso de apuntes para pasar de no haber escrito una consulta a manejar JOINs, subconsultas y funciones de ventana con soltura. Pensado para alumnado de FP de grado superior. Cada módulo combina teoría corta, consultas que puedes ejecutar tal cual, y ejercicios con sus soluciones plegadas al final.

El motor base es **SQLite**: no requiere instalar ningún servidor, va en un solo archivo y funciona en cualquier sistema. Donde MariaDB o MySQL hacen las cosas distinto, lo señalo en un recuadro **"En MariaDB/MySQL"**. Así aprendes con la herramienta más cómoda y, a la vez, sabes qué cambia cuando pases a un motor profesional.

## Cómo usar estos apuntes

Lee de arriba abajo. Cada módulo asume el anterior. No saltes a los JOINs sin dominar el `SELECT` y el `WHERE`. Escribe y ejecuta tú las consultas; leerlas no basta.

Las soluciones están dentro de cada `.md`, plegadas al final (`<details>`). Intenta resolver antes de abrirlas.

## La base de datos de prácticas

Casi todos los módulos usan la misma base de datos de ejemplo: una tienda con clientes, productos, pedidos y líneas de pedido. El script completo para crearla está en el módulo 02 y, copiado aparte, en el archivo `SQL_Apuntes_99-Script-BBDD.sql`. Ejecútalo una vez y tendrás los datos listos para todos los ejercicios.

## Qué necesitas

Una de estas opciones, de menos a más esfuerzo:

- **DB Browser for SQLite** ([sqlitebrowser.org](https://sqlitebrowser.org)): programa con ventana, ideal para empezar y ver las tablas. Recomendado.
- **SQLite Online** ([sqliteonline.com](https://sqliteonline.com)): ejecuta SQL en el navegador, sin instalar nada.
- **Línea de comandos** `sqlite3`: viene preinstalado en macOS y Linux.

Para los módulos finales sobre diseño y motor profesional, viene bien tener MariaDB instalado, pero no es imprescindible para el grueso del curso.

## Índice de módulos

| # | Archivo | Qué aprendes |
|---|---------|--------------|
| 00 | `..._00-Entorno.md` | Qué es SQL, instalar SQLite, primera consulta |
| 01 | `..._01-Modelo-relacional.md` | Tablas, claves, relaciones, tipos de datos |
| 02 | `..._02-Crear-y-poblar.md` | `CREATE TABLE`, `INSERT`, la BBDD de prácticas |
| 03 | `..._03-SELECT-basico.md` | `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`, `DISTINCT` |
| 04 | `..._04-Filtrado-avanzado.md` | `AND`/`OR`, `IN`, `BETWEEN`, `LIKE`, `NULL` |
| 05 | `..._05-Funciones.md` | Funciones de texto, número, fecha, `CASE` |
| 06 | `..._06-Agregacion-GROUP-BY.md` | `COUNT`, `SUM`, `AVG`, `GROUP BY`, `HAVING` |
| 07 | `..._07-JOINs.md` | `INNER`, `LEFT`, self-join, unir varias tablas |
| 08 | `..._08-Subconsultas.md` | Subconsultas, `IN`, `EXISTS`, correlacionadas |
| 09 | `..._09-Modificar-e-integridad.md` | `UPDATE`, `DELETE`, restricciones, transacciones |
| 10 | `..._10-Diseno-y-normalizacion.md` | Normalización, índices, vistas |
| 11 | `..._11-Window-functions-y-proyecto.md` | Funciones de ventana, CTEs, proyecto final |

## Ruta recomendada

Del 00 al 03, una sesión por módulo. Del 04 al 08, el corazón del curso: dedícales tiempo y muchos ejercicios. Del 09 al 11, sube el nivel; repártelos en dos sesiones cada uno.

Si ya conoces algo de SQL y solo quieres reforzar, salta directo al 06 (agregación) y sigue desde ahí.
