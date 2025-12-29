namespace backend_api.Models;

public class Presentacion
{
    public int Id { get; set; }
    public int ProductoId { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public int Cantidad { get; set; } = 1;
    public decimal Precio { get; set; }
    public int Orden { get; set; } = 0;
    public bool Activo { get; set; } = true;

    // Navegación
    public Producto Producto { get; set; } = null!;
}
