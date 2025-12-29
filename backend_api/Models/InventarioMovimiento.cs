namespace backend_api.Models;

public class InventarioMovimiento
{
    public int Id { get; set; }
    public int MateriaPrimaId { get; set; }
    public string Tipo { get; set; } = string.Empty; // E: Entrada, S: Salida, M: Merma
    public decimal Cantidad { get; set; }
    public decimal? CostoUnitario { get; set; }
    public string? Motivo { get; set; }
    public DateTime Fecha { get; set; } = DateTime.UtcNow;
    public int? UsuarioId { get; set; }

    // Navegación
    public MateriaPrima MateriaPrima { get; set; } = null!;
}
