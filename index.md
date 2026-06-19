---
title: SQL desde cero hasta nivel avanzado
---

# SQL desde cero hasta nivel avanzado

Curso de apuntes para pasar de no haber escrito una consulta a manejar JOINs, subconsultas y funciones de ventana con soltura. Pensado para alumnado de FP de grado superior. Cada módulo combina teoría corta, consultas que puedes ejecutar tal cual, y ejercicios con sus soluciones plegadas al final.

El motor base es **SQLite**: no requiere instalar ningún servidor, va en un solo archivo y funciona en cualquier sistema. Donde MariaDB o MySQL hacen las cosas distinto, lo señalo en un recuadro **"En MariaDB/MySQL"**. Así aprendes con la herramienta más cómoda y, a la vez, sabes qué cambia cuando pases a un motor profesional.

## Cómo usar estos apuntes

Lee de arriba abajo. Cada módulo asume el anterior. No saltes a los JOINs sin dominar el `SELECT` y el `WHERE`. Escribe y ejecuta tú las consultas; leerlas no basta.

Las soluciones están dentro de cada módulo, plegadas al final (`<details>`). Intenta resolver antes de abrirlas.

## La base de datos de prácticas

Casi todos los módulos usan la misma base de datos de ejemplo: una tienda con clientes, productos, pedidos y líneas de pedido. El script completo está en el módulo 02 y también en el archivo [`SQL_Apuntes_99-Script-BBDD_v1.sql`](https://github.com/AmadorProf/SQL/blob/main/SQL_Apuntes_99-Script-BBDD_v1.sql). Ejecútalo una vez y tendrás los datos listos para todos los ejercicios.

## Qué necesitas

Una de estas opciones, de menos a más esfuerzo:

- **DB Browser for SQLite** ([sqlitebrowser.org](https://sqlitebrowser.org)): programa con ventana, ideal para empezar y ver las tablas. Recomendado.
- **SQLite Online** ([sqliteonline.com](https://sqliteonline.com)): ejecuta SQL en el navegador, sin instalar nada.
- **Línea de comandos** `sqlite3`: viene preinstalado en macOS y Linux.

## Índice de módulos

| # | Módulo | Qué aprendes |
|---|--------|--------------|
| 00 | [Entorno](SQL_Apuntes_00-Entorno_v1) | Qué es SQL, instalar SQLite, primera consulta |
| 01 | [Modelo relacional](SQL_Apuntes_01-Modelo-relacional_v1) | Tablas, claves, relaciones, tipos de datos |
| 02 | [Crear y poblar](SQL_Apuntes_02-Crear-y-poblar_v1) | `CREATE TABLE`, `INSERT`, la BBDD de prácticas |
| 03 | [SELECT básico](SQL_Apuntes_03-SELECT-basico_v1) | `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`, `DISTINCT` |
| 04 | [Filtrado avanzado](SQL_Apuntes_04-Filtrado-avanzado_v1) | `AND`/`OR`, `IN`, `BETWEEN`, `LIKE`, `NULL` |
| 05 | [Funciones](SQL_Apuntes_05-Funciones_v1) | Funciones de texto, número, fecha, `CASE` |
| 06 | [Agregación y GROUP BY](SQL_Apuntes_06-Agregacion-GROUP-BY_v1) | `COUNT`, `SUM`, `AVG`, `GROUP BY`, `HAVING` |
| 07 | [JOINs](SQL_Apuntes_07-JOINs_v1) | `INNER`, `LEFT`, self-join, unir varias tablas |
| 08 | [Subconsultas](SQL_Apuntes_08-Subconsultas_v1) | Subconsultas, `IN`, `EXISTS`, correlacionadas |
| 09 | [Modificar e integridad](SQL_Apuntes_09-Modificar-e-integridad_v1) | `UPDATE`, `DELETE`, restricciones, transacciones |
| 10 | [Diseño y normalización](SQL_Apuntes_10-Diseno-y-normalizacion_v1) | Normalización, índices, vistas |
| 11 | [Window functions y proyecto](SQL_Apuntes_11-Window-functions-y-proyecto_v1) | Funciones de ventana, CTEs, proyecto final |

## Ruta recomendada

Del 00 al 03, una sesión por módulo. Del 04 al 08, el corazón del curso: dedícales tiempo y muchos ejercicios. Del 09 al 11, sube el nivel; repártelos en dos sesiones cada uno.

Si ya conoces algo de SQL y solo quieres reforzar, salta directo al 06 (agregación) y sigue desde ahí.
