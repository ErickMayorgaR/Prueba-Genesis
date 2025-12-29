import axios from 'axios';
import type {
  CatalogoCompleto,
  Combo,
  CrearCombo,
  MateriaPrima,
  CrearMateriaPrima,
  Movimiento,
  CrearMovimiento,
  Venta,
  CrearVenta,
  Sucursal,
  CrearSucursal,
  Dashboard,
  LLMRequest,
  LLMResponse,
  InventarioAlerta,
} from '../types';

// Configuración base de Axios
const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'https://localhost:7001/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor para manejar errores
api.interceptors.response.use(
  (response) => response,
  (error) => {
    console.error('API Error:', error.response?.data || error.message);
    return Promise.reject(error);
  }
);

// ==========================================
// CATÁLOGO
// ==========================================

export const catalogoService = {
  getCatalogo: async (): Promise<CatalogoCompleto> => {
    const response = await api.get<CatalogoCompleto>('/catalogo');
    return response.data;
  },

  getCategoria: async (id: number) => {
    const response = await api.get(`/catalogo/categorias/${id}`);
    return response.data;
  },

  getAtributos: async (categoriaId: number) => {
    const response = await api.get(`/catalogo/categorias/${categoriaId}/atributos`);
    return response.data;
  },
};

// ==========================================
// COMBOS
// ==========================================

export const comboService = {
  getAll: async (): Promise<Combo[]> => {
    const response = await api.get<Combo[]>('/combos');
    return response.data;
  },

  getById: async (id: number): Promise<Combo> => {
    const response = await api.get<Combo>(`/combos/${id}`);
    return response.data;
  },

  create: async (combo: CrearCombo): Promise<Combo> => {
    const response = await api.post<Combo>('/combos', combo);
    return response.data;
  },

  update: async (id: number, combo: CrearCombo): Promise<Combo> => {
    const response = await api.put<Combo>(`/combos/${id}`, combo);
    return response.data;
  },

  delete: async (id: number): Promise<void> => {
    await api.delete(`/combos/${id}`);
  },
};

// ==========================================
// INVENTARIO
// ==========================================

export const inventarioService = {
  getMaterias: async (): Promise<MateriaPrima[]> => {
    const response = await api.get<MateriaPrima[]>('/inventario/materias');
    return response.data;
  },

  getMateriaById: async (id: number): Promise<MateriaPrima> => {
    const response = await api.get<MateriaPrima>(`/inventario/materias/${id}`);
    return response.data;
  },

  createMateria: async (materia: CrearMateriaPrima): Promise<MateriaPrima> => {
    const response = await api.post<MateriaPrima>('/inventario/materias', materia);
    return response.data;
  },

  updateMateria: async (id: number, materia: CrearMateriaPrima): Promise<MateriaPrima> => {
    const response = await api.put<MateriaPrima>(`/inventario/materias/${id}`, materia);
    return response.data;
  },

  getMovimientos: async (params?: {
    materiaPrimaId?: number;
    desde?: string;
    hasta?: string;
  }): Promise<Movimiento[]> => {
    const response = await api.get<Movimiento[]>('/inventario/movimientos', { params });
    return response.data;
  },

  registrarMovimiento: async (movimiento: CrearMovimiento): Promise<Movimiento> => {
    const response = await api.post<Movimiento>('/inventario/movimientos', movimiento);
    return response.data;
  },

  getAlertas: async (): Promise<InventarioAlerta[]> => {
    const response = await api.get<InventarioAlerta[]>('/inventario/alertas');
    return response.data;
  },
};

// ==========================================
// VENTAS
// ==========================================

export const ventaService = {
  getAll: async (params?: {
    sucursalId?: number;
    desde?: string;
    hasta?: string;
  }): Promise<Venta[]> => {
    const response = await api.get<Venta[]>('/ventas', { params });
    return response.data;
  },

  getById: async (id: number): Promise<Venta> => {
    const response = await api.get<Venta>(`/ventas/${id}`);
    return response.data;
  },

  create: async (venta: CrearVenta): Promise<Venta> => {
    const response = await api.post<Venta>('/ventas', venta);
    return response.data;
  },

  anular: async (id: number): Promise<void> => {
    await api.put(`/ventas/${id}/anular`);
  },
};

// ==========================================
// SUCURSALES
// ==========================================

export const sucursalService = {
  getAll: async (): Promise<Sucursal[]> => {
    const response = await api.get<Sucursal[]>('/sucursales');
    return response.data;
  },

  getById: async (id: number): Promise<Sucursal> => {
    const response = await api.get<Sucursal>(`/sucursales/${id}`);
    return response.data;
  },

  create: async (sucursal: CrearSucursal): Promise<Sucursal> => {
    const response = await api.post<Sucursal>('/sucursales', sucursal);
    return response.data;
  },

  update: async (id: number, sucursal: CrearSucursal): Promise<Sucursal> => {
    const response = await api.put<Sucursal>(`/sucursales/${id}`, sucursal);
    return response.data;
  },

  delete: async (id: number): Promise<void> => {
    await api.delete(`/sucursales/${id}`);
  },
};

// ==========================================
// DASHBOARD
// ==========================================

export const dashboardService = {
  getDashboard: async (sucursalId?: number): Promise<Dashboard> => {
    const response = await api.get<Dashboard>('/dashboard', {
      params: sucursalId ? { sucursalId } : undefined,
    });
    return response.data;
  },
};

// ==========================================
// LLM (OpenRouter)
// ==========================================

export const llmService = {
  chat: async (request: LLMRequest): Promise<LLMResponse> => {
    const response = await api.post<LLMResponse>('/llm/chat', request);
    return response.data;
  },

  sugerirCombo: async (descripcion: string): Promise<LLMResponse> => {
    const response = await api.post<LLMResponse>('/llm/sugerir-combo', JSON.stringify(descripcion));
    return response.data;
  },

  analizarVentas: async (sucursalId?: number): Promise<LLMResponse> => {
    const response = await api.get<LLMResponse>('/llm/analizar-ventas', {
      params: sucursalId ? { sucursalId } : undefined,
    });
    return response.data;
  },
};

export default api;
