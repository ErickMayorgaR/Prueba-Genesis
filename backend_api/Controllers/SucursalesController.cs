using Microsoft.AspNetCore.Mvc;
using backend_api.DTOs;
using backend_api.Services;

namespace backend_api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SucursalesController : ControllerBase
{
    private readonly ISucursalService _sucursalService;

    public SucursalesController(ISucursalService sucursalService)
    {
        _sucursalService = sucursalService;
    }

    /// <summary>
    /// Obtiene todas las sucursales activas
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<SucursalDto>>> GetSucursales()
    {
        var sucursales = await _sucursalService.GetAllAsync();
        return Ok(sucursales);
    }

    /// <summary>
    /// Obtiene una sucursal por su ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<SucursalDto>> GetSucursal(int id)
    {
        var sucursal = await _sucursalService.GetByIdAsync(id);
        if (sucursal == null)
            return NotFound(new { mensaje = "Sucursal no encontrada" });

        return Ok(sucursal);
    }

    /// <summary>
    /// Crea una nueva sucursal
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<SucursalDto>> CreateSucursal([FromBody] CrearSucursalDto dto)
    {
        var sucursal = await _sucursalService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetSucursal), new { id = sucursal.Id }, sucursal);
    }

    /// <summary>
    /// Actualiza una sucursal existente
    /// </summary>
    [HttpPut("{id}")]
    public async Task<ActionResult<SucursalDto>> UpdateSucursal(int id, [FromBody] CrearSucursalDto dto)
    {
        var sucursal = await _sucursalService.UpdateAsync(id, dto);
        if (sucursal == null)
            return NotFound(new { mensaje = "Sucursal no encontrada" });

        return Ok(sucursal);
    }

    /// <summary>
    /// Elimina (desactiva) una sucursal
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<ActionResult> DeleteSucursal(int id)
    {
        var resultado = await _sucursalService.DeleteAsync(id);
        if (!resultado)
            return NotFound(new { mensaje = "Sucursal no encontrada" });

        return Ok(new { mensaje = "Sucursal eliminada correctamente" });
    }
}
