IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'NegocioCocina')
BEGIN
    CREATE DATABASE NegocioCocina
END
GO

USE NegocioCocina
GO

-- PRODUCTOS

CREATE TABLE Categorias (
    Id INT PRIMARY KEY IDENTITY,
    Nombre NVARCHAR(50) NOT NULL,           -- 'Tamales', 'Bebidas'
    Descripcion NVARCHAR(200),
    Icono NVARCHAR(50),
    Activo BIT DEFAULT 1
);

CREATE TABLE Productos (
    Id INT PRIMARY KEY IDENTITY,
    CategoriaId INT FOREIGN KEY REFERENCES Categorias(Id),
    Codigo NVARCHAR(20) UNIQUE,
    Nombre NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(500),
    ImagenUrl NVARCHAR(300),
    Activo BIT DEFAULT 1
);

-- Presentaciones/Tamaños por Producto
CREATE TABLE Presentaciones (
    Id INT PRIMARY KEY IDENTITY,
    ProductoId INT FOREIGN KEY REFERENCES Productos(Id),
    Nombre NVARCHAR(50) NOT NULL,           -- 'Unidad', 'Media Docena', 'Vaso 12oz'
    Cantidad INT DEFAULT 1,                  -- 1, 6, 12 (para tamales)
    Precio DECIMAL(10,2) NOT NULL,
    Orden INT DEFAULT 0,
    Activo BIT DEFAULT 1
);



-- Atributos configurables por categoría
CREATE TABLE Atributos (
    Id INT PRIMARY KEY IDENTITY,
    CategoriaId INT FOREIGN KEY REFERENCES Categorias(Id),
    Nombre NVARCHAR(50) NOT NULL,           -- 'Tipo de Masa', 'Relleno', 'Picante'
    Codigo NVARCHAR(30) NOT NULL,           -- 'masa', 'relleno', 'picante'
    EsMultiple BIT DEFAULT 0,               -- Si permite selección múltiple (toppings)
    EsRequerido BIT DEFAULT 1,
    Orden INT DEFAULT 0,
    Activo BIT DEFAULT 1,
    
    UNIQUE(CategoriaId, Codigo)
);

-- Opciones disponibles para cada atributo
CREATE TABLE AtributoOpciones (
    Id INT PRIMARY KEY IDENTITY,
    AtributoId INT FOREIGN KEY REFERENCES Atributos(Id),
    Nombre NVARCHAR(50) NOT NULL,           -- 'Maíz Amarillo', 'Recado Rojo'
    Codigo NVARCHAR(30) NOT NULL,
    PrecioExtra DECIMAL(10,2) DEFAULT 0,    -- Si aplica cargo extra
    Orden INT DEFAULT 0,
    Activo BIT DEFAULT 1
);

-- COMBOS

CREATE TABLE Combos (
    Id INT PRIMARY KEY IDENTITY,
    Nombre NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(500),
    Precio DECIMAL(10,2) NOT NULL,
    Tipo NVARCHAR(20) DEFAULT 'FIJO',       -- 'FIJO', 'ESTACIONAL'
    FechaInicio DATE NULL,
    FechaFin DATE NULL,
    Activo BIT DEFAULT 1
);

CREATE TABLE ComboItems (
    Id INT PRIMARY KEY IDENTITY,
    ComboId INT FOREIGN KEY REFERENCES Combos(Id),
    PresentacionId INT FOREIGN KEY REFERENCES Presentaciones(Id),
    Cantidad INT NOT NULL,
    Notas NVARCHAR(100)                     -- 'Surtido', 'A elegir'
);

-- INVENTARIO

CREATE TABLE MateriaPrimas (
    Id INT PRIMARY KEY IDENTITY,
    Categoria NVARCHAR(50) NOT NULL,        -- 'Masa', 'Hojas', 'Proteínas', etc.
    Nombre NVARCHAR(100) NOT NULL,
    UnidadMedida NVARCHAR(20) NOT NULL,
    StockActual DECIMAL(10,2) DEFAULT 0,
    StockMinimo DECIMAL(10,2) DEFAULT 0,
    PuntoCritico DECIMAL(10,2) DEFAULT 0,
    CostoPromedio DECIMAL(10,2) DEFAULT 0,
    Activo BIT DEFAULT 1
);

CREATE TABLE InventarioMovimientos (
    Id INT PRIMARY KEY IDENTITY,
    MateriaPrimaId INT FOREIGN KEY REFERENCES MateriaPrimas(Id),
    Tipo CHAR(1) NOT NULL,                  -- 'E' Entrada, 'S' Salida, 'M' Merma
    Cantidad DECIMAL(10,2) NOT NULL,
    CostoUnitario DECIMAL(10,2),
    Motivo NVARCHAR(200),
    Fecha DATETIME2 DEFAULT GETUTCDATE(),
    UsuarioId INT NULL
);

-- ============================================
-- VENTAS
-- ============================================

CREATE TABLE Sucursales (
    Id INT PRIMARY KEY IDENTITY,
    Nombre NVARCHAR(100) NOT NULL,
    Direccion NVARCHAR(200),
    Telefono NVARCHAR(20),
    Activo BIT DEFAULT 1
);

CREATE TABLE Ventas (
    Id INT PRIMARY KEY IDENTITY,
    SucursalId INT FOREIGN KEY REFERENCES Sucursales(Id),
    Codigo NVARCHAR(20),                    -- 'V-2025-00001'
    Fecha DATETIME2 DEFAULT GETUTCDATE(),
    Subtotal DECIMAL(10,2) NOT NULL,
    Descuento DECIMAL(10,2) DEFAULT 0,
    Total DECIMAL(10,2) NOT NULL,
    Estado NVARCHAR(20) DEFAULT 'COMPLETADA',
    Sincronizado BIT DEFAULT 1
);

CREATE TABLE VentaItems (
    Id INT PRIMARY KEY IDENTITY,
    VentaId INT FOREIGN KEY REFERENCES Ventas(Id),
    
    PresentacionId INT NULL FOREIGN KEY REFERENCES Presentaciones(Id),
    ComboId INT NULL FOREIGN KEY REFERENCES Combos(Id),
    
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    PrecioExtras DECIMAL(10,2) DEFAULT 0,
    Subtotal DECIMAL(10,2) NOT NULL,
    
    Personalizacion NVARCHAR(MAX) NULL,
    
    CONSTRAINT CK_TipoItem CHECK (
        (PresentacionId IS NOT NULL AND ComboId IS NULL) OR
        (PresentacionId IS NULL AND ComboId IS NOT NULL)
    )
);