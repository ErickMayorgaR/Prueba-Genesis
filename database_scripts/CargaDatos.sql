-- LIMPIAR
/*
DELETE FROM VentaItems;
DELETE FROM Ventas;
DELETE FROM ComboItems;
DELETE FROM Combos;
DELETE FROM InventarioMovimientos;
DELETE FROM MateriaPrimas;
DELETE FROM AtributoOpciones;
DELETE FROM Atributos;
DELETE FROM Presentaciones;
DELETE FROM Productos;
DELETE FROM Categorias;
DELETE FROM Sucursales;
*/

-- Categorías
INSERT INTO Categorias (Nombre, Descripcion) VALUES
('Tamales', 'Tamales tradicionales guatemaltecos'),
('Bebidas', 'Bebidas artesanales de maíz y cacao');

-- Productos
INSERT INTO Productos (CategoriaId, Codigo, Nombre) VALUES
(1, 'TAM-001', 'Tamal Chapín'),
(2, 'BEB-001', 'Bebida Artesanal');

-- Presentaciones
INSERT INTO Presentaciones (ProductoId, Nombre, Cantidad, Precio, Orden) VALUES
(1, 'Unidad', 1, 15.00, 1),
(1, 'Media Docena', 6, 80.00, 2),
(1, 'Docena', 12, 150.00, 3),
(2, 'Vaso 12oz', 1, 10.00, 1),
(2, 'Jarro 1 Litro', 1, 35.00, 2);

-- Atributos para Tamales (CategoriaId = 1)
INSERT INTO Atributos (CategoriaId, Nombre, Codigo, EsMultiple, Orden) VALUES
(1, 'Tipo de Masa', 'masa', 0, 1),
(1, 'Relleno', 'relleno', 0, 2),
(1, 'Envoltura', 'envoltura', 0, 3),
(1, 'Nivel de Picante', 'picante', 0, 4);

-- Atributos para Bebidas (CategoriaId = 2)
INSERT INTO Atributos (CategoriaId, Nombre, Codigo, EsMultiple, Orden) VALUES
(2, 'Tipo de Bebida', 'tipo', 0, 1),
(2, 'Endulzante', 'endulzante', 0, 2),
(2, 'Toppings', 'topping', 1, 3);  -- EsMultiple = 1

-- Opciones para cada atributo
-- Masa (AtributoId = 1)
INSERT INTO AtributoOpciones (AtributoId, Nombre, Codigo, Orden) VALUES
(1, 'Maíz Amarillo', 'maiz_amarillo', 1),
(1, 'Maíz Blanco', 'maiz_blanco', 2),
(1, 'Arroz', 'arroz', 3);

-- Relleno (AtributoId = 2)
INSERT INTO AtributoOpciones (AtributoId, Nombre, Codigo, Orden) VALUES
(2, 'Recado Rojo de Cerdo', 'recado_rojo', 1),
(2, 'Negro de Pollo', 'negro_pollo', 2),
(2, 'Chipilín Vegetariano', 'chipilin', 3),
(2, 'Mezcla Estilo Chuchito', 'chuchito', 4);

-- Envoltura (AtributoId = 3)
INSERT INTO AtributoOpciones (AtributoId, Nombre, Codigo, Orden) VALUES
(3, 'Hoja de Plátano', 'hoja_platano', 1),
(3, 'Tusa de Maíz', 'tusa', 2);

-- Picante (AtributoId = 4)
INSERT INTO AtributoOpciones (AtributoId, Nombre, Codigo, Orden) VALUES
(4, 'Sin Chile', 'sin_chile', 1),
(4, 'Suave', 'suave', 2),
(4, 'Chapín', 'chapin', 3);

-- Tipo Bebida (AtributoId = 5)
INSERT INTO AtributoOpciones (AtributoId, Nombre, Codigo, Orden) VALUES
(5, 'Atol de Elote', 'atol_elote', 1),
(5, 'Atole Shuco', 'shuco', 2),
(5, 'Pinol', 'pinol', 3),
(5, 'Cacao Batido', 'cacao', 4);

-- Endulzante (AtributoId = 6)
INSERT INTO AtributoOpciones (AtributoId, Nombre, Codigo, Orden) VALUES
(6, 'Panela', 'panela', 1),
(6, 'Miel', 'miel', 2),
(6, 'Sin Azúcar', 'sin_azucar', 3);

-- Toppings (AtributoId = 7)
INSERT INTO AtributoOpciones (AtributoId, Nombre, Codigo, Orden) VALUES
(7, 'Malvaviscos', 'malvaviscos', 1),
(7, 'Canela', 'canela', 2),
(7, 'Ralladura de Cacao', 'ralladura_cacao', 3);

-- Combos
INSERT INTO Combos (Nombre, Descripcion, Precio, Tipo) VALUES
('Fiesta Patronal', 'Docena surtida de tamales + 2 jarros familiares', 200.00, 'FIJO'),
('Madrugada del 24', '3 docenas + 4 jarros + termo de barro', 550.00, 'FIJO'),
('Combo Estacional', 'Varía según temporada', 180.00, 'ESTACIONAL');

-- Combo Items (ejemplo Fiesta Patronal)
INSERT INTO ComboItems (ComboId, PresentacionId, Cantidad, Notas) VALUES
(1, 3, 1, 'Docena surtida'),      -- 1 docena de tamales
(1, 5, 2, 'Jarros familiares');   -- 2 jarros de 1L

-- Sucursal default
INSERT INTO Sucursales (Nombre, Direccion) VALUES
('Central', 'Zona 1, Guatemala');

-- Materias Primas
INSERT INTO MateriaPrimas (Categoria, Nombre, UnidadMedida, StockActual, StockMinimo, PuntoCritico) VALUES
('Masa', 'Masa de Maíz Amarillo', 'kg', 30.00, 10, 5),
('Masa', 'Masa de Maíz Blanco', 'kg', 35.00, 10, 5),
('Masa', 'Masa de Arroz', 'kg', 20.00, 5, 2),
('Hojas', 'Hoja de Plátano', 'unidad', 130.00, 100, 50),
('Hojas', 'Tusa de Maíz', 'unidad', 150.00, 100, 50),
('Proteínas', 'Cerdo', 'kg', 17.00, 5, 2),
('Proteínas', 'Pollo', 'kg', 17.00, 5, 2),
('Granos', 'Maíz para Atol', 'kg', 30.00, 10, 5),
('Granos', 'Cacao', 'kg', 11.00, 3, 1),
('Endulzantes', 'Panela', 'kg', 25.00, 5, 2),
('Endulzantes', 'Miel', 'litro', 3.00, 3, 1),
('Especias', 'Chile Guaque', 'kg', 2.00, 2, 0.5),
('Empaques', 'Bolsa Térmica', 'unidad', 50.00, 50, 20),
('Combustible', 'Gas Propano', 'libra', 80.00, 50, 20);