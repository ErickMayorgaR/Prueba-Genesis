namespace backend_api.Models;

public class MateriaPrima
{
    public int Id { get; set; }
    public string Categoria { get; set; } = string.Empty; // Masa, Hojas, Proteínas, etc.
    public string Nombre { get; set; } = string.Empty;
    public string UnidadMedida { get; set; } = string.Empty;
    public decimal StockActual { get; set; } = 0;
    public decimal StockMinimo { get; set; } = 0;
    public decimal PuntoCritico { get; set; } = 0;
    public decimal CostoPromedio { get; set; } = 0;
    public bool Activo { get; set; } = true;

    // Navegación
    public List<InventarioMovimiento> Movimientos { get; set; } = new();
}
