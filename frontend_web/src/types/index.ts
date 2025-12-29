// ==========================================
// CATÁLOGO TYPES
// ==========================================

export interface CatalogoCompleto {
  categorias: Categoria[];
  combos: Combo[];
}

export interface Categoria {
  id: number;
  nombre: string;
  descripcion?: string;
  icono?: string;
  productos: Producto[];
  atributos: Atributo[];
}

export interface Producto {
  id: number;
  codigo?: string;
  nombre: string;
  descripcion?: string;
  imagenUrl?: string;
  presentaciones: Presentacion[];
}

export interface Presentacion {
  id: number;
  nombre: string;
  cantidad: number;
  precio: number;
}

export interface Atributo {
  id: number;
  nombre: string;
  codigo: string;
  esMultiple: boolean;
  esRequerido: boolean;
  opciones: Opcion[];
}

export interface Opcion {
  id: number;
  nombre: string;
  codigo: string;
  precioExtra: number;
}

// ==========================================
// COMBO TYPES
// ==========================================

export interface Combo {
  id: number;
  nombre: string;
  descripcion?: string;
  precio: number;
  tipo: string;
  fechaInicio?: string;
  fechaFin?: string;
  items: ComboItem[];
}

export interface ComboItem {
  id: number;
  presentacionId: number;
  presentacionNombre: string;
  productoNombre: string;
  cantidad: number;
  notas?: string;
}

export interface CrearCombo {
  nombre: string;
  descripcion?: string;
  precio: number;
  tipo: string;
  fechaInicio?: string;
  fechaFin?: string;
  items: CrearComboItem[];
}

export interface CrearComboItem {
  presentacionId: number;
  cantidad: number;
  notas?: string;
}

// ==========================================
// INVENTARIO TYPES
// ==========================================

export interface MateriaPrima {
  id: number;
  categoria: string;
  nombre: string;
  unidadMedida: string;
  stockActual: number;
  stockMinimo: number;
  puntoCritico: number;
  costoPromedio: number;
  enPuntoCritico: boolean;
  bajoMinimo: boolean;
}

export interface CrearMateriaPrima {
  categoria: string;
  nombre: string;
  unidadMedida: string;
  stockMinimo: number;
  puntoCritico: number;
}

export interface Movimiento {
  id: number;
  materiaPrimaId: number;
  materiaPrimaNombre: string;
  tipo: string;
  tipoDescripcion: string;
  cantidad: number;
  costoUnitario?: number;
  motivo?: string;
  fecha: string;
}

export interface CrearMovimiento {
  materiaPrimaId: number;
  tipo: string; // E, S, M
  cantidad: number;
  costoUnitario?: number;
  motivo?: string;
}

// ==========================================
// VENTA TYPES
// ==========================================

export interface Venta {
  id: number;
  codigo?: string;
  sucursalId: number;
  sucursalNombre: string;
  fecha: string;
  subtotal: number;
  descuento: number;
  total: number;
  estado: string;
  items: VentaItem[];
}

export interface VentaItem {
  id: number;
  tipoItem: string;
  presentacionId?: number;
  comboId?: number;
  descripcion: string;
  cantidad: number;
  precioUnitario: number;
  precioExtras: number;
  subtotal: number;
  personalizacion?: Record<string, PersonalizacionItem>;
}

export interface PersonalizacionItem {
  opcionId: number;
  nombre: string;
  precioExtra: number;
}

export interface CrearVenta {
  sucursalId: number;
  descuento: number;
  items: CrearVentaItem[];
}

export interface CrearVentaItem {
  presentacionId?: number;
  comboId?: number;
  cantidad: number;
  personalizacion?: Record<string, number>;
}

// ==========================================
// SUCURSAL TYPES
// ==========================================

export interface Sucursal {
  id: number;
  nombre: string;
  direccion?: string;
  telefono?: string;
  activo: boolean;
}

export interface CrearSucursal {
  nombre: string;
  direccion?: string;
  telefono?: string;
}

// ==========================================
// DASHBOARD TYPES
// ==========================================

export interface Dashboard {
  ventasHoy: number;
  ventasMes: number;
  totalVentasHoy: number;
  totalVentasMes: number;
  productosMasVendidos: ProductoVendido[];
  bebidasPorHorario: BebidaPorHorario[];
  proporcionPicante: ProporcionPicante;
  utilidadesPorLinea: UtilidadLinea[];
  alertasInventario: InventarioAlerta[];
  desperdicioMes: number;
}

export interface ProductoVendido {
  producto: string;
  presentacion: string;
  cantidadVendida: number;
  totalVendido: number;
}

export interface BebidaPorHorario {
  horario: string;
  bebida: string;
  cantidad: number;
}

export interface ProporcionPicante {
  conPicante: number;
  sinPicante: number;
  porcentajeConPicante: number;
}

export interface UtilidadLinea {
  linea: string;
  ventas: number;
  costo: number;
  utilidad: number;
  margenPorcentaje: number;
}

export interface InventarioAlerta {
  id: number;
  nombre: string;
  categoria: string;
  stockActual: number;
  puntoCritico: number;
  nivel: string;
}

// ==========================================
// LLM TYPES
// ==========================================

export interface LLMRequest {
  mensaje: string;
  contexto?: string;
}

export interface LLMResponse {
  respuesta: string;
  exito: boolean;
  error?: string;
}

// ==========================================
// CARRITO (Frontend only)
// ==========================================

export interface ItemCarrito {
  id: string; // UUID temporal
  tipo: 'producto' | 'combo';
  presentacionId?: number;
  comboId?: number;
  nombre: string;
  descripcion: string;
  cantidad: number;
  precioUnitario: number;
  precioExtras: number;
  subtotal: number;
  personalizacion?: Record<string, number>;
  personalizacionDetalle?: Record<string, { nombre: string; precioExtra: number }>;
}
