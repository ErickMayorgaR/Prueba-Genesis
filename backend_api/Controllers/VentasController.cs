using Microsoft.AspNetCore.Mvc;
using backend_api.DTOs;
using backend_api.Services;

namespace backend_api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class VentasController : ControllerBase
{
    private readonly IVentaService _ventaService;

    public VentasController(IVentaService ventaService)
    {
        _ventaService = ventaService;
    }

    /// <summary>
    /// Obtiene las ventas con filtros opcionales
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<VentaDto>>> GetVentas(
        [FromQuery] int? sucursalId = null,
        [FromQuery] DateTime? desde = null,
        [FromQuery] DateTime? hasta = null)
    {
        var ventas = await _ventaService.GetVentasAsync(sucursalId, desde, hasta);
        return Ok(ventas);
    }

    /// <summary>
    /// Obtiene una venta por su ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<VentaDto>> GetVenta(int id)
    {
        var venta = await _ventaService.GetByIdAsync(id);
        if (venta == null)
            return NotFound(new { mensaje = "Venta no encontrada" });

        return Ok(venta);
    }

    /// <summary>
    /// Registra una nueva venta
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<VentaDto>> CreateVenta([FromBody] CrearVentaDto dto)
    {
        try
        {
            var venta = await _ventaService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetVenta), new { id = venta.Id }, venta);
        }
        catch (Exception ex)
        {
            return BadRequest(new { mensaje = ex.Message });
        }
    }

    /// <summary>
    /// Anula una venta
    /// </summary>
    [HttpPut("{id}/anular")]
    public async Task<ActionResult> AnularVenta(int id)
    {
        var resultado = await _ventaService.AnularAsync(id);
        if (!resultado)
            return NotFound(new { mensaje = "Venta no encontrada" });

        return Ok(new { mensaje = "Venta anulada correctamente" });
    }
}
