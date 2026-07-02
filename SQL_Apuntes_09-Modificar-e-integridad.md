# Módulo 09 — Modificar datos: UPDATE, DELETE, transacciones e integridad

Hasta ahora solo has leído datos. Una base de datos también se actualiza y se limpia. Este módulo cubre cómo cambiar (`UPDATE`) y borrar (`DELETE`) filas sin provocar un desastre, y cómo las transacciones y las restricciones protegen la coherencia de tus datos. Aquí un error de verdad hace daño, así que lee la sección de seguridad antes de tocar nada.

> Base de datos `tienda`. Si rompes algo, vuelve a ejecutar el script del módulo 02 y empiezas de cero.

## UPDATE: cambiar valores existentes

`UPDATE` modifica filas que ya existen. Indicas la tabla, qué columnas cambiar (`SET`) y, crucialmente, qué filas afecta (`WHERE`):

```sql
UPDATE productos
SET precio = 24.90
WHERE id = 2;
```

Puedes cambiar varias columnas a la vez:

```sql
UPDATE pedidos
SET estado = 'entregado', fecha = '2025-08-10'
WHERE id = 12;
```

Y calcular el nuevo valor a partir del actual. "Subir un 10% el precio de todos los periféricos":

```sql
UPDATE productos
SET precio = precio * 1.10
WHERE categoria = 'Periféricos';
```

## La regla de oro: el WHERE del UPDATE y del DELETE

Esto te lo grabas a fuego. **Un `UPDATE` o un `DELETE` sin `WHERE` afecta a TODAS las filas de la tabla.**

```sql
UPDATE productos SET precio = 0;   -- ¡pone TODOS los precios a 0!
DELETE FROM clientes;              -- ¡borra TODOS los clientes!
```

No hay "deshacer" mágico fuera de una transacción. Antes de ejecutar un `UPDATE` o `DELETE`, comprueba a qué filas afectará escribiendo primero un `SELECT` con el mismo `WHERE`:

```sql
-- 1. Primero MIRA qué vas a tocar:
SELECT * FROM productos WHERE categoria = 'Periféricos';
-- 2. Si son las filas correctas, cambia el SELECT por el UPDATE:
UPDATE productos SET precio = precio * 1.10 WHERE categoria = 'Periféricos';
```

Esta costumbre —probar con `SELECT` antes de modificar— te ahorrará disgustos serios. Hazla automática.

## DELETE: borrar filas

`DELETE` elimina filas que cumplen una condición:

```sql
DELETE FROM pedidos WHERE estado = 'cancelado';
DELETE FROM clientes WHERE id = 6;
```

Igual que con `UPDATE`: sin `WHERE` borra todo. Y recuerda las claves foráneas: no puedes borrar un cliente que tiene pedidos si eso dejaría pedidos huérfanos (la restricción lo impide). Tendrías que borrar antes sus pedidos, o configurar un borrado en cascada (más abajo).

> **TRUNCATE:** en MariaDB/MySQL existe `TRUNCATE TABLE productos;` para vaciar una tabla entera de golpe, más rápido que `DELETE` sin `WHERE`. SQLite no tiene `TRUNCATE`; usa `DELETE FROM productos;`. En ambos casos, vacía la tabla: úsalo con respeto.

## Transacciones: todo o nada

Una transacción agrupa varias operaciones en una unidad indivisible: o se aplican todas, o no se aplica ninguna. Es imprescindible cuando varias modificaciones deben cuadrar entre sí. El ejemplo clásico es una transferencia bancaria: restar de una cuenta y sumar a otra. Si solo se hace la mitad, el dinero desaparece.

```sql
BEGIN TRANSACTION;

UPDATE productos SET stock = stock - 1 WHERE id = 1;   -- vendemos un portátil
INSERT INTO pedidos (cliente_id, fecha, estado) VALUES (3, '2025-12-01', 'pendiente');

COMMIT;   -- confirma: ahora sí, los cambios son definitivos
```

`BEGIN TRANSACTION` abre la transacción. `COMMIT` la confirma y guarda todo. Si algo va mal antes del `COMMIT`, ejecutas `ROLLBACK` y se deshacen todos los cambios desde el `BEGIN`, como si nada hubiera pasado:

```sql
BEGIN TRANSACTION;
DELETE FROM clientes WHERE id = 2;
-- "uy, no era ese cliente"
ROLLBACK;   -- deshace el DELETE; el cliente 2 sigue ahí
```

Las transacciones son tu red de seguridad para operaciones delicadas. Cuando hagas cambios importantes a mano, envuélvelos en `BEGIN ... COMMIT` y tendrás la opción de `ROLLBACK` si te equivocas.

## Las propiedades ACID, en una frase

Las bases de datos serias garantizan **ACID**: Atomicidad (todo o nada), Consistencia (los datos siempre cumplen las reglas), Aislamiento (las transacciones simultáneas no se pisan) y Durabilidad (lo confirmado sobrevive a un apagón). No necesitas memorizarlo al detalle ahora, pero ten el concepto: las transacciones son lo que hace que un banco pueda confiar en su base de datos.

> **En MariaDB/MySQL:** las transacciones solo funcionan con el motor de almacenamiento **InnoDB** (el de por defecto hoy). El antiguo MyISAM no las soporta. En SQLite, toda operación va dentro de una transacción implícita aunque no la escribas.

## Integridad referencial: ON DELETE

Cuando defines una clave foránea, puedes decidir qué pasa con las filas hijas si se borra la fila padre. Se configura en el `CREATE TABLE`:

```sql
CREATE TABLE pedidos (
    id         INTEGER PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    fecha      TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE CASCADE
);
```

`ON DELETE CASCADE` significa: si borras un cliente, se borran automáticamente sus pedidos. Las alternativas: `ON DELETE RESTRICT` (impide borrar el cliente si tiene pedidos, el comportamiento por defecto) y `ON DELETE SET NULL` (pone `cliente_id` a `NULL` en los pedidos). Elige según convenga; `RESTRICT` es el más seguro porque te obliga a ser explícito.

## Buenas prácticas al modificar datos

Tres costumbres que te evitan estropicios: prueba siempre el `WHERE` con un `SELECT` antes de un `UPDATE`/`DELETE`; envuelve los cambios importantes en una transacción para poder hacer `ROLLBACK`; y haz copia de seguridad de la base de datos antes de operaciones masivas (en SQLite, copiar el archivo `.db` basta). El dato borrado sin copia no vuelve.

---

## Ejercicios

Trabaja sobre una copia de la base de datos (o reejecuta el script al terminar). Comprueba cada cambio con un `SELECT`.

**09.1** — Sube el precio del producto con `id = 4` (Monitor) a 210 €. Verifícalo.

**09.2** — Cambia el estado del pedido 13 a 'enviado' y ponle la fecha '2025-08-25'.

**09.3** — Aplica un descuento del 5% a todos los productos de la categoría 'Informática'. Comprueba antes con un `SELECT` a qué productos afectará.

**09.4** — Marca como 'cancelado' todos los pedidos que sigan en estado 'pendiente'.

**09.5** — Borra el producto que nunca se ha vendido y no tiene stock (la Webcam). Antes, comprueba con un `SELECT` que ninguna línea de pedido lo referencia (si lo hiciera, la clave foránea impediría el borrado).

**09.6** — Dentro de una transacción: resta 2 unidades al stock del producto 8 (Cargador) e inserta un nuevo pedido para el cliente 5. Luego haz `ROLLBACK` y comprueba que ni el stock ni los pedidos cambiaron.

**09.7** — Repite el ejercicio anterior pero con `COMMIT`, y comprueba que esta vez sí se aplicaron los cambios.

---

<details markdown="1">
<summary>Soluciones</summary>

**09.1**
```sql
UPDATE productos SET precio = 210 WHERE id = 4;
SELECT * FROM productos WHERE id = 4;
```

---

**09.2**
```sql
UPDATE pedidos SET estado = 'enviado', fecha = '2025-08-25' WHERE id = 13;
```

---

**09.3**
```sql
SELECT * FROM productos WHERE categoria = 'Informática';   -- Portátil y Tablet
UPDATE productos SET precio = precio * 0.95 WHERE categoria = 'Informática';
```

---

**09.4**
```sql
UPDATE pedidos SET estado = 'cancelado' WHERE estado = 'pendiente';
```

---

**09.5**
```sql
SELECT * FROM lineas_pedido WHERE producto_id = 5;   -- debe estar vacío
DELETE FROM productos WHERE id = 5;
```
La Webcam no aparece en ninguna línea de pedido, así que la clave foránea no bloquea el borrado.

---

**09.6**
```sql
BEGIN TRANSACTION;
UPDATE productos SET stock = stock - 2 WHERE id = 8;
INSERT INTO pedidos (cliente_id, fecha, estado) VALUES (5, '2025-12-10', 'pendiente');
ROLLBACK;
SELECT stock FROM productos WHERE id = 8;   -- sigue siendo 300
SELECT COUNT(*) FROM pedidos;               -- sigue siendo 7
```

---

**09.7**
```sql
BEGIN TRANSACTION;
UPDATE productos SET stock = stock - 2 WHERE id = 8;
INSERT INTO pedidos (cliente_id, fecha, estado) VALUES (5, '2025-12-10', 'pendiente');
COMMIT;
SELECT stock FROM productos WHERE id = 8;   -- ahora 298
SELECT COUNT(*) FROM pedidos;               -- ahora 8
```

</details>
