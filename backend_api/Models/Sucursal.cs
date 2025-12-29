namespace backend_api.Models;

public class Sucursal
{
    public int Id { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Direccion { get; set; }
    public string? Telefono { get; set; }
    public bool Activo { get; set; } = true;

    // Navegación
    public List<Venta> Ventas { get; set; } = new();
}
