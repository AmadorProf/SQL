-- ============================================================
-- Base de datos de prácticas: TIENDA
-- Curso de SQL (SQLite). Ejecuta este script una vez.
-- ============================================================

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
