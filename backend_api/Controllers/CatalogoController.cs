using Microsoft.AspNetCore.Mvc;
using backend_api.DTOs;
using backend_api.Services;

namespace backend_api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CatalogoController : ControllerBase
{
    private readonly ICatalogoService _catalogoService;

    public CatalogoController(ICatalogoService catalogoService)
    {
        _catalogoService = catalogoService;
    }

    /// <summary>
    /// Obtiene el catálogo completo con categorías, productos, presentaciones, atributos y combos
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<CatalogoCompletoDto>> GetCatalogo()
    {
        var catalogo = await _catalogoService.GetCatalogoCompletoAsync();
        return Ok(catalogo);
    }

    /// <summary>
    /// Obtiene una categoría específica con sus productos y atributos
    /// </summary>
    [HttpGet("categorias/{id}")]
    public async Task<ActionResult<CategoriaDto>> GetCategoria(int id)
    {
        var categoria = await _catalogoService.GetCategoriaAsync(id);
        if (categoria == null)
            return NotFound(new { mensaje = "Categoría no encontrada" });

        return Ok(categoria);
    }

    /// <summary>
    /// Obtiene los atributos configurables de una categoría
    /// </summary>
    [HttpGet("categorias/{categoriaId}/atributos")]
    public async Task<ActionResult<List<AtributoDto>>> GetAtributos(int categoriaId)
    {
        var atributos = await _catalogoService.GetAtributosPorCategoriaAsync(categoriaId);
        return Ok(atributos);
    }
}
