using Microsoft.EntityFrameworkCore;
using backend_api.Data;
using backend_api.DTOs;
using System.Text.Json;

namespace backend_api.Services;

public interface IDashboardService
{
    Task<DashboardDto> GetDashboardAsync(int? sucursalId = null);
}

public class DashboardService : IDashboardService
{
    private readonly AppDbContext _context;

    public DashboardService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<DashboardDto> GetDashboardAsync(int? sucursalId = null)
    {
        var hoy = DateTime.Today;
        var inicioMes = new DateTime(hoy.Year, hoy.Month, 1);
        var finHoy = hoy.AddDays(1);

        var ventasQuery = _context.Ventas
            .Where(v => v.Estado == "COMPLETADA");

        if (sucursalId.HasValue)
            ventasQuery = ventasQuery.Where(v => v.SucursalId == sucursalId.Value);

        // Ventas de hoy
        var ventasHoy = await ventasQuery
            .Where(v => v.Fecha >= hoy && v.Fecha < finHoy)
            .ToListAsync();

        // Ventas del mes
        var ventasMes = await ventasQuery
            .Where(v => v.Fecha >= inicioMes && v.Fecha < finHoy)
            .ToListAsync();

        // Productos más vendidos (este mes)
        var productosMasVendidos = await GetProductosMasVendidos(sucursalId, inicioMes);

        // Bebidas por horario
        var bebidasPorHorario = await GetBebidasPorHorario(sucursalId, inicioMes);

        // Proporción picante vs no picante
        var proporcionPicante = await GetProporcionPicante(sucursalId, inicioMes);

        // Utilidades por línea
        var utilidadesPorLinea = await GetUtilidadesPorLinea(sucursalId, inicioMes);

        // Alertas de inventario
        var alertas = await _context.MateriasPrimas
            .Where(m => m.Activo && m.StockActual <= m.StockMinimo)
            .OrderBy(m => m.StockActual)
            .Select(m => new InventarioAlertaDto
            {
                Id = m.Id,
                Nombre = m.Nombre,
                Categoria = m.Categoria,
                StockActual = m.StockActual,
                PuntoCritico = m.PuntoCritico,
                Nivel = m.StockActual <= m.PuntoCritico ? "CRITICO" : "BAJO"
            }).ToListAsync();

        // Desperdicio del mes (mermas)
        var desperdicioMes = await _context.InventarioMovimientos
            .Where(m => m.Tipo == "M" && m.Fecha >= inicioMes)
            .SumAsync(m => (m.CostoUnitario ?? 0) * m.Cantidad);

        return new DashboardDto
        {
            VentasHoy = ventasHoy.Sum(v => v.Total),
            VentasMes = ventasMes.Sum(v => v.Total),
            TotalVentasHoy = ventasHoy.Count,
            TotalVentasMes = ventasMes.Count,
            ProductosMasVendidos = productosMasVendidos,
            BebidasPorHorario = bebidasPorHorario,
            ProporcionPicante = proporcionPicante,
            UtilidadesPorLinea = utilidadesPorLinea,
            AlertasInventario = alertas,
            DesperdicioMes = desperdicioMes
        };
    }

    private async Task<List<ProductoVendidoDto>> GetProductosMasVendidos(int? sucursalId, DateTime desde)
    {
        var query = _context.VentaItems
            .Include(vi => vi.Venta)
            .Include(vi => vi.Presentacion)
                .ThenInclude(p => p!.Producto)
            .Where(vi => vi.Venta.Estado == "COMPLETADA")
            .Where(vi => vi.Venta.Fecha >= desde)
            .Where(vi => vi.PresentacionId != null);

        if (sucursalId.HasValue)
            query = query.Where(vi => vi.Venta.SucursalId == sucursalId.Value);

        var items = await query.ToListAsync();

        return items
    .GroupBy(vi => new {
        ProductoNombre = vi.Presentacion!.Producto.Nombre,
        PresentacionNombre = vi.Presentacion.Nombre
    })
    .Select(g => new ProductoVendidoDto
    {
        Producto = g.Key.ProductoNombre,
        Presentacion = g.Key.PresentacionNombre,
        CantidadVendida = g.Sum(x => x.Cantidad),
        TotalVendido = g.Sum(x => x.Subtotal)
    })
    .OrderByDescending(p => p.CantidadVendida)
    .Take(10)
    .ToList();
    }

    private async Task<List<BebidaPorHorarioDto>> GetBebidasPorHorario(int? sucursalId, DateTime desde)
    {
        // Obtener categoría de bebidas
        var categoriaBebidas = await _context.Categorias
            .FirstOrDefaultAsync(c => c.Nombre.ToLower().Contains("bebida"));

        if (categoriaBebidas == null)
            return new List<BebidaPorHorarioDto>();

        var query = _context.VentaItems
            .Include(vi => vi.Venta)
            .Include(vi => vi.Presentacion)
                .ThenInclude(p => p!.Producto)
            .Where(vi => vi.Venta.Estado == "COMPLETADA")
            .Where(vi => vi.Venta.Fecha >= desde)
            .Where(vi => vi.PresentacionId != null)
            .Where(vi => vi.Presentacion!.Producto.CategoriaId == categoriaBebidas.Id);

        if (sucursalId.HasValue)
            query = query.Where(vi => vi.Venta.SucursalId == sucursalId.Value);

        var items = await query.ToListAsync();

        var resultado = new List<BebidaPorHorarioDto>();
        var horarios = new[] {
            ("Mañana", 6, 12),
            ("Tarde", 12, 18),
            ("Noche", 18, 24)
        };

        foreach (var (nombre, horaInicio, horaFin) in horarios)
        {
            var itemsHorario = items
                .Where(vi => vi.Venta.Fecha.Hour >= horaInicio && vi.Venta.Fecha.Hour < horaFin)
                .GroupBy(vi => vi.Presentacion!.Producto.Nombre)
                .OrderByDescending(g => g.Sum(x => x.Cantidad))
                .FirstOrDefault();

            if (itemsHorario != null)
            {
                resultado.Add(new BebidaPorHorarioDto
                {
                    Horario = nombre,
                    Bebida = itemsHorario.Key,
                    Cantidad = itemsHorario.Sum(x => x.Cantidad)
                });
            }
        }

        return resultado;
    }

    private async Task<ProporcionPicanteDto> GetProporcionPicante(int? sucursalId, DateTime desde)
    {
        var query = _context.VentaItems
            .Include(vi => vi.Venta)
            .Where(vi => vi.Venta.Estado == "COMPLETADA")
            .Where(vi => vi.Venta.Fecha >= desde)
            .Where(vi => vi.PresentacionId != null)
            .Where(vi => vi.Personalizacion != null);

        if (sucursalId.HasValue)
            query = query.Where(vi => vi.Venta.SucursalId == sucursalId.Value);

        var items = await query.ToListAsync();

        int conPicante = 0;
        int sinPicante = 0;

        foreach (var item in items)
        {
            if (string.IsNullOrEmpty(item.Personalizacion)) continue;

            try
            {
                var personalizacion = JsonSerializer.Deserialize<Dictionary<string, PersonalizacionItemDto>>(item.Personalizacion);
                if (personalizacion != null && personalizacion.TryGetValue("picante", out var opcionPicante))
                {
                    if (opcionPicante.Nombre.ToLower().Contains("sin"))
                        sinPicante += item.Cantidad;
                    else
                        conPicante += item.Cantidad;
                }
            }
            catch
            {
                // Ignorar errores de deserialización
            }
        }

        return new ProporcionPicanteDto
        {
            ConPicante = conPicante,
            SinPicante = sinPicante
        };
    }

    private async Task<List<UtilidadLineaDto>> GetUtilidadesPorLinea(int? sucursalId, DateTime desde)
    {
        var query = _context.VentaItems
            .Include(vi => vi.Venta)
            .Include(vi => vi.Presentacion)
                .ThenInclude(p => p!.Producto)
                    .ThenInclude(p => p.Categoria)
            .Include(vi => vi.Combo)
            .Where(vi => vi.Venta.Estado == "COMPLETADA")
            .Where(vi => vi.Venta.Fecha >= desde);

        if (sucursalId.HasValue)
            query = query.Where(vi => vi.Venta.SucursalId == sucursalId.Value);

        var items = await query.ToListAsync();

        var resultado = new List<UtilidadLineaDto>();

        // Agrupar productos por categoría
        var porCategoria = items
            .Where(i => i.PresentacionId.HasValue)
            .GroupBy(i => i.Presentacion!.Producto.Categoria.Nombre);

        foreach (var grupo in porCategoria)
        {
            resultado.Add(new UtilidadLineaDto
            {
                Linea = grupo.Key,
                Ventas = grupo.Sum(i => i.Subtotal),
                Costo = grupo.Sum(i => i.Subtotal * 0.4m) // Estimación: 40% costo
            });
        }

        // Agregar combos
        var ventasCombos = items
            .Where(i => i.ComboId.HasValue)
            .Sum(i => i.Subtotal);

        if (ventasCombos > 0)
        {
            resultado.Add(new UtilidadLineaDto
            {
                Linea = "Combos",
                Ventas = ventasCombos,
                Costo = ventasCombos * 0.45m // Estimación: 45% costo
            });
        }

        return resultado.OrderByDescending(u => u.Ventas).ToList();
    }
}
