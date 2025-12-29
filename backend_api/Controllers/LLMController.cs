using Microsoft.AspNetCore.Mvc;
using backend_api.DTOs;
using backend_api.Services;

namespace backend_api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LLMController : ControllerBase
{
    private readonly ILLMService _llmService;
    private readonly IDashboardService _dashboardService;

    public LLMController(ILLMService llmService, IDashboardService dashboardService)
    {
        _llmService = llmService;
        _dashboardService = dashboardService;
    }

    /// <summary>
    /// Chat con el asistente virtual de La Cazuela Chapina
    /// </summary>
    [HttpPost("chat")]
    public async Task<ActionResult<LLMResponseDto>> Chat([FromBody] LLMRequestDto request)
    {
        var response = await _llmService.ChatAsync(request);
        return Ok(response);
    }

    /// <summary>
    /// Sugiere un combo basado en una descripción
    /// </summary>
    [HttpPost("sugerir-combo")]
    public async Task<ActionResult<LLMResponseDto>> SugerirCombo([FromBody] string descripcion)
    {
        var response = await _llmService.SugerirComboAsync(descripcion);
        return Ok(response);
    }

    /// <summary>
    /// Analiza las ventas y da insights
    /// </summary>
    [HttpGet("analizar-ventas")]
    public async Task<ActionResult<LLMResponseDto>> AnalizarVentas([FromQuery] int? sucursalId = null)
    {
        // Obtener datos del dashboard para enviar al LLM
        var dashboard = await _dashboardService.GetDashboardAsync(sucursalId);
        
        var datosVentas = $@"
Ventas de Hoy: Q{dashboard.VentasHoy:N2} ({dashboard.TotalVentasHoy} ventas)
Ventas del Mes: Q{dashboard.VentasMes:N2} ({dashboard.TotalVentasMes} ventas)

Productos más vendidos:
{string.Join("\n", dashboard.ProductosMasVendidos.Select(p => $"- {p.Producto} ({p.Presentacion}): {p.CantidadVendida} unidades, Q{p.TotalVendido:N2}"))}

Proporción Picante: {dashboard.ProporcionPicante.PorcentajeConPicante}% con picante, {100 - dashboard.ProporcionPicante.PorcentajeConPicante}% sin picante

Utilidades por Línea:
{string.Join("\n", dashboard.UtilidadesPorLinea.Select(u => $"- {u.Linea}: Ventas Q{u.Ventas:N2}, Margen {u.MargenPorcentaje}%"))}

Desperdicio del Mes: Q{dashboard.DesperdicioMes:N2}

Alertas de Inventario: {dashboard.AlertasInventario.Count} productos en nivel bajo/crítico";

        var response = await _llmService.AnalizarVentasAsync(datosVentas);
        return Ok(response);
    }
}
