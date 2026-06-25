# SQL desde cero hasta nivel avanzado

[![Página web](https://img.shields.io/badge/Página_web-ver-4A90E2?style=flat-square&logo=github)](https://amadorprof.github.io/SQL/)
[![Licencia CC BY 4.0](https://img.shields.io/badge/Licencia-CC%20BY%204.0-green?style=flat-square)](https://creativecommons.org/licenses/by/4.0/)

Apuntes para pasar de no haber escrito una consulta a manejar JOINs, subconsultas y funciones de ventana con soltura. Pensado para alumnado de FP de grado superior. Cada módulo combina teoría corta, consultas que puedes ejecutar tal cual, y ejercicios con soluciones plegadas al final.

## Qué necesitas

Una de estas opciones, de menos a más esfuerzo:

- **DB Browser for SQLite** ([sqlitebrowser.org](https://sqlitebrowser.org)) — programa con ventana, ideal para empezar. Recomendado.
- **SQLite Online** ([sqliteonline.com](https://sqliteonline.com)) — ejecuta SQL en el navegador, sin instalar nada.
- **Línea de comandos** `sqlite3` — preinstalado en macOS y Linux.

El motor base es **SQLite**: no requiere servidor, va en un solo archivo y funciona en cualquier sistema. Donde MariaDB o MySQL hacen las cosas distinto, lo señalo en un recuadro. Así aprendes con la herramienta más cómoda y, a la vez, sabes qué cambia cuando pases a un motor profesional.

## Índice de módulos

| # | Archivo | Qué aprendes |
|---|---------|--------------|
| 00 | `..._00-Entorno_v1.md` | Qué es SQL, instalar SQLite, primera consulta |
| 01 | `..._01-Modelo-relacional_v1.md` | Tablas, claves, relaciones, tipos de datos |
| 02 | `..._02-Crear-y-poblar_v1.md` | `CREATE TABLE`, `INSERT`, la BBDD de prácticas |
| 03 | `..._03-SELECT-basico_v1.md` | `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`, `DISTINCT` |
| 04 | `..._04-Filtrado-avanzado_v1.md` | `AND`/`OR`, `IN`, `BETWEEN`, `LIKE`, `NULL` |
| 05 | `..._05-Funciones_v1.md` | Funciones de texto, número, fecha, `CASE` |
| 06 | `..._06-Agregacion-GROUP-BY_v1.md` | `COUNT`, `SUM`, `AVG`, `GROUP BY`, `HAVING` |
| 07 | `..._07-JOINs_v1.md` | `INNER`, `LEFT`, self-join, unir varias tablas |
| 08 | `..._08-Subconsultas_v1.md` | Subconsultas, `IN`, `EXISTS`, correlacionadas |
| 09 | `..._09-Modificar-e-integridad_v1.md` | `UPDATE`, `DELETE`, restricciones, transacciones |
| 10 | `..._10-Diseno-y-normalizacion_v1.md` | Normalización, índices, vistas |
| 11 | `..._11-Window-functions-y-proyecto_v1.md` | Funciones de ventana, CTEs, proyecto final |

## Cómo usar estos apuntes

Lee de arriba abajo. Cada módulo asume el anterior. No saltes a los JOINs sin dominar el `SELECT` y el `WHERE`. Escribe y ejecuta tú las consultas — leerlas no basta.

Las soluciones están dentro de cada `.md`, plegadas al final (`<details>`). Intenta resolver antes de abrirlas.

La base de datos de prácticas (tienda con clientes, productos y pedidos) está en el módulo 02 y en `SQL_Apuntes_99-Script-BBDD_v1.sql`. Ejecútalo una vez y tendrás los datos listos para todos los ejercicios.

**Ruta recomendada:** módulos 00–03 a un ritmo de uno por sesión. Módulos 04–08 son el corazón del curso: dedícales tiempo. Módulos 09–11 son los más avanzados; repártelos en dos sesiones cada uno.

---

Publicado bajo [Creative Commons Attribution 4.0 International](https://creativecommons.org/licenses/by/4.0/) — puedes usar, compartir y adaptar con atribución.