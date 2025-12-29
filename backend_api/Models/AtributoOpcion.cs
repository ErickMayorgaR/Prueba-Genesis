namespace backend_api.Models;

public class AtributoOpcion
{
    public int Id { get; set; }
    public int AtributoId { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Codigo { get; set; } = string.Empty;
    public decimal PrecioExtra { get; set; } = 0;
    public int Orden { get; set; } = 0;
    public bool Activo { get; set; } = true;

    // Navegación
    public Atributo Atributo { get; set; } = null!;
}
