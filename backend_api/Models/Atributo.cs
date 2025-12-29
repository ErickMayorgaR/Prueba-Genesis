namespace backend_api.Models;

public class Atributo
{
    public int Id { get; set; }
    public int CategoriaId { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string Codigo { get; set; } = string.Empty;
    public bool EsMultiple { get; set; } = false;
    public bool EsRequerido { get; set; } = true;
    public int Orden { get; set; } = 0;
    public bool Activo { get; set; } = true;

    // Navegación
    public Categoria Categoria { get; set; } = null!;
    public List<AtributoOpcion> Opciones { get; set; } = new();
}
