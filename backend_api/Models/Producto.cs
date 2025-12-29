namespace backend_api.Models;

public class Producto
{
    public int Id { get; set; }
    public int CategoriaId { get; set; }
    public string? Codigo { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public string? ImagenUrl { get; set; }
    public bool Activo { get; set; } = true;

    // Navegación
    public Categoria Categoria { get; set; } = null!;
    public List<Presentacion> Presentaciones { get; set; } = new();
}
