using Microsoft.EntityFrameworkCore;
using backend_api.Data;
using backend_api.DTOs;

namespace backend_api.Services;

public interface ICatalogoService
{
    Task<CatalogoCompletoDto> GetCatalogoCompletoAsync();
    Task<CategoriaDto?> GetCategoriaAsync(int id);
    Task<List<AtributoDto>> GetAtributosPorCategoriaAsync(int categoriaId);
}

public class CatalogoService : ICatalogoService
{
    private readonly AppDbContext _context;

    public CatalogoService(AppDbContext context)
    {
        _context = context;
    }

    public async Task<CatalogoCompletoDto> GetCatalogoCompletoAsync()
    {
        var categorias = await _context.Categorias
            .Where(c => c.Activo)
            .Include(c => c.Productos.Where(p => p.Activo))
                .ThenInclude(p => p.Presentaciones.Where(pr => pr.Activo))
            .Include(c => c.Atributos.Where(a => a.Activo))
                .ThenInclude(a => a.Opciones.Where(o => o.Activo))
            .OrderBy(c => c.Nombre)
            .Select(c => new CategoriaDto
            {
                Id = c.Id,
                Nombre = c.Nombre,
                Descripcion = c.Descripcion,
                Icono = c.Icono,
                Productos = c.Productos.Select(p => new ProductoDto
                {
                    Id = p.Id,
                    Codigo = p.Codigo,
                    Nombre = p.Nombre,
                    Descripcion = p.Descripcion,
                    ImagenUrl = p.ImagenUrl,
                    Presentaciones = p.Presentaciones.OrderBy(pr => pr.Orden).Select(pr => new PresentacionDto
                    {
                        Id = pr.Id,
                        Nombre = pr.Nombre,
                        Cantidad = pr.Cantidad,
                        Precio = pr.Precio
                    }).ToList()
                }).ToList(),
                Atributos = c.Atributos.OrderBy(a => a.Orden).Select(a => new AtributoDto
                {
                    Id = a.Id,
                    Nombre = a.Nombre,
                    Codigo = a.Codigo,
                    EsMultiple = a.EsMultiple,
                    EsRequerido = a.EsRequerido,
                    Opciones = a.Opciones.OrderBy(o => o.Orden).Select(o => new OpcionDto
                    {
                        Id = o.Id,
                        Nombre = o.Nombre,
                        Codigo = o.Codigo,
                        PrecioExtra = o.PrecioExtra
                    }).ToList()
                }).ToList()
            }).ToListAsync();

        var combos = await _context.Combos
            .Where(c => c.Activo)
            .Where(c => c.Tipo == "FIJO" || 
                       (c.FechaInicio <= DateTime.Today && c.FechaFin >= DateTime.Today))
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

        return new CatalogoCompletoDto
        {
            Categorias = categorias,
            Combos = combos
        };
    }

    public async Task<CategoriaDto?> GetCategoriaAsync(int id)
    {
        return await _context.Categorias
            .Where(c => c.Id == id && c.Activo)
            .Include(c => c.Productos.Where(p => p.Activo))
                .ThenInclude(p => p.Presentaciones.Where(pr => pr.Activo))
            .Include(c => c.Atributos.Where(a => a.Activo))
                .ThenInclude(a => a.Opciones.Where(o => o.Activo))
            .Select(c => new CategoriaDto
            {
                Id = c.Id,
                Nombre = c.Nombre,
                Descripcion = c.Descripcion,
                Icono = c.Icono,
                Productos = c.Productos.Select(p => new ProductoDto
                {
                    Id = p.Id,
                    Codigo = p.Codigo,
                    Nombre = p.Nombre,
                    Descripcion = p.Descripcion,
                    ImagenUrl = p.ImagenUrl,
                    Presentaciones = p.Presentaciones.OrderBy(pr => pr.Orden).Select(pr => new PresentacionDto
                    {
                        Id = pr.Id,
                        Nombre = pr.Nombre,
                        Cantidad = pr.Cantidad,
                        Precio = pr.Precio
                    }).ToList()
                }).ToList(),
                Atributos = c.Atributos.OrderBy(a => a.Orden).Select(a => new AtributoDto
                {
                    Id = a.Id,
                    Nombre = a.Nombre,
                    Codigo = a.Codigo,
                    EsMultiple = a.EsMultiple,
                    EsRequerido = a.EsRequerido,
                    Opciones = a.Opciones.OrderBy(o => o.Orden).Select(o => new OpcionDto
                    {
                        Id = o.Id,
                        Nombre = o.Nombre,
                        Codigo = o.Codigo,
                        PrecioExtra = o.PrecioExtra
                    }).ToList()
                }).ToList()
            }).FirstOrDefaultAsync();
    }

    public async Task<List<AtributoDto>> GetAtributosPorCategoriaAsync(int categoriaId)
    {
        return await _context.Atributos
            .Where(a => a.CategoriaId == categoriaId && a.Activo)
            .OrderBy(a => a.Orden)
            .Include(a => a.Opciones.Where(o => o.Activo))
            .Select(a => new AtributoDto
            {
                Id = a.Id,
                Nombre = a.Nombre,
                Codigo = a.Codigo,
                EsMultiple = a.EsMultiple,
                EsRequerido = a.EsRequerido,
                Opciones = a.Opciones.OrderBy(o => o.Orden).Select(o => new OpcionDto
                {
                    Id = o.Id,
                    Nombre = o.Nombre,
                    Codigo = o.Codigo,
                    PrecioExtra = o.PrecioExtra
                }).ToList()
            }).ToListAsync();
    }
}
