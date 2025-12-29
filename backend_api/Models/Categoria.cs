namespace backend_api.Models;

public class Categoria
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public string? Icono { get; set; }
    public bool Activo { get; set; } = true;

    // Navegación
    public List<Producto> Productos { get; set; } = new();
    public List<Atributo> Atributos { get; set; } = new();
}
