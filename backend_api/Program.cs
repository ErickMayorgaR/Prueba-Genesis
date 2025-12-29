using Microsoft.EntityFrameworkCore;
using backend_api.Data;
using backend_api.Services;

var builder = WebApplication.CreateBuilder(args);



// DbContext
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Services (Dependency Injection)
builder.Services.AddScoped<ICatalogoService, CatalogoService>();
builder.Services.AddScoped<IComboService, ComboService>();
builder.Services.AddScoped<IInventarioService, InventarioService>();
builder.Services.AddScoped<IVentaService, VentaService>();
builder.Services.AddScoped<IDashboardService, DashboardService>();
builder.Services.AddScoped<ISucursalService, SucursalService>();

// HttpClient para OpenRouter
builder.Services.AddHttpClient<ILLMService, LLMService>();

builder.Services.AddControllers();

// Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() 
    { 
        Title = "La Cazuela Chapina API", 
        Version = "v1",
        Description = "API para el sistema de gestión de La Cazuela Chapina - Tamales y Bebidas Artesanales"
    });
});

// CORS para React y Flutter
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();



// Swagger siempre habilitado para desarrollo
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "La Cazuela Chapina API v1");
    c.RoutePrefix = string.Empty; // Swagger en la raíz
});

app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseAuthorization();
app.MapControllers();


using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    
    if (context.Database.CanConnect() && !context.Categorias.Any())
    {
        await SeedData.Initialize(context);
    }
}

app.Run();
