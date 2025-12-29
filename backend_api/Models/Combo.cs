namespace backend_api.Models;

public class Combo
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public decimal Precio { get; set; }
    public string Tipo { get; set; } = "FIJO"; // FIJO, ESTACIONAL
    public DateTime? FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public bool Activo { get; set; } = true;

    // Navegación
    public List<ComboItem> Items { get; set; } = new();
}
