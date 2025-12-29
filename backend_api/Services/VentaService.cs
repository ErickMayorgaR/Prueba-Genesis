using Microsoft.EntityFrameworkCore;
using backend_api.Data;
using backend_api.DTOs;
using backend_api.Models;
using System.Text.Json;

namespace backend_api.Services;

public interface IVentaService
{
    Task<List<VentaDto>> GetVentasAsync(int? sucursalId = null, DateTime? desde = null, DateTime? hasta = null);
    Task<VentaDto?> GetByIdAsync(int id);
    Task<VentaDto> CreateAsync(CrearVentaDto dto);
    Task<bool> AnularAsync(int id);
}

public class VentaService : IVentaService
{
    private readonly AppDbContext _context;

    public VentaService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<VentaDto>> GetVentasAsync(int? sucursalId = null, DateTime? desde = null, DateTime? hasta = null)
    {
        var query = _context.Ventas
            .Include(v => v.Sucursal)
            .Include(v => v.Items)
                .ThenInclude(i => i.Presentacion)
                    .ThenInclude(p => p!.Producto)
            .Include(v => v.Items)
                .ThenInclude(i => i.Combo)
            .AsQueryable();

        if (sucursalId.HasValue)
            query = query.Where(v => v.SucursalId == sucursalId.Value);

        if (desde.HasValue)
            query = query.Where(v => v.Fecha >= desde.Value);

        if (hasta.HasValue)
            query = query.Where(v => v.Fecha <= hasta.Value);

        return await query
            .OrderByDescending(v => v.Fecha)
            .Select(v => MapToDto(v))
            .ToListAsync();
    }

    public async Task<VentaDto?> GetByIdAsync(int id)
    {
        var venta = await _context.Ventas
            .Include(v => v.Sucursal)
            .Include(v => v.Items)
                .ThenInclude(i => i.Presentacion)
                    .ThenInclude(p => p!.Producto)
            .Include(v => v.Items)
                .ThenInclude(i => i.Combo)
            .FirstOrDefaultAsync(v => v.Id == id);

        return venta != null ? MapToDto(venta) : null;
    }

    public async Task<VentaDto> CreateAsync(CrearVentaDto dto)
    {
        // Validar que exista la sucursal
        var sucursal = await _context.Sucursales.FindAsync(dto.SucursalId);
        if (sucursal == null)
            throw new Exception("Sucursal no encontrada");

        // Generar código de venta
        var hoy = DateTime.Today;
        var ventasHoy = await _context.Ventas.CountAsync(v => v.Fecha.Date == hoy);
        var codigo = $"V-{hoy:yyyyMMdd}-{(ventasHoy + 1):D4}";

        var venta = new Venta
        {
            SucursalId = dto.SucursalId,
            Codigo = codigo,
            Fecha = DateTime.UtcNow,
            Descuento = dto.Descuento,
            Estado = "COMPLETADA",
            Sincronizado = true,
            Items = new List<VentaItem>()
        };

        decimal subtotal = 0;

        foreach (var itemDto in dto.Items)
        {
            var ventaItem = new VentaItem
            {
                Cantidad = itemDto.Cantidad,
                PrecioExtras = 0
            };

            if (itemDto.PresentacionId.HasValue)
            {
                // Es un producto
                var presentacion = await _context.Presentaciones
                    .Include(p => p.Producto)
                        .ThenInclude(p => p.Categoria)
                            .ThenInclude(c => c.Atributos)
                                .ThenInclude(a => a.Opciones)
                    .FirstOrDefaultAsync(p => p.Id == itemDto.PresentacionId.Value);

                if (presentacion == null)
                    throw new Exception($"Presentación {itemDto.PresentacionId} no encontrada");

                ventaItem.PresentacionId = presentacion.Id;
                ventaItem.PrecioUnitario = presentacion.Precio;

                // Procesar personalizaciones
                if (itemDto.Personalizacion != null && itemDto.Personalizacion.Any())
                {
                    var personalizacionDict = new Dictionary<string, PersonalizacionItemDto>();

                    foreach (var (codigoAtributo, opcionId) in itemDto.Personalizacion)
                    {
                        var opcion = await _context.AtributoOpciones
                            .Include(o => o.Atributo)
                            .FirstOrDefaultAsync(o => o.Id == opcionId);

                        if (opcion != null)
                        {
                            personalizacionDict[codigoAtributo] = new PersonalizacionItemDto
                            {
                                OpcionId = opcion.Id,
                                Nombre = opcion.Nombre,
                                PrecioExtra = opcion.PrecioExtra
                            };
                            ventaItem.PrecioExtras += opcion.PrecioExtra;
                        }
                    }

                    ventaItem.Personalizacion = JsonSerializer.Serialize(personalizacionDict);
                }
            }
            else if (itemDto.ComboId.HasValue)
            {
                // Es un combo
                var combo = await _context.Combos.FindAsync(itemDto.ComboId.Value);
                if (combo == null)
                    throw new Exception($"Combo {itemDto.ComboId} no encontrado");

                ventaItem.ComboId = combo.Id;
                ventaItem.PrecioUnitario = combo.Precio;
            }
            else
            {
                throw new Exception("Cada item debe tener PresentacionId o ComboId");
            }

            ventaItem.Subtotal = (ventaItem.PrecioUnitario + ventaItem.PrecioExtras) * ventaItem.Cantidad;
            subtotal += ventaItem.Subtotal;

            venta.Items.Add(ventaItem);
        }

        venta.Subtotal = subtotal;
        venta.Total = subtotal - dto.Descuento;

        _context.Ventas.Add(venta);
        await _context.SaveChangesAsync();

        return (await GetByIdAsync(venta.Id))!;
    }

    public async Task<bool> AnularAsync(int id)
    {
        var venta = await _context.Ventas.FindAsync(id);
        if (venta == null) return false;

        venta.Estado = "ANULADA";
        await _context.SaveChangesAsync();
        return true;
    }

    private static VentaDto MapToDto(Venta v)
    {
        return new VentaDto
        {
            Id = v.Id,
            Codigo = v.Codigo,
            SucursalId = v.SucursalId,
            SucursalNombre = v.Sucursal.Nombre,
            Fecha = v.Fecha,
            Subtotal = v.Subtotal,
            Descuento = v.Descuento,
            Total = v.Total,
            Estado = v.Estado,
            Items = v.Items.Select(i => new VentaItemDto
            {
                Id = i.Id,
                TipoItem = i.PresentacionId.HasValue ? "PRODUCTO" : "COMBO",
                PresentacionId = i.PresentacionId,
                ComboId = i.ComboId,
                Descripcion = i.PresentacionId.HasValue
                    ? $"{i.Presentacion!.Producto.Nombre} - {i.Presentacion.Nombre}"
                    : i.Combo!.Nombre,
                Cantidad = i.Cantidad,
                PrecioUnitario = i.PrecioUnitario,
                PrecioExtras = i.PrecioExtras,
                Subtotal = i.Subtotal,
                Personalizacion = string.IsNullOrEmpty(i.Personalizacion)
                    ? null
                    : JsonSerializer.Deserialize<Dictionary<string, PersonalizacionItemDto>>(i.Personalizacion)
            }).ToList()
        };
    }
}
