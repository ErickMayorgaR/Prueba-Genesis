namespace backend_api.Models;

public class ComboItem
{
    public int Id { get; set; }
    public int ComboId { get; set; }
    public int PresentacionId { get; set; }
    public int Cantidad { get; set; }
    public string? Notas { get; set; }

    // Navegación
    public Combo Combo { get; set; } = null!;
    public Presentacion Presentacion { get; set; } = null!;
}
