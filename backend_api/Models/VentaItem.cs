namespace backend_api.Models;

public class VentaItem
{
    public int Id { get; set; }
    public int VentaId { get; set; }
    public int? PresentacionId { get; set; }
    public int? ComboId { get; set; }
    public int Cantidad { get; set; }
    public decimal PrecioUnitario { get; set; }
    public decimal PrecioExtras { get; set; } = 0;
    public decimal Subtotal { get; set; }
    public string? Personalizacion { get; set; } // JSON con las opciones elegidas

    // Navegación
    public Venta Venta { get; set; } = null!;
    public Presentacion? Presentacion { get; set; }
    public Combo? Combo { get; set; }
}
