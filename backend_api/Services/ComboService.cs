using Microsoft.EntityFrameworkCore;
using backend_api.Data;
using backend_api.DTOs;
using backend_api.Models;

namespace backend_api.Services;

public interface IComboService
{
    Task<List<ComboDto>> GetAllAsync();
    Task<ComboDto?> GetByIdAsync(int id);
    Task<ComboDto> CreateAsync(CrearComboDto dto);
    Task<ComboDto?> UpdateAsync(int id, CrearComboDto dto);
    Task<bool> DeleteAsync(int id);
}

public class ComboService : IComboService
{
    private readonly AppDbContext _context;

    public ComboService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<ComboDto>> GetAllAsync()
    {
        return await _context.Combos
            .Where(c => c.Activo)
            .Include(c => c.Items)
                .ThenInclude(i => i.Presentacion)
                    .ThenInclude(p => p.Producto)
            .Select(c => new ComboDto
            {
                Id = c.Id,
                Nombre = c.Nombre,
                Descripcion = c.Descripcion,
                Precio = c.Precio,
                Tipo = c.Tipo,
                FechaInicio = c.FechaInicio,
                FechaFin = c.FechaFin,
                Items = c.Items.Select(i => new ComboItemDto
                {
                    Id = i.Id,
                    PresentacionId = i.PresentacionId,
                    PresentacionNombre = i.Presentacion.Nombre,
                    ProductoNombre = i.Presentacion.Producto.Nombre,
                    Cantidad = i.Cantidad,
                    Notas = i.Notas
                }).ToList()
            }).ToListAsync();
    }

    public async Task<ComboDto?> GetByIdAsync(int id)
    {
        return await _context.Combos
            .Where(c => c.Id == id && c.Activo)
            .Include(c => c.Items)
                .ThenInclude(i => i.Presentacion)
                    .ThenInclude(p => p.Producto)
            .Select(c => new ComboDto
            {
                Id = c.Id,
                Nombre = c.Nombre,
                Descripcion = c.Descripcion,
                Precio = c.Precio,
                Tipo = c.Tipo,
                FechaInicio = c.FechaInicio,
                FechaFin = c.FechaFin,
                Items = c.Items.Select(i => new ComboItemDto
                {
                    Id = i.Id,
                    PresentacionId = i.PresentacionId,
                    PresentacionNombre = i.Presentacion.Nombre,
                    ProductoNombre = i.Presentacion.Producto.Nombre,
                    Cantidad = i.Cantidad,
                    Notas = i.Notas
                }).ToList()
            }).FirstOrDefaultAsync();
    }

    public async Task<ComboDto> CreateAsync(CrearComboDto dto)
    {
        var combo = new Combo
        {
            Nombre = dto.Nombre,
            Descripcion = dto.Descripcion,
            Precio = dto.Precio,
            Tipo = dto.Tipo,
            FechaInicio = dto.FechaInicio,
            FechaFin = dto.FechaFin,
            Activo = true,
            Items = dto.Items.Select(i => new ComboItem
            {
                PresentacionId = i.PresentacionId,
                Cantidad = i.Cantidad,
                Notas = i.Notas
            }).ToList()
        };

        _context.Combos.Add(combo);
        await _context.SaveChangesAsync();

        return (await GetByIdAsync(combo.Id))!;
    }

    public async Task<ComboDto?> UpdateAsync(int id, CrearComboDto dto)
    {
        var combo = await _context.Combos
            .Include(c => c.Items)
            .FirstOrDefaultAsync(c => c.Id == id && c.Activo);

        if (combo == null) return null;

        combo.Nombre = dto.Nombre;
        combo.Descripcion = dto.Descripcion;
        combo.Precio = dto.Precio;
        combo.Tipo = dto.Tipo;
        combo.FechaInicio = dto.FechaInicio;
        combo.FechaFin = dto.FechaFin;

        // Eliminar items anteriores y agregar nuevos
        _context.ComboItems.RemoveRange(combo.Items);
        combo.Items = dto.Items.Select(i => new ComboItem
        {
            ComboId = combo.Id,
            PresentacionId = i.PresentacionId,
            Cantidad = i.Cantidad,
            Notas = i.Notas
        }).ToList();

        await _context.SaveChangesAsync();

        return await GetByIdAsync(id);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var combo = await _context.Combos.FindAsync(id);
        if (combo == null) return false;

        combo.Activo = false;
        await _context.SaveChangesAsync();
        return true;
    }
}
