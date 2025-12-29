import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../models/models.dart';

class ApiService {
  // Cambiar según el entorno:
  // Android Emulator: 10.0.2.2
  // iOS Simulator: localhost
  // Dispositivo físico: IP de tu PC (ej: 192.168.1.100)
  static const String baseUrl = 'https://10.0.2.2:7230/api';  // ← HTTPS con puerto correcto

  late http.Client _client;

  ApiService() {
    // Cliente que ignora certificados self-signed (SOLO para desarrollo)
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    _client = IOClient(httpClient);
  }

  // ==================== DASHBOARD ====================
  Future<Dashboard> getDashboard() async {
    print('🔵 Llamando: $baseUrl/dashboard');
    try {
      final response = await _client.get(Uri.parse('$baseUrl/dashboard'));
      print('🟢 Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return Dashboard.fromJson(json.decode(response.body));
      }
      throw Exception('Error: ${response.statusCode}');
    } catch (e) {
      print('🔴 Error Dashboard: $e');
      rethrow;
    }
  }

  // ==================== CATÁLOGO ====================
  Future<CatalogoCompleto> getCatalogo() async {
    print('🔵 Llamando: $baseUrl/catalogo');
    try {
      final response = await _client.get(Uri.parse('$baseUrl/catalogo'));
      print('🟢 Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        return CatalogoCompleto.fromJson(json.decode(response.body));
      }
      throw Exception('Error: ${response.statusCode}');
    } catch (e) {
      print('🔴 Error Catalogo: $e');
      rethrow;
    }
  }

  Future<List<Atributo>> getAtributos(int categoriaId) async {
    final response = await _client.get(Uri.parse('$baseUrl/catalogo/categoria/$categoriaId/atributos'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Atributo.fromJson(e)).toList();
    }
    throw Exception('Error al cargar atributos');
  }

  // ==================== COMBOS ====================
  Future<List<Combo>> getCombos() async {
    final response = await _client.get(Uri.parse('$baseUrl/combos'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Combo.fromJson(e)).toList();
    }
    throw Exception('Error al cargar combos');
  }

  Future<Combo> getCombo(int id) async {
    final response = await _client.get(Uri.parse('$baseUrl/combos/$id'));
    if (response.statusCode == 200) {
      return Combo.fromJson(json.decode(response.body));
    }
    throw Exception('Error al cargar combo');
  }

  Future<Combo> createCombo(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/combos'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Combo.fromJson(json.decode(response.body));
    }
    throw Exception('Error al crear combo');
  }

  Future<void> deleteCombo(int id) async {
    final response = await _client.delete(Uri.parse('$baseUrl/combos/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar combo');
    }
  }

  // ==================== INVENTARIO ====================
  Future<List<MateriaPrima>> getMateriasPrimas() async {
    final response = await _client.get(Uri.parse('$baseUrl/inventario/materias'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => MateriaPrima.fromJson(e)).toList();
    }
    throw Exception('Error al cargar materias primas');
  }

  Future<List<Movimiento>> getMovimientos({DateTime? desde, DateTime? hasta}) async {
    String url = '$baseUrl/inventario/movimientos';
    List<String> params = [];
    if (desde != null) params.add('desde=${desde.toIso8601String()}');
    if (hasta != null) params.add('hasta=${hasta.toIso8601String()}');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Movimiento.fromJson(e)).toList();
    }
    throw Exception('Error al cargar movimientos');
  }

  Future<Movimiento> registrarMovimiento(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/inventario/movimientos'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Movimiento.fromJson(json.decode(response.body));
    }
    throw Exception('Error al registrar movimiento');
  }

  // ==================== VENTAS ====================
  Future<List<Venta>> getVentas({DateTime? desde, DateTime? hasta}) async {
    String url = '$baseUrl/ventas';
    List<String> params = [];
    if (desde != null) params.add('desde=${desde.toIso8601String()}');
    if (hasta != null) params.add('hasta=${hasta.toIso8601String()}');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    final response = await _client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Venta.fromJson(e)).toList();
    }
    throw Exception('Error al cargar ventas');
  }

  Future<Venta> getVenta(int id) async {
    final response = await _client.get(Uri.parse('$baseUrl/ventas/$id'));
    if (response.statusCode == 200) {
      return Venta.fromJson(json.decode(response.body));
    }
    throw Exception('Error al cargar venta');
  }

  Future<Venta> crearVenta(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/ventas'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Venta.fromJson(json.decode(response.body));
    }
    throw Exception('Error al crear venta: ${response.body}');
  }

  Future<void> anularVenta(int id) async {
    final response = await _client.put(Uri.parse('$baseUrl/ventas/$id/anular'));
    if (response.statusCode != 200) {
      throw Exception('Error al anular venta');
    }
  }

  // ==================== SUCURSALES ====================
  Future<List<Sucursal>> getSucursales() async {
    final response = await _client.get(Uri.parse('$baseUrl/sucursales'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Sucursal.fromJson(e)).toList();
    }
    throw Exception('Error al cargar sucursales');
  }

  Future<Sucursal> createSucursal(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/sucursales'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Sucursal.fromJson(json.decode(response.body));
    }
    throw Exception('Error al crear sucursal');
  }

  Future<void> deleteSucursal(int id) async {
    final response = await _client.delete(Uri.parse('$baseUrl/sucursales/$id'));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar sucursal');
    }
  }

  // ==================== LLM ====================
  Future<String> chat(String mensaje) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/llm/chat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'mensaje': mensaje}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['respuesta'] ?? '';
    }
    throw Exception('Error al comunicarse con el asistente');
  }
}