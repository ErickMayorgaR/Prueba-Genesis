namespace backend_api.Models;

public class Venta
{
    public int Id { get; set; }
    public int SucursalId { get; set; }
    public string? Codigo { get; set; }
    public DateTime Fecha { get; set; } = DateTime.UtcNow;
    public decimal Subtotal { get; set; }
    public decimal Descuento { get; set; } = 0;
    public decimal Total { get; set; }
    public string Estado { get; set; } = "COMPLETADA";
    public bool Sincronizado { get; set; } = true;

    // Navegación
    public Sucursal Sucursal { get; set; } = null!;
    public List<VentaItem> Items { get; set; } = new();
}
