using System.Text;
using System.Text.Json;
using backend_api.DTOs;

namespace backend_api.Services;

public interface ILLMService
{
    Task<LLMResponseDto> ChatAsync(LLMRequestDto request);
    Task<LLMResponseDto> SugerirComboAsync(string descripcion);
    Task<LLMResponseDto> AnalizarVentasAsync(string datosVentas);
}

public class LLMService : ILLMService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;
    private readonly string _apiKey;
    private readonly string _baseUrl;

    public LLMService(HttpClient httpClient, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _configuration = configuration;
        _apiKey = _configuration["OpenRouter:ApiKey"] ?? "";
        _baseUrl = _configuration["OpenRouter:BaseUrl"] ?? "https://openrouter.ai/api/v1";
    }

    public async Task<LLMResponseDto> ChatAsync(LLMRequestDto request)
    {
        try
        {
            var systemPrompt = @"Eres un asistente virtual de 'La Cazuela Chapina', un negocio guatemalteco de tamales y bebidas artesanales.
            
Conoces el menú:
- TAMALES: Se venden por unidad (Q15), media docena (Q80) o docena (Q150). 
  Opciones: Masa (maíz amarillo, maíz blanco, arroz), Relleno (recado rojo de cerdo, negro de pollo, chipilín vegetariano, chuchito), 
  Envoltura (hoja de plátano, tusa de maíz), Picante (sin chile, suave, chapín).

- BEBIDAS: Vaso 12oz (Q10) o Jarro 1L (Q35).
  Tipos: Atol de elote, Atole shuco, Pinol, Cacao batido.
  Endulzantes: Panela, Miel, Sin azúcar.
  Toppings: Malvaviscos, Canela, Ralladura de cacao.

- COMBOS: Fiesta Patronal (docena surtida + 2 jarros, Q200), Madrugada del 24 (3 docenas + 4 jarros + termo, Q550).

Ayuda a los clientes con sus pedidos, recomendaciones y cualquier consulta sobre el negocio.
Responde siempre en español guatemalteco de forma amigable.";

            var payload = new
            {
                model = "meta-llama/llama-3.2-3b-instruct:free", // Modelo gratuito
                messages = new[]
                {
                    new { role = "system", content = systemPrompt },
                    new { role = "user", content = request.Contexto != null 
                        ? $"{request.Contexto}\n\nPregunta del cliente: {request.Mensaje}" 
                        : request.Mensaje }
                },
                max_tokens = 500,
                temperature = 0.7
            };

            var response = await SendRequestAsync(payload);
            return response;
        }
        catch (Exception ex)
        {
            return new LLMResponseDto
            {
                Exito = false,
                Error = ex.Message,
                Respuesta = "Lo siento, hubo un problema al procesar tu solicitud. ¿Podés intentar de nuevo?"
            };
        }
    }

    public async Task<LLMResponseDto> SugerirComboAsync(string descripcion)
    {
        var request = new LLMRequestDto
        {
            Mensaje = $"Basándote en esta descripción, sugiere un combo ideal con tamales y bebidas: {descripcion}",
            Contexto = "El cliente quiere crear un combo personalizado. Sugiere cantidades, tipos de tamales, bebidas y un precio justo."
        };

        return await ChatAsync(request);
    }

    public async Task<LLMResponseDto> AnalizarVentasAsync(string datosVentas)
    {
        var request = new LLMRequestDto
        {
            Mensaje = "Analiza estos datos de ventas y dame insights útiles para el negocio.",
            Contexto = $"Datos de ventas del período:\n{datosVentas}\n\nProporciona análisis de tendencias, productos estrella, oportunidades de mejora y recomendaciones."
        };

        return await ChatAsync(request);
    }

    private async Task<LLMResponseDto> SendRequestAsync(object payload)
    {
        var json = JsonSerializer.Serialize(payload);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        _httpClient.DefaultRequestHeaders.Clear();
        _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {_apiKey}");
        _httpClient.DefaultRequestHeaders.Add("HTTP-Referer", "https://lacazuelachapina.com");
        _httpClient.DefaultRequestHeaders.Add("X-Title", "La Cazuela Chapina");

        var response = await _httpClient.PostAsync($"{_baseUrl}/chat/completions", content);
        var responseContent = await response.Content.ReadAsStringAsync();

        if (!response.IsSuccessStatusCode)
        {
            return new LLMResponseDto
            {
                Exito = false,
                Error = $"Error API: {response.StatusCode} - {responseContent}",
                Respuesta = "No pude procesar tu solicitud en este momento."
            };
        }

        var result = JsonDocument.Parse(responseContent);
        var message = result.RootElement
            .GetProperty("choices")[0]
            .GetProperty("message")
            .GetProperty("content")
            .GetString();

        return new LLMResponseDto
        {
            Exito = true,
            Respuesta = message ?? "No obtuve respuesta"
        };
    }
}
