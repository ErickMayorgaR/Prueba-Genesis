using Microsoft.AspNetCore.Mvc;
using backend_api.DTOs;
using backend_api.Services;

namespace backend_api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DashboardController : ControllerBase
{
    private readonly IDashboardService _dashboardService;

    public DashboardController(IDashboardService dashboardService)
    {
        _dashboardService = dashboardService;
    }

    /// <summary>
    /// Obtiene todos los indicadores del dashboard
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<DashboardDto>> GetDashboard([FromQuery] int? sucursalId = null)
    {
        var dashboard = await _dashboardService.GetDashboardAsync(sucursalId);
        return Ok(dashboard);
    }
}
