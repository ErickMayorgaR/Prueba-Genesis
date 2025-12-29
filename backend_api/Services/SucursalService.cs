using Microsoft.EntityFrameworkCore;
using backend_api.Data;
using backend_api.DTOs;
using backend_api.Models;

namespace backend_api.Services;

public interface ISucursalService
{
    Task<List<SucursalDto>> GetAllAsync();
    Task<SucursalDto?> GetByIdAsync(int id);
    Task<SucursalDto> CreateAsync(CrearSucursalDto dto);
    Task<SucursalDto?> UpdateAsync(int id, CrearSucursalDto dto);
    Task<bool> DeleteAsync(int id);
}

public class SucursalService : ISucursalService
{
    private readonly AppDbContext _context;

    public SucursalService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<List<SucursalDto>> GetAllAsync()
    {
        return await _context.Sucursales
            .Where(s => s.Activo)
            .OrderBy(s => s.Nombre)
            .Select(s => new SucursalDto
            {
                Id = s.Id,
                Nombre = s.Nombre,
                Direccion = s.Direccion,
                Telefono = s.Telefono,
                Activo = s.Activo
            }).ToListAsync();
    }

    public async Task<SucursalDto?> GetByIdAsync(int id)
    {
        return await _context.Sucursales
            .Where(s => s.Id == id && s.Activo)
            .Select(s => new SucursalDto
            {
                Id = s.Id,
                Nombre = s.Nombre,
                Direccion = s.Direccion,
                Telefono = s.Telefono,
                Activo = s.Activo
            }).FirstOrDefaultAsync();
    }

    public async Task<SucursalDto> CreateAsync(CrearSucursalDto dto)
    {
        var sucursal = new Sucursal
        {
            Nombre = dto.Nombre,
            Direccion = dto.Direccion,
            Telefono = dto.Telefono,
            Activo = true
        };

        _context.Sucursales.Add(sucursal);
        await _context.SaveChangesAsync();

        return (await GetByIdAsync(sucursal.Id))!;
    }

    public async Task<SucursalDto?> UpdateAsync(int id, CrearSucursalDto dto)
    {
        var sucursal = await _context.Sucursales.FindAsync(id);
        if (sucursal == null || !sucursal.Activo) return null;

        sucursal.Nombre = dto.Nombre;
        sucursal.Direccion = dto.Direccion;
        sucursal.Telefono = dto.Telefono;

        await _context.SaveChangesAsync();

        return await GetByIdAsync(id);
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var sucursal = await _context.Sucursales.FindAsync(id);
        if (sucursal == null) return false;

        sucursal.Activo = false;
        await _context.SaveChangesAsync();
        return true;
    }
}
