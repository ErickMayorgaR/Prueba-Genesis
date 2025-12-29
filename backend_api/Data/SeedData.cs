using backend_api.Models;

namespace backend_api.Data;

public static class SeedData
{
    public static async Task Initialize(AppDbContext context)
    {
        // ==========================================
        // CATEGORÍAS
        // ==========================================
        var catTamales = new Categoria { Nombre = "Tamales", Descripcion = "Tamales tradicionales guatemaltecos", Icono = "🫔" };
        var catBebidas = new Categoria { Nombre = "Bebidas", Descripcion = "Bebidas artesanales de maíz y cacao", Icono = "🥤" };
        
        context.Categorias.AddRange(catTamales, catBebidas);
        await context.SaveChangesAsync();

        // ==========================================
        // PRODUCTOS
        // ==========================================
        var productoTamal = new Producto 
        { 
            CategoriaId = catTamales.Id, 
            Codigo = "TAM-001", 
            Nombre = "Tamal Chapín", 
            Descripcion = "Tamal tradicional guatemalteco personalizable" 
        };
        
        var productoBebida = new Producto 
        { 
            CategoriaId = catBebidas.Id, 
            Codigo = "BEB-001", 
            Nombre = "Bebida Artesanal", 
            Descripcion = "Bebida tradicional de maíz o cacao" 
        };
        
        context.Productos.AddRange(productoTamal, productoBebida);
        await context.SaveChangesAsync();

        // ==========================================
        // PRESENTACIONES
        // ==========================================
        context.Presentaciones.AddRange(
            new Presentacion { ProductoId = productoTamal.Id, Nombre = "Unidad", Cantidad = 1, Precio = 15.00m, Orden = 1 },
            new Presentacion { ProductoId = productoTamal.Id, Nombre = "Media Docena", Cantidad = 6, Precio = 80.00m, Orden = 2 },
            new Presentacion { ProductoId = productoTamal.Id, Nombre = "Docena", Cantidad = 12, Precio = 150.00m, Orden = 3 },
            new Presentacion { ProductoId = productoBebida.Id, Nombre = "Vaso 12oz", Cantidad = 1, Precio = 10.00m, Orden = 1 },
            new Presentacion { ProductoId = productoBebida.Id, Nombre = "Jarro 1 Litro", Cantidad = 1, Precio = 35.00m, Orden = 2 }
        );
        await context.SaveChangesAsync();

        // ==========================================
        // ATRIBUTOS PARA TAMALES
        // ==========================================
        var attrMasa = new Atributo { CategoriaId = catTamales.Id, Nombre = "Tipo de Masa", Codigo = "masa", EsRequerido = true, Orden = 1 };
        var attrRelleno = new Atributo { CategoriaId = catTamales.Id, Nombre = "Relleno", Codigo = "relleno", EsRequerido = true, Orden = 2 };
        var attrEnvoltura = new Atributo { CategoriaId = catTamales.Id, Nombre = "Envoltura", Codigo = "envoltura", EsRequerido = true, Orden = 3 };
        var attrPicante = new Atributo { CategoriaId = catTamales.Id, Nombre = "Nivel de Picante", Codigo = "picante", EsRequerido = true, Orden = 4 };
        
        context.Atributos.AddRange(attrMasa, attrRelleno, attrEnvoltura, attrPicante);
        await context.SaveChangesAsync();

        // Opciones de Masa
        context.AtributoOpciones.AddRange(
            new AtributoOpcion { AtributoId = attrMasa.Id, Nombre = "Maíz Amarillo", Codigo = "maiz_amarillo", Orden = 1 },
            new AtributoOpcion { AtributoId = attrMasa.Id, Nombre = "Maíz Blanco", Codigo = "maiz_blanco", Orden = 2 },
            new AtributoOpcion { AtributoId = attrMasa.Id, Nombre = "Arroz", Codigo = "arroz", Orden = 3 }
        );

        // Opciones de Relleno
        context.AtributoOpciones.AddRange(
            new AtributoOpcion { AtributoId = attrRelleno.Id, Nombre = "Recado Rojo de Cerdo", Codigo = "recado_rojo", Orden = 1 },
            new AtributoOpcion { AtributoId = attrRelleno.Id, Nombre = "Negro de Pollo", Codigo = "negro_pollo", Orden = 2 },
            new AtributoOpcion { AtributoId = attrRelleno.Id, Nombre = "Chipilín Vegetariano", Codigo = "chipilin", Orden = 3 },
            new AtributoOpcion { AtributoId = attrRelleno.Id, Nombre = "Mezcla Estilo Chuchito", Codigo = "chuchito", Orden = 4 }
        );

        // Opciones de Envoltura
        context.AtributoOpciones.AddRange(
            new AtributoOpcion { AtributoId = attrEnvoltura.Id, Nombre = "Hoja de Plátano", Codigo = "hoja_platano", Orden = 1 },
            new AtributoOpcion { AtributoId = attrEnvoltura.Id, Nombre = "Tusa de Maíz", Codigo = "tusa", Orden = 2 }
        );

        // Opciones de Picante
        context.AtributoOpciones.AddRange(
            new AtributoOpcion { AtributoId = attrPicante.Id, Nombre = "Sin Chile", Codigo = "sin_chile", Orden = 1 },
            new AtributoOpcion { AtributoId = attrPicante.Id, Nombre = "Suave", Codigo = "suave", Orden = 2 },
            new AtributoOpcion { AtributoId = attrPicante.Id, Nombre = "Chapín (Picante)", Codigo = "chapin", Orden = 3 }
        );

        // ==========================================
        // ATRIBUTOS PARA BEBIDAS
        // ==========================================
        var attrTipo = new Atributo { CategoriaId = catBebidas.Id, Nombre = "Tipo de Bebida", Codigo = "tipo", EsRequerido = true, Orden = 1 };
        var attrEndulzante = new Atributo { CategoriaId = catBebidas.Id, Nombre = "Endulzante", Codigo = "endulzante", EsRequerido = true, Orden = 2 };
        var attrTopping = new Atributo { CategoriaId = catBebidas.Id, Nombre = "Toppings", Codigo = "topping", EsMultiple = true, EsRequerido = false, Orden = 3 };
        
        context.Atributos.AddRange(attrTipo, attrEndulzante, attrTopping);
        await context.SaveChangesAsync();

        // Opciones de Tipo de Bebida
        context.AtributoOpciones.AddRange(
            new AtributoOpcion { AtributoId = attrTipo.Id, Nombre = "Atol de Elote", Codigo = "atol_elote", Orden = 1 },
            new AtributoOpcion { AtributoId = attrTipo.Id, Nombre = "Atole Shuco", Codigo = "shuco", Orden = 2 },
            new AtributoOpcion { AtributoId = attrTipo.Id, Nombre = "Pinol", Codigo = "pinol", Orden = 3 },
            new AtributoOpcion { AtributoId = attrTipo.Id, Nombre = "Cacao Batido", Codigo = "cacao", Orden = 4 }
        );

        // Opciones de Endulzante
        context.AtributoOpciones.AddRange(
            new AtributoOpcion { AtributoId = attrEndulzante.Id, Nombre = "Panela", Codigo = "panela", Orden = 1 },
            new AtributoOpcion { AtributoId = attrEndulzante.Id, Nombre = "Miel", Codigo = "miel", Orden = 2 },
            new AtributoOpcion { AtributoId = attrEndulzante.Id, Nombre = "Sin Azúcar", Codigo = "sin_azucar", Orden = 3 }
        );

        // Opciones de Toppings
        context.AtributoOpciones.AddRange(
            new AtributoOpcion { AtributoId = attrTopping.Id, Nombre = "Malvaviscos", Codigo = "malvaviscos", PrecioExtra = 3.00m, Orden = 1 },
            new AtributoOpcion { AtributoId = attrTopping.Id, Nombre = "Canela", Codigo = "canela", PrecioExtra = 2.00m, Orden = 2 },
            new AtributoOpcion { AtributoId = attrTopping.Id, Nombre = "Ralladura de Cacao", Codigo = "ralladura_cacao", PrecioExtra = 5.00m, Orden = 3 }
        );

        await context.SaveChangesAsync();

        // ==========================================
        // COMBOS
        // ==========================================
        var presentaciones = context.Presentaciones.ToList();
        var docena = presentaciones.First(p => p.Nombre == "Docena");
        var jarro = presentaciones.First(p => p.Nombre == "Jarro 1 Litro");

        var comboFiesta = new Combo
        {
            Nombre = "Fiesta Patronal",
            Descripcion = "Docena surtida de tamales + 2 jarros familiares",
            Precio = 200.00m,
            Tipo = "FIJO"
        };
        
        var comboMadrugada = new Combo
        {
            Nombre = "Madrugada del 24",
            Descripcion = "3 docenas + 4 jarros + termo de barro conmemorativo",
            Precio = 550.00m,
            Tipo = "FIJO"
        };

        var comboEstacional = new Combo
        {
            Nombre = "Combo Estacional",
            Descripcion = "Combo especial de temporada",
            Precio = 180.00m,
            Tipo = "ESTACIONAL",
            FechaInicio = new DateTime(2025, 12, 1),
            FechaFin = new DateTime(2025, 12, 31)
        };

        context.Combos.AddRange(comboFiesta, comboMadrugada, comboEstacional);
        await context.SaveChangesAsync();

        // Items de combos
        context.ComboItems.AddRange(
            new ComboItem { ComboId = comboFiesta.Id, PresentacionId = docena.Id, Cantidad = 1, Notas = "Docena surtida" },
            new ComboItem { ComboId = comboFiesta.Id, PresentacionId = jarro.Id, Cantidad = 2, Notas = "Jarros familiares" },
            new ComboItem { ComboId = comboMadrugada.Id, PresentacionId = docena.Id, Cantidad = 3, Notas = "3 docenas surtidas" },
            new ComboItem { ComboId = comboMadrugada.Id, PresentacionId = jarro.Id, Cantidad = 4, Notas = "4 jarros" },
            new ComboItem { ComboId = comboEstacional.Id, PresentacionId = docena.Id, Cantidad = 1, Notas = "Docena especial de temporada" }
        );

        // ==========================================
        // MATERIAS PRIMAS
        // ==========================================
        context.MateriasPrimas.AddRange(
            new MateriaPrima { Categoria = "Masa", Nombre = "Masa de Maíz Amarillo", UnidadMedida = "kg", StockActual = 50, StockMinimo = 10, PuntoCritico = 5, CostoPromedio = 8.00m },
            new MateriaPrima { Categoria = "Masa", Nombre = "Masa de Maíz Blanco", UnidadMedida = "kg", StockActual = 30, StockMinimo = 10, PuntoCritico = 5, CostoPromedio = 8.50m },
            new MateriaPrima { Categoria = "Masa", Nombre = "Masa de Arroz", UnidadMedida = "kg", StockActual = 15, StockMinimo = 5, PuntoCritico = 2, CostoPromedio = 12.00m },
            new MateriaPrima { Categoria = "Hojas", Nombre = "Hoja de Plátano", UnidadMedida = "unidad", StockActual = 200, StockMinimo = 100, PuntoCritico = 50, CostoPromedio = 0.50m },
            new MateriaPrima { Categoria = "Hojas", Nombre = "Tusa de Maíz", UnidadMedida = "unidad", StockActual = 150, StockMinimo = 100, PuntoCritico = 50, CostoPromedio = 0.25m },
            new MateriaPrima { Categoria = "Proteínas", Nombre = "Cerdo", UnidadMedida = "kg", StockActual = 20, StockMinimo = 5, PuntoCritico = 2, CostoPromedio = 45.00m },
            new MateriaPrima { Categoria = "Proteínas", Nombre = "Pollo", UnidadMedida = "kg", StockActual = 25, StockMinimo = 5, PuntoCritico = 2, CostoPromedio = 35.00m },
            new MateriaPrima { Categoria = "Granos", Nombre = "Maíz para Atol", UnidadMedida = "kg", StockActual = 40, StockMinimo = 10, PuntoCritico = 5, CostoPromedio = 6.00m },
            new MateriaPrima { Categoria = "Granos", Nombre = "Cacao", UnidadMedida = "kg", StockActual = 10, StockMinimo = 3, PuntoCritico = 1, CostoPromedio = 80.00m },
            new MateriaPrima { Categoria = "Endulzantes", Nombre = "Panela", UnidadMedida = "kg", StockActual = 20, StockMinimo = 5, PuntoCritico = 2, CostoPromedio = 15.00m },
            new MateriaPrima { Categoria = "Endulzantes", Nombre = "Miel", UnidadMedida = "litro", StockActual = 8, StockMinimo = 3, PuntoCritico = 1, CostoPromedio = 60.00m },
            new MateriaPrima { Categoria = "Especias", Nombre = "Chile Guaque", UnidadMedida = "kg", StockActual = 5, StockMinimo = 2, PuntoCritico = 0.5m, CostoPromedio = 50.00m },
            new MateriaPrima { Categoria = "Empaques", Nombre = "Bolsa Térmica", UnidadMedida = "unidad", StockActual = 100, StockMinimo = 50, PuntoCritico = 20, CostoPromedio = 2.00m },
            new MateriaPrima { Categoria = "Combustible", Nombre = "Gas Propano", UnidadMedida = "libra", StockActual = 75, StockMinimo = 50, PuntoCritico = 20, CostoPromedio = 5.00m }
        );

        // ==========================================
        // SUCURSAL
        // ==========================================
        context.Sucursales.Add(new Sucursal
        {
            Nombre = "Casa Central",
            Direccion = "6ta Avenida, Zona 1, Guatemala",
            Telefono = "2222-3333"
        });

        await context.SaveChangesAsync();
    }
}
