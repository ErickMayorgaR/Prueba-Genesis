using Microsoft.AspNetCore.Mvc;
using backend_api.DTOs;
using backend_api.Services;

namespace backend_api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CombosController : ControllerBase
{
    private readonly IComboService _comboService;

    public CombosController(IComboService comboService)
    {
        _comboService = comboService;
    }

    /// <summary>
    /// Obtiene todos los combos activos
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<ComboDto>>> GetCombos()
    {
        var combos = await _comboService.GetAllAsync();
        return Ok(combos);
    }

    /// <summary>
    /// Obtiene un combo por su ID
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<ComboDto>> GetCombo(int id)
    {
        var combo = await _comboService.GetByIdAsync(id);
        if (combo == null)
            return NotFound(new { mensaje = "Combo no encontrado" });

        return Ok(combo);
    }

    /// <summary>
    /// Crea un nuevo combo
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<ComboDto>> CreateCombo([FromBody] CrearComboDto dto)
    {
        var combo = await _comboService.CreateAsync(dto);
        return CreatedAtAction(nameof(GetCombo), new { id = combo.Id }, combo);
    }

    /// <summary>
    /// Actualiza un combo existente
    /// </summary>
    [HttpPut("{id}")]
    public async Task<ActionResult<ComboDto>> UpdateCombo(int id, [FromBody] CrearComboDto dto)
    {
        var combo = await _comboService.UpdateAsync(id, dto);
        if (combo == null)
            return NotFound(new { mensaje = "Combo no encontrado" });

        return Ok(combo);
    }

    /// <summary>
    /// Elimina (desactiva) un combo
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<ActionResult> DeleteCombo(int id)
    {
        var resultado = await _comboService.DeleteAsync(id);
        if (!resultado)
            return NotFound(new { mensaje = "Combo no encontrado" });

        return Ok(new { mensaje = "Combo eliminado correctamente" });
    }
}
