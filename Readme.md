#  La Cazuela Chapina - Sistema Integral de Gestión

## Documentación Técnica del Proyecto

**Curso:** Prueba Práctica React, .NET y Flutter  
**Fecha:** Diciembre 2025


Tambien se puede consultar información técnica en:
---


https://deepwiki.com/ErickMayorgaR/Prueba-Genesis/1-overview

##  Tabla de Contenidos

1. [Descripción del Proyecto](#1-descripción-del-proyecto)
2. [Arquitectura del Sistema](#2-arquitectura-del-sistema)
3. [Tecnologías Utilizadas](#3-tecnologías-utilizadas)
4. [Modelo de Datos](#4-modelo-de-datos)
5. [Backend - API .NET](#5-backend---api-net)
6. [Frontend - React](#6-frontend---react)
7. [Mobile - Flutter](#7-mobile---flutter)
8. [Integración LLM](#8-integración-llm)
9. [Instrucciones de Instalación](#9-instrucciones-de-instalación)
10. [Endpoints de la API](#10-endpoints-de-la-api)
11. [Funcionalidades Implementadas](#11-funcionalidades-implementadas)

---

## 1. Descripción del Proyecto

**La Cazuela Chapina** es un sistema integral para la gestión de un negocio de comida típica guatemalteca especializado en tamales tradicionales y bebidas artesanales de maíz y cacao.

### Alcance del Sistema

El sistema permite:
- Gestión de catálogo de productos con personalización
- Registro y seguimiento de ventas
- Control de inventario de materias primas
- Dashboard con indicadores clave (KPIs)
- Gestión de combos promocionales
- Asistente virtual con inteligencia artificial
- Operación multi-sucursal

### Productos Manejados

#### Tamales
| Presentación | Precio |
|--------------|--------|
| Unidad | Q15.00 |
| Media Docena (6 uds) | Q80.00 |
| Docena (12 uds) | Q150.00 |

**Atributos personalizables:**
| Atributo | Opciones |
|----------|----------|
| Tipo de masa | Maíz amarillo, Maíz blanco, Arroz |
| Relleno | Recado rojo de cerdo, Negro de pollo, Chipilín vegetariano, Estilo chuchito |
| Envoltura | Hoja de plátano, Tusa de maíz |
| Nivel de picante | Sin chile, Suave, Chapín |

#### Bebidas Artesanales
| Presentación | Precio |
|--------------|--------|
| Vaso 12oz | Q10.00 |
| Jarro 1L | Q35.00 |

**Atributos personalizables:**
| Atributo | Opciones |
|----------|----------|
| Tipo | Atol de elote, Atole shuco, Pinol, Cacao batido |
| Endulzante | Panela, Miel, Sin azúcar |
| Toppings | Malvaviscos, Canela, Ralladura de cacao |

#### Combos Disponibles
| Combo | Contenido | Precio |
|-------|-----------|--------|
| Fiesta Patronal | Docena surtida + 2 jarros familiares | Q200.00 |
| Madrugada del 24 | 3 docenas + 4 jarros + termo conmemorativo | Q550.00 |
| Desayuno Chapín | 3 tamales + 1 bebida | Q55.00 |
| Navideño 2025 | Combo estacional configurable | Variable |

---

## 2. Arquitectura del Sistema

### Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────────┐
│                        CAPA DE PRESENTACIÓN                         │
├─────────────────────────────┬───────────────────────────────────────┤
│      Frontend Web           │           App Móvil                   │
│      React + TypeScript     │           Flutter + Dart              │
│      Vite + Tailwind CSS    │           Material Design             │
│      Puerto: 5173           │           Android/iOS                 │
└──────────────┬──────────────┴───────────────────┬───────────────────┘
               │                                   │
               │         HTTP/REST API             │
               │                                   │
               ▼                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         CAPA DE SERVICIOS                           │
│                    .NET 8 Web API (Puerto 5222/7230)                │
├─────────────────────────────────────────────────────────────────────┤
│  Controllers:                                                       │
│  ├── CatalogoController     (Productos, Categorías, Atributos)     │
│  ├── VentasController       (Registro y consulta de ventas)        │
│  ├── InventarioController   (Materias primas, movimientos)         │
│  ├── CombosController       (CRUD de combos)                       │
│  ├── DashboardController    (KPIs y estadísticas)                  │
│  ├── SucursalesController   (Gestión de sucursales)                │
│  └── LLMController          (Integración OpenRouter/Llama)         │
├─────────────────────────────────────────────────────────────────────┤
│  Services (Inyección de Dependencias):                              │
│  ├── CatalogoService        │  DashboardService                    │
│  ├── VentaService           │  SucursalService                     │
│  ├── InventarioService      │  LLMService (OpenRouter)             │
│  └── ComboService           │                                      │
└──────────────────────────────────┬──────────────────────────────────┘
                                   │
                                   │ Entity Framework Core
                                   │
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         CAPA DE DATOS                               │
│                   SQL Server (Database First)                       │
├─────────────────────────────────────────────────────────────────────┤
│  Base de datos: NegocioCocina                                       │
│  Tablas: 12 tablas normalizadas                                     │
│  Datos de prueba: Ventas, Inventario, Movimientos precargados       │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ HTTP
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    SERVICIOS EXTERNOS                               │
│                    OpenRouter API (LLM)                             │
│                    Modelo: meta-llama/llama-3.2-3b-instruct:free   │
│                    URL: https://openrouter.ai/api/v1               │
└─────────────────────────────────────────────────────────────────────┘
```

### Patrón de Diseño

El proyecto implementa una arquitectura de **3 capas** con los siguientes patrones:

| Patrón | Implementación |
|--------|----------------|
| Repository Pattern | Implícito en Entity Framework Core |
| Service Layer | Servicios separados por dominio |
| Dependency Injection | Configurado en Program.cs |
| DTOs | Separación entre modelos y transferencia |
| Database First | Modelos generados desde SQL Server |

---

## 3. Tecnologías Utilizadas

### Backend
| Tecnología | Versión | Uso |
|------------|---------|-----|
| .NET | 8.0 | Framework principal |
| ASP.NET Core Web API | 8.0 | API REST |
| Entity Framework Core | 8.0 | ORM / Acceso a datos |
| SQL Server | 2019+ | Base de datos relacional |
| Swagger/OpenAPI | 6.x | Documentación interactiva de API |
| HttpClient | Built-in | Conexión a servicios externos |

### Frontend Web
| Tecnología | Versión | Uso |
|------------|---------|-----|
| React | 18.x | Librería UI |
| TypeScript | 5.x | Tipado estático |
| Vite | 5.x | Build tool y dev server |
| Tailwind CSS | 3.x | Framework de estilos |
| Recharts | 2.x | Gráficos y visualizaciones |
| Axios | 1.x | Cliente HTTP |
| React Router | 6.x | Navegación SPA |

### Mobile
| Tecnología | Versión | Uso |
|------------|---------|-----|
| Flutter | 3.x | Framework multiplataforma |
| Dart | 3.x | Lenguaje de programación |
| http | 1.x | Cliente HTTP |
| Material Design | 3 | Sistema de diseño |

### Servicios Externos
| Servicio | Modelo | Uso |
|----------|--------|-----|
| OpenRouter | meta-llama/llama-3.2-3b-instruct:free | Gateway LLM gratuito |

---

## 4. Modelo de Datos

### Diagrama Entidad-Relación

```
┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│    CATEGORIAS    │         │    PRODUCTOS     │         │  PRESENTACIONES  │
├──────────────────┤         ├──────────────────┤         ├──────────────────┤
│ Id          PK   │────1:N──│ Id          PK   │────1:N──│ Id          PK   │
│ Nombre           │         │ CategoriaId FK   │         │ ProductoId  FK   │
│ Descripcion      │         │ Nombre           │         │ Nombre           │
│ Activo           │         │ Descripcion      │         │ Cantidad         │
└──────────────────┘         │ PrecioBase       │         │ Precio           │
        │                    │ Activo           │         │ Activo           │
        │                    └──────────────────┘         └──────────────────┘
        │                                                          │
        │ 1:N                                                       │
        ▼                                                          │
┌──────────────────┐         ┌──────────────────┐                  │
│    ATRIBUTOS     │         │ ATRIBUTO_OPCIONES│                  │
├──────────────────┤         ├──────────────────┤                  │
│ Id          PK   │────1:N──│ Id          PK   │                  │
│ CategoriaId FK   │         │ AtributoId  FK   │                  │
│ Nombre           │         │ Nombre           │                  │
│ Obligatorio      │         │ PrecioExtra      │                  │
│ Orden            │         │ Activo           │                  │
└──────────────────┘         └──────────────────┘                  │
                                                                   │
┌──────────────────┐         ┌──────────────────┐                  │
│     COMBOS       │         │   COMBO_ITEMS    │                  │
├──────────────────┤         ├──────────────────┤                  │
│ Id          PK   │────1:N──│ Id          PK   │──────────────────┘
│ Nombre           │         │ ComboId     FK   │         N:1
│ Descripcion      │         │ PresentacionId FK│
│ Precio           │         │ Cantidad         │
│ Activo           │         └──────────────────┘
│ FechaInicio      │
│ FechaFin         │
└──────────────────┘

┌──────────────────┐         ┌──────────────────┐         ┌──────────────────┐
│   SUCURSALES     │         │     VENTAS       │         │   VENTA_ITEMS    │
├──────────────────┤         ├──────────────────┤         ├──────────────────┤
│ Id          PK   │────1:N──│ Id          PK   │────1:N──│ Id          PK   │
│ Nombre           │         │ SucursalId  FK   │         │ VentaId     FK   │
│ Direccion        │         │ Fecha            │         │ PresentacionId FK│
│ Activo           │         │ Subtotal         │         │ ComboId     FK   │
└──────────────────┘         │ Descuento        │         │ Cantidad         │
                             │ Total            │         │ PrecioUnitario   │
                             │ Estado           │         │ Subtotal         │
                             └──────────────────┘         │ Personalizacion  │
                                                          │ (JSON)           │
                                                          └──────────────────┘

┌──────────────────┐         ┌──────────────────────────┐
│ MATERIAS_PRIMAS  │         │ INVENTARIO_MOVIMIENTOS   │
├──────────────────┤         ├──────────────────────────┤
│ Id          PK   │────1:N──│ Id                  PK   │
│ Nombre           │         │ MateriaPrimaId      FK   │
│ UnidadMedida     │         │ Tipo (E/S/M)             │
│ StockActual      │         │ Cantidad                 │
│ StockMinimo      │         │ CostoUnitario            │
│ PuntoCritico     │         │ Fecha                    │
│ CostoPromedio    │         │ Observaciones            │
│ Categoria        │         └──────────────────────────┘
└──────────────────┘
```

### Descripción de Tablas

| Tabla | Registros | Descripción |
|-------|-----------|-------------|
| Categorias | 2 | Tamales, Bebidas |
| Productos | 5 | Tamal Chapín + 4 bebidas artesanales |
| Presentaciones | 7 | Unidad, Media Docena, Docena, Vaso 12oz, Jarro 1L |
| Atributos | 6 | Masa, Relleno, Envoltura, Picante, Endulzante, Topping |
| AtributoOpciones | 17 | Todas las opciones de personalización |
| Combos | 4 | Fiesta Patronal, Madrugada del 24, Desayuno Chapín, Navideño |
| ComboItems | 8 | Items incluidos en cada combo |
| Sucursales | 3 | Casa Matriz Zona 1, Sucursal Zona 10, Sucursal Mixco |
| Ventas | 30+ | Ventas de prueba con datos realistas |
| VentaItems | 50+ | Detalle de cada venta con personalizaciones |
| MateriasPrimas | 20 | Masa, hojas, proteínas, granos, especias, empaques, combustible |
| InventarioMovimientos | 40+ | Entradas, salidas y mermas registradas |

---

## 5. Backend - API .NET

### Estructura del Proyecto

```
backend_api/
│
├── Controllers/                    # Endpoints REST
│   ├── CatalogoController.cs      # GET catálogo, categorías, atributos
│   ├── VentasController.cs        # CRUD ventas
│   ├── InventarioController.cs    # Materias primas, movimientos, alertas
│   ├── CombosController.cs        # CRUD combos
│   ├── DashboardController.cs     # KPIs y estadísticas
│   ├── SucursalesController.cs    # CRUD sucursales
│   └── LLMController.cs           # Chat, sugerencias, análisis IA
│
├── Models/                         # Entidades de base de datos
│   ├── Categoria.cs
│   ├── Producto.cs
│   ├── Presentacion.cs
│   ├── Atributo.cs
│   ├── AtributoOpcion.cs
│   ├── Combo.cs
│   ├── ComboItem.cs
│   ├── Venta.cs
│   ├── VentaItem.cs
│   ├── MateriaPrima.cs
│   ├── InventarioMovimiento.cs
│   └── Sucursal.cs
│
├── DTOs/                           # Data Transfer Objects
│   └── AllDTOs.cs                 # Todos los DTOs en un archivo
│
├── Data/                           # Acceso a datos
│   ├── AppDbContext.cs            # Contexto de Entity Framework
│   └── SeedData.cs                # Datos iniciales de prueba
│
├── Services/                       # Lógica de negocio
│   ├── CatalogoService.cs
│   ├── VentaService.cs
│   ├── InventarioService.cs
│   ├── ComboService.cs
│   ├── DashboardService.cs
│   ├── SucursalService.cs
│   └── LLMService.cs              # Integración OpenRouter
│
├── Program.cs                      # Configuración de la aplicación
├── appsettings.json               # Configuración (connection string, OpenRouter)
├── appsettings.Development.json   # Configuración de desarrollo
└── backend_api.csproj             # Archivo de proyecto
```

### Configuración de Servicios (Program.cs)

```csharp
// Entity Framework con SQL Server
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Inyección de dependencias - Servicios
builder.Services.AddScoped<ICatalogoService, CatalogoService>();
builder.Services.AddScoped<IComboService, ComboService>();
builder.Services.AddScoped<IInventarioService, InventarioService>();
builder.Services.AddScoped<IVentaService, VentaService>();
builder.Services.AddScoped<IDashboardService, DashboardService>();
builder.Services.AddScoped<ISucursalService, SucursalService>();

// HttpClient tipado para OpenRouter
builder.Services.AddHttpClient<ILLMService, LLMService>();

// CORS para React (puerto 5173) y Flutter
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// Swagger con documentación
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() 
    { 
        Title = "La Cazuela Chapina API", 
        Version = "v1",
        Description = "API para el sistema de gestión de La Cazuela Chapina"
    });
});
```

### Configuración (appsettings.json)

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=NegocioCocina;Trusted_Connection=True;TrustServerCertificate=True;"
  },
  "OpenRouter": {
    "ApiKey": "",
    "Model": "meta-llama/llama-3.2-3b-instruct:free",
    "BaseUrl": "https://openrouter.ai/api/v1"
  }
}
```

---

## 6. Frontend - React

### Estructura del Proyecto

```
frontend_web/
│
├── src/
│   ├── components/                 # Componentes de UI
│   │   ├── Dashboard.tsx          # Panel con KPIs y gráficos
│   │   ├── Catalogo.tsx           # Lista de productos
│   │   ├── Combos.tsx             # Gestión de combos
│   │   ├── Ventas.tsx             # Registro de ventas
│   │   ├── Inventario.tsx         # Control de materias primas
│   │   └── Navbar.tsx             # Navegación principal
│   │
│   ├── services/
│   │   └── api.ts                 # Cliente Axios configurado
│   │
│   ├── types/
│   │   └── index.ts               # Interfaces TypeScript
│   │
│   ├── App.tsx                    # Componente raíz con rutas
│   ├── main.tsx                   # Punto de entrada
│   └── index.css                  # Estilos globales + Tailwind
│
├── public/                         # Archivos estáticos
├── package.json                    # Dependencias npm
├── tailwind.config.js             # Configuración Tailwind
├── tsconfig.json                  # Configuración TypeScript
└── vite.config.ts                 # Configuración Vite
```

### Módulos del Frontend

| Módulo | Ruta | Funcionalidad |
|--------|------|---------------|
| Dashboard | `/` | KPIs, gráficos de ventas, alertas de inventario |
| Catálogo | `/catalogo` | Lista de productos con atributos y presentaciones |
| Combos | `/combos` | Crear, editar, eliminar combos promocionales |
| Ventas | `/ventas` | Registrar ventas, ver historial, anular |
| Inventario | `/inventario` | Materias primas, movimientos, alertas de stock |

### Dependencias Principales

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0",
    "axios": "^1.6.0",
    "recharts": "^2.10.0",
    "lucide-react": "^0.294.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "vite": "^5.0.0",
    "tailwindcss": "^3.3.0",
    "@types/react": "^18.2.0"
  }
}
```

---

## 7. Mobile - Flutter

### Estructura del Proyecto

```
mobile_app/
│
├── lib/
│   ├── models/                     # Modelos de datos
│   │   ├── dashboard_data.dart
│   │   ├── producto.dart
│   │   ├── categoria.dart
│   │   ├── presentacion.dart
│   │   ├── combo.dart
│   │   ├── venta.dart
│   │   ├── materia_prima.dart
│   │   └── sucursal.dart
│   │
│   ├── screens/                    # Pantallas de la app
│   │   ├── home_screen.dart       # Navegación principal
│   │   ├── dashboard_screen.dart  # KPIs móviles
│   │   ├── catalogo_screen.dart   # Productos
│   │   ├── combos_screen.dart     # Promociones
│   │   ├── ventas_screen.dart     # Registro de ventas
│   │   ├── inventario_screen.dart # Materias primas
│   │   └── sucursales_screen.dart # Gestión de sucursales
│   │
│   ├── services/
│   │   └── api_service.dart       # Cliente HTTP
│   │
│   ├── widgets/                    # Widgets reutilizables
│   │   └── ...
│   │
│   └── main.dart                   # Punto de entrada
│
├── pubspec.yaml                    # Dependencias
├── android/                        # Configuración Android
├── ios/                            # Configuración iOS
└── ...
```

### Pantallas Implementadas

| Pantalla | Descripción |
|----------|-------------|
| Home | Drawer con navegación a todos los módulos |
| Dashboard | Tarjetas de KPIs, ventas del día/mes, alertas |
| Catálogo | Lista de categorías y productos con detalles |
| Combos | Cards de combos con precio y contenido |
| Ventas | Lista de ventas con filtros y detalle |
| Inventario | Materias primas con indicadores de stock |
| Sucursales | Lista de sucursales con información |

### Configuración de API

```dart
class ApiService {
  // Para emulador Android usar 10.0.2.2
  // Para dispositivo físico usar IP de la máquina
  static const String baseUrl = 'http://10.0.2.2:5222/api';
  
  // Métodos HTTP
  Future<dynamic> get(String endpoint) async { ... }
  Future<dynamic> post(String endpoint, dynamic data) async { ... }
  Future<dynamic> put(String endpoint, dynamic data) async { ... }
  Future<dynamic> delete(String endpoint) async { ... }
}
```

### Dependencias (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  provider: ^6.1.0
  intl: ^0.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## 8. Integración LLM

### Arquitectura de la Integración

```
┌────────────────┐         ┌─────────────────┐         ┌──────────────────┐
│   Cliente      │         │  LLMController  │         │   LLMService     │
│ React/Flutter  │────────▶│  .NET API       │────────▶│                  │
└────────────────┘         └─────────────────┘         └────────┬─────────┘
                                                                │
                                    HTTP POST                   │
                                    Authorization: Bearer       │
                                                               ▼
                                                      ┌──────────────────┐
                                                      │   OpenRouter     │
                                                      │   /v1/chat/      │
                                                      │   completions    │
                                                      └────────┬─────────┘
                                                               │
                                                               ▼
                                                      ┌──────────────────┐
                                                      │  Llama 3.2 3B    │
                                                      │  (Gratuito)      │
                                                      └──────────────────┘
```

### Interfaz del Servicio

```csharp
public interface ILLMService
{
    // Chat general con el asistente virtual
    Task<LLMResponseDto> ChatAsync(LLMRequestDto request);
    
    // Sugerir combo basado en descripción del cliente
    Task<LLMResponseDto> SugerirComboAsync(string descripcion);
    
    // Analizar datos del dashboard y generar insights
    Task<LLMResponseDto> AnalizarVentasAsync(string datosVentas);
}
```

### Implementación del Servicio

```csharp
public class LLMService : ILLMService
{
    private readonly HttpClient _httpClient;
    private readonly string _apiKey;
    private readonly string _baseUrl;

    public LLMService(HttpClient httpClient, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _apiKey = configuration["OpenRouter:ApiKey"] ?? "";
        _baseUrl = configuration["OpenRouter:BaseUrl"] ?? "https://openrouter.ai/api/v1";
    }

    public async Task<LLMResponseDto> ChatAsync(LLMRequestDto request)
    {
        var systemPrompt = @"Eres un asistente virtual de 'La Cazuela Chapina', 
        un negocio guatemalteco de tamales y bebidas artesanales.
        
        Conoces el menú:
        - TAMALES: unidad (Q15), media docena (Q80), docena (Q150)
        - BEBIDAS: Vaso 12oz (Q10), Jarro 1L (Q35)
        - COMBOS: Fiesta Patronal (Q200), Madrugada del 24 (Q550)
        
        Responde siempre en español guatemalteco de forma amigable.";

        var payload = new
        {
            model = "meta-llama/llama-3.2-3b-instruct:free",
            messages = new[]
            {
                new { role = "system", content = systemPrompt },
                new { role = "user", content = request.Mensaje }
            },
            max_tokens = 500,
            temperature = 0.7
        };

        return await SendRequestAsync(payload);
    }
    
    // ... otros métodos
}
```

### Endpoints del LLM

| Método | Endpoint | Body | Descripción |
|--------|----------|------|-------------|
| POST | `/api/llm/chat` | `{ "mensaje": "string", "contexto": "string?" }` | Chat con asistente que conoce el menú |
| POST | `/api/llm/sugerir-combo` | `"descripción del evento"` | Sugiere combo personalizado |
| GET | `/api/llm/analizar-ventas` | Query: `?sucursalId=1` | Analiza KPIs y genera insights |

### Funcionalidades del Asistente Virtual

1. **Chat General**
   - Responde preguntas sobre el menú
   - Recomienda productos según preferencias
   - Explica opciones de personalización
   - Informa sobre precios y combos

2. **Sugerencia de Combos**
   - Recibe descripción del evento (ej: "fiesta de 20 personas")
   - Sugiere cantidades de tamales y bebidas
   - Calcula precio estimado
   - Considera preferencias mencionadas

3. **Análisis de Ventas**
   - Recibe datos del dashboard en tiempo real
   - Identifica tendencias y patrones
   - Genera recomendaciones de negocio
   - Sugiere acciones para mejorar ventas

### Seguridad de Credenciales

La API Key de OpenRouter se almacena usando **User Secrets** de .NET:

```bash
# Inicializar User Secrets en el proyecto
dotnet user-secrets init

# Guardar la API Key de forma segura
dotnet user-secrets set "OpenRouter:ApiKey" "sk-or-v1-xxxxx"

# Ver secrets guardados
dotnet user-secrets list
```

**Ubicación de User Secrets:**
- Windows: `%APPDATA%\Microsoft\UserSecrets\<user_secrets_id>\secrets.json`
- Linux/Mac: `~/.microsoft/usersecrets/<user_secrets_id>/secrets.json`

---

## 9. Instrucciones de Instalación

### Requisitos Previos

| Software | Versión | Descarga |
|----------|---------|----------|
| .NET SDK | 8.0+ | https://dotnet.microsoft.com/download |
| Node.js | 18+ | https://nodejs.org |
| SQL Server | 2019+ | LocalDB, Express o Full |
| Flutter SDK | 3.x | https://flutter.dev |
| Git | 2.x | https://git-scm.com |

### Paso 1: Clonar/Descomprimir el Proyecto

```bash
# Si es un ZIP
unzip proyecto.zip
cd proyecto/

# Estructura esperada
├── backend_api/
├── frontend_web/
└── mobile_app/
```

### Paso 2: Configurar Backend (.NET)

```bash
# Navegar al directorio del backend
cd backend_api

# Restaurar paquetes NuGet
dotnet restore

# Editar appsettings.json con tu connection string
# Server=localhost;Database=NegocioCocina;Trusted_Connection=True;TrustServerCertificate=True;

# Crear la base de datos (Entity Framework)
dotnet ef migrations add InitialCreate
dotnet ef database update

# (Opcional) Configurar OpenRouter API Key
dotnet user-secrets init
dotnet user-secrets set "OpenRouter:ApiKey" "tu-api-key-de-openrouter"

# Ejecutar el backend
dotnet run

# El API estará en:
# - HTTPS: https://localhost:7230
# - HTTP: http://localhost:5222
# - Swagger: https://localhost:7230/swagger
```

### Paso 3: Configurar Frontend (React)

```bash
# En otra terminal, navegar al frontend
cd frontend_web

# Instalar dependencias
npm install

# Ejecutar en modo desarrollo
npm run dev

# El frontend estará en: http://localhost:5173
```

### Paso 4: Configurar Mobile (Flutter)

```bash
# En otra terminal, navegar al proyecto móvil
cd mobile_app

# Obtener dependencias
flutter pub get

# Verificar dispositivos disponibles
flutter devices

# Ejecutar en emulador o dispositivo
flutter run
```

**Nota para Android Emulator:** 
El API URL debe apuntar a `10.0.2.2:5222` (no `localhost`) ya que el emulador tiene su propia red.

### Verificación de Instalación

| Componente | URL | Estado Esperado |
|------------|-----|-----------------|
| Backend API | http://localhost:5222/swagger | Swagger UI visible |
| Frontend Web | http://localhost:5173 | Dashboard cargando |
| Mobile App | Emulador/Dispositivo | Home screen visible |

---

## 10. Endpoints de la API

### Catálogo

| Método | Endpoint | Descripción | Response |
|--------|----------|-------------|----------|
| GET | `/api/catalogo` | Catálogo completo | Lista de categorías con productos |
| GET | `/api/catalogo/categorias/{id}` | Categoría específica | Categoría con productos |
| GET | `/api/catalogo/categorias/{id}/atributos` | Atributos de categoría | Lista de atributos con opciones |
| GET | `/api/catalogo/productos/{id}/presentaciones` | Presentaciones | Lista de presentaciones |

### Ventas

| Método | Endpoint | Descripción | Body/Params |
|--------|----------|-------------|-------------|
| GET | `/api/ventas` | Listar ventas | Query: `?sucursalId=1&fecha=2024-12-29` |
| GET | `/api/ventas/{id}` | Detalle de venta | - |
| POST | `/api/ventas` | Registrar venta | `CrearVentaDto` |
| PUT | `/api/ventas/{id}/anular` | Anular venta | - |

**Ejemplo de CrearVentaDto:**
```json
{
  "sucursalId": 1,
  "descuento": 0,
  "items": [
    {
      "presentacionId": 3,
      "cantidad": 1,
      "personalizacion": {
        "masa": 1,
        "relleno": 1,
        "envoltura": 1,
        "picante": 3
      }
    }
  ]
}
```

### Inventario

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/inventario/materias` | Listar materias primas |
| POST | `/api/inventario/materias` | Crear materia prima |
| PUT | `/api/inventario/materias/{id}` | Actualizar materia prima |
| DELETE | `/api/inventario/materias/{id}` | Eliminar materia prima |
| GET | `/api/inventario/movimientos` | Listar movimientos |
| POST | `/api/inventario/movimientos` | Registrar movimiento |
| GET | `/api/inventario/alertas` | Alertas de stock bajo |

### Combos

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/combos` | Listar combos activos |
| GET | `/api/combos/{id}` | Detalle de combo |
| POST | `/api/combos` | Crear combo |
| PUT | `/api/combos/{id}` | Actualizar combo |
| DELETE | `/api/combos/{id}` | Eliminar combo |

### Dashboard

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/dashboard` | Todos los KPIs |
| GET | `/api/dashboard?sucursalId={id}` | KPIs filtrados por sucursal |

**Response del Dashboard:**
```json
{
  "ventasHoy": 1250.00,
  "totalVentasHoy": 15,
  "ventasMes": 28500.00,
  "totalVentasMes": 342,
  "productosMasVendidos": [...],
  "bebidasPorHorario": {...},
  "proporcionPicante": {...},
  "utilidadesPorLinea": [...],
  "desperdicioMes": 450.00,
  "alertasInventario": [...]
}
```

### Sucursales

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/sucursales` | Listar sucursales |
| GET | `/api/sucursales/{id}` | Detalle de sucursal |
| POST | `/api/sucursales` | Crear sucursal |
| PUT | `/api/sucursales/{id}` | Actualizar sucursal |

### LLM (Inteligencia Artificial)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/llm/chat` | Chat con asistente virtual |
| POST | `/api/llm/sugerir-combo` | Sugerir combo personalizado |
| GET | `/api/llm/analizar-ventas` | Análisis de ventas con IA |

---

## 11. Funcionalidades Implementadas

### Checklist de Requisitos

#### Tecnologías Objetivo
| Requisito | Estado | Implementación |
|-----------|--------|----------------|
| 1.1 Frontend web en React | ✅ | React 18 + TypeScript + Vite |
| 1.2 API en .NET | ✅ | .NET 8 Web API con Controllers |
| 1.3 App móvil en Flutter | ✅ | Flutter 3 + Dart |

#### Catálogo de Productos
| Requisito | Estado | Implementación |
|-----------|--------|----------------|
| 2.1 Tamales: unidad, 6, 12 uds | ✅ | 3 presentaciones configuradas |
| 2.2 Atributos tamal | ✅ | Masa, relleno, envoltura, picante |
| 2.3 Bebidas: vaso 12oz, jarro 1L | ✅ | 2 presentaciones por bebida |
| 2.4 Atributos bebida | ✅ | Tipo, endulzante, topping |

#### Combos
| Requisito | Estado | Implementación |
|-----------|--------|----------------|
| 3.1 Combo "Fiesta Patronal" | ✅ | Docena + 2 jarros |
| 3.2 Combo "Madrugada del 24" | ✅ | 3 docenas + 4 jarros + termo |
| 3.3 Combo Estacional editable | ✅ | CRUD completo sin redeploy |

#### Inventario
| Requisito | Estado | Implementación |
|-----------|--------|----------------|
| 4.1 Materias primas | ✅ | 20 items en 7 categorías |
| 4.2 Empaques y combustible | ✅ | Incluidos en materias primas |
| 4.3 Entradas, salidas, mermas | ✅ | Movimientos con tipos E/S/M |
| 4.4 Bloqueo por punto crítico | ⚠️ | Alertas implementadas |

#### Dashboard
| Requisito | Estado | Implementación |
|-----------|--------|----------------|
| 5.1 Ventas diarias y mensuales | ✅ | Totales y conteos |
| 5.2 Tamales más vendidos | ✅ | Top 5 productos |
| 5.3 Bebidas por horario | ✅ | Mañana, tarde, noche |
| 5.4 Proporción picante | ✅ | Gráfico circular |
| 5.5 Utilidades por línea | ✅ | Tamales vs Bebidas |
| 5.6 Desperdicio MP | ✅ | Total de mermas del mes |

#### Integración LLM
| Requisito | Estado | Implementación |
|-----------|--------|----------------|
| 6.1 API OpenRouter | ✅ | Llama 3.2 3B gratuito |
| 6.2 Implementación creativa | ✅ | Chat, sugerencias, análisis |
| 6.3 Voz a texto (extra) | ❌ | No implementado |

#### Funciones Móviles
| Requisito | Estado | Implementación |
|-----------|--------|----------------|
| 9.1 Gestión de sucursales | ✅ | Pantalla dedicada |
| 9.2 Registro de ventas | ✅ | Módulo completo |
| 9.3 Notificaciones push | ❌ | No implementado |

### Resumen de Implementación

| Categoría | Implementado | Pendiente |
|-----------|--------------|-----------|
| Requisitos obligatorios | 95% | Bloqueo punto crítico |
| Requisitos móvil | 66% | Offline, Push notifications |
| Requisitos opcionales | 0% | React Scan, Proveedores, etc. |

---

## Comandos Útiles

### Backend (.NET)

```bash
# Restaurar paquetes
dotnet restore

# Compilar
dotnet build

# Ejecutar
dotnet run

# Ejecutar con hot reload
dotnet watch run

# Crear migración
dotnet ef migrations add NombreMigracion

# Aplicar migraciones
dotnet ef database update

# Ver User Secrets
dotnet user-secrets list
```

### Frontend (React)

```bash
# Instalar dependencias
npm install

# Ejecutar desarrollo
npm run dev

# Compilar para producción
npm run build

# Preview de producción
npm run preview
```

### Mobile (Flutter)

```bash
# Obtener dependencias
flutter pub get

# Ejecutar
flutter run

# Compilar APK
flutter build apk

# Limpiar caché
flutter clean
```

---

## Información Adicional

### Datos de Prueba Incluidos

El sistema incluye datos de prueba realistas:

- **3 sucursales** configuradas
- **30+ ventas** con fechas variadas
- **50+ items de venta** con personalizaciones
- **20 materias primas** con stock inicial
- **40+ movimientos** de inventario (entradas, salidas, mermas)
- **4 combos** activos

### Credenciales y URLs

| Servicio | URL |
|----------|-----|
| API Backend (HTTPS) | https://localhost:7230 |
| API Backend (HTTP) | http://localhost:5222 |
| Swagger UI | https://localhost:7230/swagger |
| Frontend React | http://localhost:5173 |
| OpenRouter Dashboard | https://openrouter.ai/dashboard |

### Obtener API Key de OpenRouter

1. Ir a https://openrouter.ai
2. Crear cuenta (Google/GitHub)
3. Navegar a **Keys** → **Create Key**
4. Copiar la key (formato: `sk-or-v1-xxxxx`)
5. Guardar con User Secrets en el proyecto .NET

---

**Desarrollado para La Cazuela Chapina** 🇬🇹  
**Diciembre 2025**