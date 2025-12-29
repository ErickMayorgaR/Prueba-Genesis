using Microsoft.EntityFrameworkCore;
using backend_api.Data;
using backend_api.DTOs;
using backend_api.Models;

namespace backend_api.Services;

public interface IInventarioService
{
    Task<List<MateriaPrimaDto>> GetMateriasAsync();
    Task<MateriaPrimaDto?> GetMateriaByIdAsync(int id);
    Task<MateriaPrimaDto> CreateMateriaAsync(CrearMateriaPrimaDto dto);
    Task<MateriaPrimaDto?> UpdateMateriaAsync(int id, CrearMateriaPrimaDto dto);
    Task<List<MovimientoDto>> GetMovimientosAsync(int? materiaPrimaId = null, DateTime? desde = null, DateTime? hasta = null);
    Task<MovimientoDto> RegistrarMovimientoAsync(CrearMovimientoDto dto);
    Task<List<InventarioAlertaDto>> GetAlertasAsync();
    Task<bool> ValidarStockParaVenta(int presentacionId, int cantidad);
}

public class InventarioService : IInventarioService
{
    private readonly AppDbContext _context;

    public InventarioService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<MateriaPrimaDto>> GetMateriasAsync()
    {
        return await _context.MateriasPrimas
            .Where(m => m.Activo)
            .OrderBy(m => m.Categoria)
            .ThenBy(m => m.Nombre)
            .Select(m => new MateriaPrimaDto
            {
                Id = m.Id,
                Categoria = m.Categoria,
                Nombre = m.Nombre,
                UnidadMedida = m.UnidadMedida,
                StockActual = m.StockActual,
                StockMinimo = m.StockMinimo,
                PuntoCritico = m.PuntoCritico,
                CostoPromedio = m.CostoPromedio
            }).ToListAsync();
    }

    public async Task<MateriaPrimaDto?> GetMateriaByIdAsync(int id)
    {
        return await _context.MateriasPrimas
            .Where(m => m.Id == id && m.Activo)
            .Select(m => new MateriaPrimaDto
            {
                Id = m.Id,
                Categoria = m.Categoria,
                Nombre = m.Nombre,
                UnidadMedida = m.UnidadMedida,
                StockActual = m.StockActual,
                StockMinimo = m.StockMinimo,
                PuntoCritico = m.PuntoCritico,
                CostoPromedio = m.CostoPromedio
            }).FirstOrDefaultAsync();
    }

    public async Task<MateriaPrimaDto> CreateMateriaAsync(CrearMateriaPrimaDto dto)
    {
        var materia = new MateriaPrima
        {
            Categoria = dto.Categoria,
            Nombre = dto.Nombre,
            UnidadMedida = dto.UnidadMedida,
            StockMinimo = dto.StockMinimo,
            PuntoCritico = dto.PuntoCritico,
            Activo = true
        };

        _context.MateriasPrimas.Add(materia);
        await _context.SaveChangesAsync();

        return (await GetMateriaByIdAsync(materia.Id))!;
    }

    public async Task<MateriaPrimaDto?> UpdateMateriaAsync(int id, CrearMateriaPrimaDto dto)
    {
        var materia = await _context.MateriasPrimas.FindAsync(id);
        if (materia == null || !materia.Activo) return null;

        materia.Categoria = dto.Categoria;
        materia.Nombre = dto.Nombre;
        materia.UnidadMedida = dto.UnidadMedida;
        materia.StockMinimo = dto.StockMinimo;
        materia.PuntoCritico = dto.PuntoCritico;

        await _context.SaveChangesAsync();

        return await GetMateriaByIdAsync(id);
    }

    public async Task<List<MovimientoDto>> GetMovimientosAsync(int? materiaPrimaId = null, DateTime? desde = null, DateTime? hasta = null)
    {
        var query = _context.InventarioMovimientos
            .Include(m => m.MateriaPrima)
            .AsQueryable();

        if (materiaPrimaId.HasValue)
            query = query.Where(m => m.MateriaPrimaId == materiaPrimaId.Value);

        if (desde.HasValue)
            query = query.Where(m => m.Fecha >= desde.Value);

        if (hasta.HasValue)
            query = query.Where(m => m.Fecha <= hasta.Value);

        return await query
            .OrderByDescending(m => m.Fecha)
            .Select(m => new MovimientoDto
            {
                Id = m.Id,
                MateriaPrimaId = m.MateriaPrimaId,
                MateriaPrimaNombre = m.MateriaPrima.Nombre,
                Tipo = m.Tipo,
                Cantidad = m.Cantidad,
                CostoUnitario = m.CostoUnitario,
                Motivo = m.Motivo,
                Fecha = m.Fecha
            }).ToListAsync();
    }

    public async Task<MovimientoDto> RegistrarMovimientoAsync(CrearMovimientoDto dto)
    {
        var materia = await _context.MateriasPrimas.FindAsync(dto.MateriaPrimaId);
        if (materia == null)
            throw new Exception("Materia prima no encontrada");

        // Crear el movimiento
        var movimiento = new InventarioMovimiento
        {
            MateriaPrimaId = dto.MateriaPrimaId,
            Tipo = dto.Tipo.ToUpper(),
            Cantidad = dto.Cantidad,
            CostoUnitario = dto.CostoUnitario,
            Motivo = dto.Motivo,
            Fecha = DateTime.UtcNow
        };

        // Actualizar stock según tipo
        switch (dto.Tipo.ToUpper())
        {
            case "E": // Entrada
                // Calcular nuevo costo promedio
                if (dto.CostoUnitario.HasValue && dto.CostoUnitario > 0)
                {
                    var costoTotal = (materia.StockActual * materia.CostoPromedio) + (dto.Cantidad * dto.CostoUnitario.Value);
                    var cantidadTotal = materia.StockActual + dto.Cantidad;
                    materia.CostoPromedio = cantidadTotal > 0 ? costoTotal / cantidadTotal : 0;
                }
                materia.StockActual += dto.Cantidad;
                break;

            case "S": // Salida
            case "M": // Merma
                if (materia.StockActual < dto.Cantidad)
                    throw new Exception("Stock insuficiente");
                materia.StockActual -= dto.Cantidad;
                break;

            default:
                throw new Exception("Tipo de movimiento inválido. Use E (Entrada), S (Salida) o M (Merma)");
        }

        _context.InventarioMovimientos.Add(movimiento);
        await _context.SaveChangesAsync();

        return new MovimientoDto
        {
            Id = movimiento.Id,
            MateriaPrimaId = movimiento.MateriaPrimaId,
            MateriaPrimaNombre = materia.Nombre,
            Tipo = movimiento.Tipo,
            Cantidad = movimiento.Cantidad,
            CostoUnitario = movimiento.CostoUnitario,
            Motivo = movimiento.Motivo,
            Fecha = movimiento.Fecha
        };
    }

    public async Task<List<InventarioAlertaDto>> GetAlertasAsync()
    {
        return await _context.MateriasPrimas
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
    }

    public async Task<bool> ValidarStockParaVenta(int presentacionId, int cantidad)
    {
        // Por ahora retornamos true, aquí iría la lógica de validación
        // de materias primas según recetas/fórmulas
        await Task.CompletedTask;
        return true;
    }
}
