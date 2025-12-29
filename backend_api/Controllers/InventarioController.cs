using Microsoft.AspNetCore.Mvc;
using backend_api.DTOs;
using backend_api.Services;

namespace backend_api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class InventarioController : ControllerBase
{
    private readonly IInventarioService _inventarioService;

    public InventarioController(IInventarioService inventarioService)
    {
        _inventarioService = inventarioService;
    }

    /// <summary>
    /// Obtiene todas las materias primas
    /// </summary>
    [HttpGet("materias")]
    public async Task<ActionResult<List<MateriaPrimaDto>>> GetMaterias()
    {
        var materias = await _inventarioService.GetMateriasAsync();
        return Ok(materias);
    }

    /// <summary>
    /// Obtiene una materia prima por ID
    /// </summary>
    [HttpGet("materias/{id}")]
    public async Task<ActionResult<MateriaPrimaDto>> GetMateria(int id)
    {
        var materia = await _inventarioService.GetMateriaByIdAsync(id);
        if (materia == null)
            return NotFound(new { mensaje = "Materia prima no encontrada" });

        return Ok(materia);
    }

    /// <summary>
    /// Crea una nueva materia prima
    /// </summary>
    [HttpPost("materias")]
    public async Task<ActionResult<MateriaPrimaDto>> CreateMateria([FromBody] CrearMateriaPrimaDto dto)
    {
        var materia = await _inventarioService.CreateMateriaAsync(dto);
        return CreatedAtAction(nameof(GetMateria), new { id = materia.Id }, materia);
    }

    /// <summary>
    /// Actualiza una materia prima
    /// </summary>
    [HttpPut("materias/{id}")]
    public async Task<ActionResult<MateriaPrimaDto>> UpdateMateria(int id, [FromBody] CrearMateriaPrimaDto dto)
    {
        var materia = await _inventarioService.UpdateMateriaAsync(id, dto);
        if (materia == null)
            return NotFound(new { mensaje = "Materia prima no encontrada" });

        return Ok(materia);
    }

    /// <summary>
    /// Obtiene los movimientos de inventario
    /// </summary>
    [HttpGet("movimientos")]
    public async Task<ActionResult<List<MovimientoDto>>> GetMovimientos(
        [FromQuery] int? materiaPrimaId = null,
        [FromQuery] DateTime? desde = null,
        [FromQuery] DateTime? hasta = null)
    {
        var movimientos = await _inventarioService.GetMovimientosAsync(materiaPrimaId, desde, hasta);
        return Ok(movimientos);
    }

    /// <summary>
    /// Registra un nuevo movimiento de inventario (Entrada, Salida o Merma)
    /// </summary>
    [HttpPost("movimientos")]
    public async Task<ActionResult<MovimientoDto>> RegistrarMovimiento([FromBody] CrearMovimientoDto dto)
    {
        try
        {
            var movimiento = await _inventarioService.RegistrarMovimientoAsync(dto);
            return Ok(movimiento);
        }
        catch (Exception ex)
        {
            return BadRequest(new { mensaje = ex.Message });
        }
    }

    /// <summary>
    /// Obtiene las alertas de inventario (stock bajo o crítico)
    /// </summary>
    [HttpGet("alertas")]
    public async Task<ActionResult<List<InventarioAlertaDto>>> GetAlertas()
    {
        var alertas = await _inventarioService.GetAlertasAsync();
        return Ok(alertas);
    }
}
