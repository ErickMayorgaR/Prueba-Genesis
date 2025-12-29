namespace backend_api.DTOs;

// ==========================================
// CATÁLOGO DTOs
// ==========================================

public class CatalogoCompletoDto
{
    public List<CategoriaDto> Categorias { get; set; } = new();
    public List<ComboDto> Combos { get; set; } = new();
}

public class CategoriaDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public string? Icono { get; set; }
    public List<ProductoDto> Productos { get; set; } = new();
    public List<AtributoDto> Atributos { get; set; } = new();
}

public class ProductoDto
{
    public int Id { get; set; }
    public string? Codigo { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public string? ImagenUrl { get; set; }
    public List<PresentacionDto> Presentaciones { get; set; } = new();
}

public class PresentacionDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public int Cantidad { get; set; }
    public decimal Precio { get; set; }
}

public class AtributoDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Codigo { get; set; } = string.Empty;
    public bool EsMultiple { get; set; }
    public bool EsRequerido { get; set; }
    public List<OpcionDto> Opciones { get; set; } = new();
}

public class OpcionDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Codigo { get; set; } = string.Empty;
    public decimal PrecioExtra { get; set; }
}

// ==========================================
// COMBO DTOs
// ==========================================

public class ComboDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public decimal Precio { get; set; }
    public string Tipo { get; set; } = string.Empty;
    public DateTime? FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public List<ComboItemDto> Items { get; set; } = new();
}

public class ComboItemDto
{
    public int Id { get; set; }
    public int PresentacionId { get; set; }
    public string PresentacionNombre { get; set; } = string.Empty;
    public string ProductoNombre { get; set; } = string.Empty;
    public int Cantidad { get; set; }
    public string? Notas { get; set; }
}

public class CrearComboDto
{
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public decimal Precio { get; set; }
    public string Tipo { get; set; } = "FIJO";
    public DateTime? FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public List<CrearComboItemDto> Items { get; set; } = new();
}

public class CrearComboItemDto
{
    public int PresentacionId { get; set; }
    public int Cantidad { get; set; }
    public string? Notas { get; set; }
}

// ==========================================
// INVENTARIO DTOs
// ==========================================

public class MateriaPrimaDto
{
    public int Id { get; set; }
    public string Categoria { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public string UnidadMedida { get; set; } = string.Empty;
    public decimal StockActual { get; set; }
    public decimal StockMinimo { get; set; }
    public decimal PuntoCritico { get; set; }
    public decimal CostoPromedio { get; set; }
    public bool EnPuntoCritico => StockActual <= PuntoCritico;
    public bool BajoMinimo => StockActual <= StockMinimo;
}

public class CrearMateriaPrimaDto
{
    public string Categoria { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public string UnidadMedida { get; set; } = string.Empty;
    public decimal StockMinimo { get; set; }
    public decimal PuntoCritico { get; set; }
}

public class MovimientoDto
{
    public int Id { get; set; }
    public int MateriaPrimaId { get; set; }
    public string MateriaPrimaNombre { get; set; } = string.Empty;
    public string Tipo { get; set; } = string.Empty;
    public string TipoDescripcion => Tipo switch
    {
        "E" => "Entrada",
        "S" => "Salida",
        "M" => "Merma",
        _ => "Desconocido"
    };
    public decimal Cantidad { get; set; }
    public decimal? CostoUnitario { get; set; }
    public string? Motivo { get; set; }
    public DateTime Fecha { get; set; }
}

public class CrearMovimientoDto
{
    public int MateriaPrimaId { get; set; }
    public string Tipo { get; set; } = string.Empty; // E, S, M
    public decimal Cantidad { get; set; }
    public decimal? CostoUnitario { get; set; }
    public string? Motivo { get; set; }
}

// ==========================================
// VENTA DTOs
// ==========================================

public class VentaDto
{
    public int Id { get; set; }
    public string? Codigo { get; set; }
    public int SucursalId { get; set; }
    public string SucursalNombre { get; set; } = string.Empty;
    public DateTime Fecha { get; set; }
    public decimal Subtotal { get; set; }
    public decimal Descuento { get; set; }
    public decimal Total { get; set; }
    public string Estado { get; set; } = string.Empty;
    public List<VentaItemDto> Items { get; set; } = new();
}

public class VentaItemDto
{
    public int Id { get; set; }
    public string TipoItem { get; set; } = string.Empty; // PRODUCTO o COMBO
    public int? PresentacionId { get; set; }
    public int? ComboId { get; set; }
    public string Descripcion { get; set; } = string.Empty;
    public int Cantidad { get; set; }
    public decimal PrecioUnitario { get; set; }
    public decimal PrecioExtras { get; set; }
    public decimal Subtotal { get; set; }
    public Dictionary<string, PersonalizacionItemDto>? Personalizacion { get; set; }
}

public class PersonalizacionItemDto
{
    public int OpcionId { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public decimal PrecioExtra { get; set; }
}

public class CrearVentaDto
{
    public int SucursalId { get; set; }
    public decimal Descuento { get; set; } = 0;
    public List<CrearVentaItemDto> Items { get; set; } = new();
}

public class CrearVentaItemDto
{
    public int? PresentacionId { get; set; }
    public int? ComboId { get; set; }
    public int Cantidad { get; set; }
    public Dictionary<string, int>? Personalizacion { get; set; } // codigo_atributo -> opcion_id
}

// ==========================================
// SUCURSAL DTOs
// ==========================================

public class SucursalDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Direccion { get; set; }
    public string? Telefono { get; set; }
    public bool Activo { get; set; }
}

public class CrearSucursalDto
{
    public string Nombre { get; set; } = string.Empty;
    public string? Direccion { get; set; }
    public string? Telefono { get; set; }
}

// ==========================================
// DASHBOARD DTOs
// ==========================================

public class DashboardDto
{
    public decimal VentasHoy { get; set; }
    public decimal VentasMes { get; set; }
    public int TotalVentasHoy { get; set; }
    public int TotalVentasMes { get; set; }
    public List<ProductoVendidoDto> ProductosMasVendidos { get; set; } = new();
    public List<BebidaPorHorarioDto> BebidasPorHorario { get; set; } = new();
    public ProporcionPicanteDto ProporcionPicante { get; set; } = new();
    public List<UtilidadLineaDto> UtilidadesPorLinea { get; set; } = new();
    public List<InventarioAlertaDto> AlertasInventario { get; set; } = new();
    public decimal DesperdicioMes { get; set; }
}

public class ProductoVendidoDto
{
    public string Producto { get; set; } = string.Empty;
    public string Presentacion { get; set; } = string.Empty;
    public int CantidadVendida { get; set; }
    public decimal TotalVendido { get; set; }
}

public class BebidaPorHorarioDto
{
    public string Horario { get; set; } = string.Empty; // "Mañana", "Tarde", "Noche"
    public string Bebida { get; set; } = string.Empty;
    public int Cantidad { get; set; }
}

public class ProporcionPicanteDto
{
    public int ConPicante { get; set; }
    public int SinPicante { get; set; }
    public decimal PorcentajeConPicante => ConPicante + SinPicante > 0 
        ? Math.Round((decimal)ConPicante / (ConPicante + SinPicante) * 100, 2) 
        : 0;
}

public class UtilidadLineaDto
{
    public string Linea { get; set; } = string.Empty; // "Tamales", "Bebidas", "Combos"
    public decimal Ventas { get; set; }
    public decimal Costo { get; set; }
    public decimal Utilidad => Ventas - Costo;
    public decimal MargenPorcentaje => Ventas > 0 ? Math.Round((Utilidad / Ventas) * 100, 2) : 0;
}

public class InventarioAlertaDto
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Categoria { get; set; } = string.Empty;
    public decimal StockActual { get; set; }
    public decimal PuntoCritico { get; set; }
    public string Nivel { get; set; } = string.Empty; // "CRITICO", "BAJO"
}

// ==========================================
// LLM DTOs
// ==========================================

public class LLMRequestDto
{
    public string Mensaje { get; set; } = string.Empty;
    public string? Contexto { get; set; }
}

public class LLMResponseDto
{
    public string Respuesta { get; set; } = string.Empty;
    public bool Exito { get; set; }
    public string? Error { get; set; }
}
