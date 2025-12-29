USE NegocioCocina
GO

-- MOVIMIENTOS DE INVENTARIO (20)
INSERT INTO InventarioMovimientos (MateriaPrimaId, Tipo, Cantidad, CostoUnitario, Motivo, Fecha) VALUES
(1, 'E', 50.00, 8.00, 'Compra semanal', DATEADD(day, -25, GETDATE())),
(2, 'E', 35.00, 8.50, 'Compra semanal', DATEADD(day, -25, GETDATE())),
(3, 'E', 20.00, 12.00, 'Compra semanal', DATEADD(day, -25, GETDATE())),
(4, 'E', 200.00, 0.50, 'Compra semanal', DATEADD(day, -25, GETDATE())),
(5, 'E', 150.00, 0.25, 'Compra semanal', DATEADD(day, -25, GETDATE())),
(6, 'E', 25.00, 45.00, 'Compra semanal', DATEADD(day, -25, GETDATE())),
(7, 'E', 25.00, 35.00, 'Compra semanal', DATEADD(day, -25, GETDATE())),
(8, 'E', 40.00, 6.00, 'Compra semanal', DATEADD(day, -25, GETDATE())),
(9, 'E', 12.00, 80.00, 'Compra semanal', DATEADD(day, -25, GETDATE())),
(10, 'E', 25.00, 15.00, 'Compra semanal', DATEADD(day, -25, GETDATE())),
(1, 'S', 12.00, 8.00, 'Producción', DATEADD(day, -20, GETDATE())),
(4, 'S', 50.00, 0.50, 'Producción', DATEADD(day, -20, GETDATE())),
(6, 'S', 8.00, 45.00, 'Producción', DATEADD(day, -18, GETDATE())),
(7, 'S', 6.00, 35.00, 'Producción', DATEADD(day, -18, GETDATE())),
(8, 'S', 10.00, 6.00, 'Bebidas', DATEADD(day, -15, GETDATE())),
(1, 'M', 3.00, 8.00, 'Masa dañada', DATEADD(day, -10, GETDATE())),
(7, 'M', 2.00, 35.00, 'Pollo vencido', DATEADD(day, -8, GETDATE())),
(9, 'M', 1.00, 80.00, 'Cacao con moho', DATEADD(day, -5, GETDATE())),
(4, 'M', 20.00, 0.50, 'Hojas rotas', DATEADD(day, -3, GETDATE())),
(1, 'S', 5.00, 8.00, 'Producción hoy', GETDATE());

-- VENTAS DEL MES (11)
SET IDENTITY_INSERT Ventas ON;

INSERT INTO Ventas (Id, SucursalId, Codigo, Fecha, Subtotal, Descuento, Total, Estado, Sincronizado) VALUES
(1, 1, 'V-001', DATEADD(day, -28, GETDATE()), 150.00, 0, 150.00, 'COMPLETADA', 1),
(2, 1, 'V-002', DATEADD(day, -25, GETDATE()), 80.00, 0, 80.00, 'COMPLETADA', 1),
(3, 1, 'V-003', DATEADD(day, -22, GETDATE()), 200.00, 0, 200.00, 'COMPLETADA', 1),
(4, 1, 'V-004', DATEADD(day, -18, GETDATE()), 35.00, 0, 35.00, 'COMPLETADA', 1),
(5, 1, 'V-005', DATEADD(day, -15, GETDATE()), 550.00, 0, 550.00, 'COMPLETADA', 1),
(6, 1, 'V-006', DATEADD(day, -12, GETDATE()), 95.00, 0, 95.00, 'COMPLETADA', 1),
(7, 1, 'V-007', DATEADD(day, -10, GETDATE()), 200.00, 0, 200.00, 'COMPLETADA', 1),
(8, 1, 'V-008', DATEADD(day, -8, GETDATE()), 150.00, 15, 135.00, 'COMPLETADA', 1),
(9, 1, 'V-009', DATEADD(day, -5, GETDATE()), 80.00, 0, 80.00, 'COMPLETADA', 1),
(10, 1, 'V-010', DATEADD(day, -3, GETDATE()), 65.00, 0, 65.00, 'COMPLETADA', 1),
(11, 1, 'V-011', DATEADD(day, -1, GETDATE()), 200.00, 0, 200.00, 'COMPLETADA', 1);

-- VENTAS DE HOY (4)
INSERT INTO Ventas (Id, SucursalId, Codigo, Fecha, Subtotal, Descuento, Total, Estado, Sincronizado) VALUES
(12, 1, 'V-HOY-001', GETDATE(), 150.00, 0, 150.00, 'COMPLETADA', 1),
(13, 1, 'V-HOY-002', GETDATE(), 35.00, 0, 35.00, 'COMPLETADA', 1),
(14, 1, 'V-HOY-003', GETDATE(), 200.00, 0, 200.00, 'COMPLETADA', 1),
(15, 1, 'V-HOY-004', GETDATE(), 95.00, 0, 95.00, 'COMPLETADA', 1);

SET IDENTITY_INSERT Ventas OFF;

-- ITEMS DE VENTAS (19)
SET IDENTITY_INSERT VentaItems ON;

INSERT INTO VentaItems (Id, VentaId, PresentacionId, ComboId, Cantidad, PrecioUnitario, PrecioExtras, Subtotal, Personalizacion) VALUES
(1, 1, 3, NULL, 1, 150.00, 0, 150.00, '{"masa":{"opcionId":1,"nombre":"Maíz Amarillo"},"relleno":{"opcionId":4,"nombre":"Recado Rojo de Cerdo"},"picante":{"opcionId":12,"nombre":"Chapín"}}'),
(2, 2, 2, NULL, 1, 80.00, 0, 80.00, '{"masa":{"opcionId":2,"nombre":"Maíz Blanco"},"relleno":{"opcionId":5,"nombre":"Negro de Pollo"},"picante":{"opcionId":10,"nombre":"Sin Chile"}}'),
(3, 3, NULL, 1, 1, 200.00, 0, 200.00, NULL),
(4, 4, 4, NULL, 2, 10.00, 0, 20.00, '{"tipo":{"opcionId":13,"nombre":"Atol de Elote"},"endulzante":{"opcionId":17,"nombre":"Panela"}}'),
(5, 4, 1, NULL, 1, 15.00, 0, 15.00, '{"masa":{"opcionId":1,"nombre":"Maíz Amarillo"},"relleno":{"opcionId":4,"nombre":"Recado Rojo de Cerdo"},"picante":{"opcionId":11,"nombre":"Suave"}}'),
(6, 5, NULL, 2, 1, 550.00, 0, 550.00, NULL),
(7, 6, 1, NULL, 4, 15.00, 0, 60.00, '{"masa":{"opcionId":1,"nombre":"Maíz Amarillo"},"relleno":{"opcionId":6,"nombre":"Chipilín Vegetariano"},"picante":{"opcionId":10,"nombre":"Sin Chile"}}'),
(8, 6, 5, NULL, 1, 35.00, 0, 35.00, '{"tipo":{"opcionId":15,"nombre":"Pinol"},"endulzante":{"opcionId":19,"nombre":"Sin Azúcar"}}'),
(9, 7, NULL, 1, 1, 200.00, 0, 200.00, NULL),
(10, 8, 3, NULL, 1, 150.00, 0, 150.00, '{"masa":{"opcionId":3,"nombre":"Arroz"},"relleno":{"opcionId":7,"nombre":"Mezcla Estilo Chuchito"},"picante":{"opcionId":12,"nombre":"Chapín"}}'),
(11, 9, 2, NULL, 1, 80.00, 0, 80.00, '{"masa":{"opcionId":1,"nombre":"Maíz Amarillo"},"relleno":{"opcionId":5,"nombre":"Negro de Pollo"},"picante":{"opcionId":10,"nombre":"Sin Chile"}}'),
(12, 10, 1, NULL, 3, 15.00, 0, 45.00, '{"masa":{"opcionId":2,"nombre":"Maíz Blanco"},"relleno":{"opcionId":4,"nombre":"Recado Rojo de Cerdo"},"picante":{"opcionId":12,"nombre":"Chapín"}}'),
(13, 10, 4, NULL, 2, 10.00, 0, 20.00, '{"tipo":{"opcionId":16,"nombre":"Cacao Batido"},"endulzante":{"opcionId":17,"nombre":"Panela"}}'),
(14, 11, NULL, 1, 1, 200.00, 0, 200.00, NULL),
(15, 12, 3, NULL, 1, 150.00, 0, 150.00, '{"masa":{"opcionId":1,"nombre":"Maíz Amarillo"},"relleno":{"opcionId":4,"nombre":"Recado Rojo de Cerdo"},"picante":{"opcionId":12,"nombre":"Chapín"}}'),
(16, 13, 4, NULL, 2, 10.00, 0, 20.00, '{"tipo":{"opcionId":13,"nombre":"Atol de Elote"},"endulzante":{"opcionId":17,"nombre":"Panela"}}'),
(17, 13, 1, NULL, 1, 15.00, 0, 15.00, '{"masa":{"opcionId":1,"nombre":"Maíz Amarillo"},"relleno":{"opcionId":6,"nombre":"Chipilín Vegetariano"},"picante":{"opcionId":10,"nombre":"Sin Chile"}}'),
(18, 14, NULL, 1, 1, 200.00, 0, 200.00, NULL),
(19, 15, 1, NULL, 4, 15.00, 0, 60.00, '{"masa":{"opcionId":1,"nombre":"Maíz Amarillo"},"relleno":{"opcionId":4,"nombre":"Recado Rojo de Cerdo"},"picante":{"opcionId":12,"nombre":"Chapín"}}');

SET IDENTITY_INSERT VentaItems OFF;

-- VERIFICACIÓN
SELECT 'Ventas HOY' AS Tipo, COUNT(*) AS Cantidad, SUM(Total) AS Total FROM Ventas WHERE CAST(Fecha AS DATE) = CAST(GETDATE() AS DATE) AND Estado = 'COMPLETADA'
UNION ALL
SELECT 'Ventas MES', COUNT(*), SUM(Total) FROM Ventas WHERE MONTH(Fecha) = MONTH(GETDATE()) AND Estado = 'COMPLETADA'
UNION ALL
SELECT 'Mermas', COUNT(*), SUM(Cantidad * CostoUnitario) FROM InventarioMovimientos WHERE Tipo = 'M'
UNION ALL
SELECT 'Movimientos', COUNT(*), 0 FROM InventarioMovimientos;