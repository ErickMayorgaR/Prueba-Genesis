import { useState } from 'react';
import { useCatalogo, useSucursales } from '../hooks/useData';
import { useCart } from '../context/CartContext';
import { ventaService } from '../services/api';
import { Card, Button, Select, Modal, Spinner, Badge } from '../components/ui';
import { ShoppingCart, Plus, Minus, Trash2, X } from 'lucide-react';
import toast from 'react-hot-toast';
import type { Categoria, Presentacion, Atributo, Combo, ItemCarrito } from '../types';

export default function PuntoVenta() {
  const { catalogo, loading: loadingCatalogo } = useCatalogo();
  const { sucursales } = useSucursales();
  const {
    items,
    sucursalId,
    setSucursalId,
    addItem,
    removeItem,
    updateQuantity,
    clearCart,
    getTotal,
    getSubtotal,
    descuento,
    setDescuento,
    toCrearVenta,
  } = useCart();

  const [categoriaActiva, setCategoriaActiva] = useState<number | null>(null);
  const [modalProducto, setModalProducto] = useState<{
    isOpen: boolean;
    categoria: Categoria | null;
    presentacion: Presentacion | null;
  }>({ isOpen: false, categoria: null, presentacion: null });
  const [personalizacion, setPersonalizacion] = useState<Record<string, number>>({});
  const [cantidad, setCantidad] = useState(1);
  const [procesando, setProcesando] = useState(false);

  if (loadingCatalogo) {
    return (
      <div className="flex items-center justify-center h-96">
        <Spinner size="lg" />
      </div>
    );
  }

  if (!catalogo) {
    return (
      <div className="text-center py-12">
        <p className="text-red-500">Error al cargar el catálogo</p>
      </div>
    );
  }

  const categoriaSeleccionada = catalogo.categorias.find((c) => c.id === categoriaActiva);

  const abrirModalProducto = (categoria: Categoria, presentacion: Presentacion) => {
    setModalProducto({ isOpen: true, categoria, presentacion });
    setPersonalizacion({});
    setCantidad(1);

    // Establecer valores por defecto
    categoria.atributos.forEach((attr) => {
      if (attr.opciones.length > 0 && !attr.esMultiple) {
        setPersonalizacion((prev) => ({
          ...prev,
          [attr.codigo]: attr.opciones[0].id,
        }));
      }
    });
  };

  const calcularPrecioExtras = () => {
    if (!modalProducto.categoria) return 0;
    let extras = 0;
    modalProducto.categoria.atributos.forEach((attr) => {
      const opcionId = personalizacion[attr.codigo];
      if (opcionId) {
        const opcion = attr.opciones.find((o) => o.id === opcionId);
        if (opcion) extras += opcion.precioExtra;
      }
    });
    return extras;
  };

  const agregarAlCarrito = () => {
    if (!modalProducto.presentacion || !modalProducto.categoria) return;

    const precioExtras = calcularPrecioExtras();
    const precioUnitario = modalProducto.presentacion.precio;

    // Construir descripción de personalización
    const personalizacionDetalle: Record<string, { nombre: string; precioExtra: number }> = {};
    modalProducto.categoria.atributos.forEach((attr) => {
      const opcionId = personalizacion[attr.codigo];
      if (opcionId) {
        const opcion = attr.opciones.find((o) => o.id === opcionId);
        if (opcion) {
          personalizacionDetalle[attr.codigo] = {
            nombre: opcion.nombre,
            precioExtra: opcion.precioExtra,
          };
        }
      }
    });

    const descripcion = Object.values(personalizacionDetalle)
      .map((p) => p.nombre)
      .join(', ');

    const item: ItemCarrito = {
      id: '',
      tipo: 'producto',
      presentacionId: modalProducto.presentacion.id,
      nombre: `${modalProducto.categoria.productos[0].nombre} - ${modalProducto.presentacion.nombre}`,
      descripcion: descripcion || 'Sin personalización',
      cantidad,
      precioUnitario,
      precioExtras,
      subtotal: (precioUnitario + precioExtras) * cantidad,
      personalizacion,
      personalizacionDetalle,
    };

    addItem(item);
    setModalProducto({ isOpen: false, categoria: null, presentacion: null });
    toast.success('Producto agregado al carrito');
  };

  const agregarCombo = (combo: Combo) => {
    const item: ItemCarrito = {
      id: '',
      tipo: 'combo',
      comboId: combo.id,
      nombre: combo.nombre,
      descripcion: combo.descripcion || '',
      cantidad: 1,
      precioUnitario: combo.precio,
      precioExtras: 0,
      subtotal: combo.precio,
    };

    addItem(item);
    toast.success('Combo agregado al carrito');
  };

  const procesarVenta = async () => {
    if (items.length === 0) {
      toast.error('El carrito está vacío');
      return;
    }

    try {
      setProcesando(true);
      const ventaData = toCrearVenta();
      const venta = await ventaService.create(ventaData);
      
      toast.success(`Venta ${venta.codigo} registrada exitosamente`);
      clearCart();
    } catch (error) {
      console.error(error);
      toast.error('Error al procesar la venta');
    } finally {
      setProcesando(false);
    }
  };

  const formatCurrency = (value: number) =>
    `Q${value.toLocaleString('es-GT', { minimumFractionDigits: 2 })}`;

  return (
    <div className="flex gap-6 h-[calc(100vh-140px)]">
      {/* Panel izquierdo - Catálogo */}
      <div className="flex-1 flex flex-col overflow-hidden">
        <div className="mb-4">
          <h1 className="text-2xl font-bold text-gray-900">Punto de Venta</h1>
          <p className="text-gray-500">Selecciona los productos para la venta</p>
        </div>

        {/* Categorías */}
        <div className="flex gap-2 mb-4 overflow-x-auto pb-2">
          {catalogo.categorias.map((categoria) => (
            <button
              key={categoria.id}
              onClick={() => setCategoriaActiva(categoria.id)}
              className={`px-4 py-2 rounded-lg whitespace-nowrap transition-colors ${
                categoriaActiva === categoria.id
                  ? 'bg-amber-600 text-white'
                  : 'bg-white text-gray-700 hover:bg-gray-100 border border-gray-200'
              }`}
            >
              {categoria.icono} {categoria.nombre}
            </button>
          ))}
          <button
            onClick={() => setCategoriaActiva(null)}
            className={`px-4 py-2 rounded-lg whitespace-nowrap transition-colors ${
              categoriaActiva === null
                ? 'bg-amber-600 text-white'
                : 'bg-white text-gray-700 hover:bg-gray-100 border border-gray-200'
            }`}
          >
            🎁 Combos
          </button>
        </div>

        {/* Productos/Combos Grid */}
        <div className="flex-1 overflow-y-auto">
          {categoriaActiva === null ? (
            // Mostrar Combos
            <div className="grid grid-cols-2 lg:grid-cols-3 gap-4">
              {catalogo.combos.map((combo) => (
                <div
                  key={combo.id}
                  onClick={() => agregarCombo(combo)}
                  className="bg-white rounded-xl border border-gray-200 p-4 cursor-pointer hover:shadow-lg hover:border-amber-300 transition-all"
                >
                  <div className="text-3xl mb-2">🎁</div>
                  <h3 className="font-semibold text-gray-900">{combo.nombre}</h3>
                  <p className="text-sm text-gray-500 mt-1 line-clamp-2">{combo.descripcion}</p>
                  <div className="mt-3 flex items-center justify-between">
                    <span className="text-lg font-bold text-amber-600">
                      {formatCurrency(combo.precio)}
                    </span>
                    {combo.tipo === 'ESTACIONAL' && (
                      <Badge variant="info">Estacional</Badge>
                    )}
                  </div>
                </div>
              ))}
            </div>
          ) : (
            // Mostrar Presentaciones de la categoría
            <div className="grid grid-cols-2 lg:grid-cols-3 gap-4">
              {categoriaSeleccionada?.productos.map((producto) =>
                producto.presentaciones.map((presentacion) => (
                  <div
                    key={presentacion.id}
                    onClick={() =>
                      abrirModalProducto(categoriaSeleccionada, presentacion)
                    }
                    className="bg-white rounded-xl border border-gray-200 p-4 cursor-pointer hover:shadow-lg hover:border-amber-300 transition-all"
                  >
                    <div className="text-3xl mb-2">{categoriaSeleccionada.icono}</div>
                    <h3 className="font-semibold text-gray-900">{producto.nombre}</h3>
                    <p className="text-sm text-gray-500">{presentacion.nombre}</p>
                    {presentacion.cantidad > 1 && (
                      <p className="text-xs text-gray-400">({presentacion.cantidad} unidades)</p>
                    )}
                    <p className="text-lg font-bold text-amber-600 mt-2">
                      {formatCurrency(presentacion.precio)}
                    </p>
                  </div>
                ))
              )}
            </div>
          )}
        </div>
      </div>

      {/* Panel derecho - Carrito */}
      <div className="w-96 bg-white rounded-xl border border-gray-200 flex flex-col">
        {/* Header del carrito */}
        <div className="p-4 border-b border-gray-200">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <ShoppingCart className="h-5 w-5 text-amber-600" />
              <span className="font-semibold">Carrito</span>
              <Badge>{items.length}</Badge>
            </div>
            {items.length > 0 && (
              <button
                onClick={clearCart}
                className="text-red-500 hover:text-red-700 text-sm"
              >
                Vaciar
              </button>
            )}
          </div>
          
          {/* Sucursal */}
          <div className="mt-3">
            <Select
              label="Sucursal"
              value={sucursalId}
              onChange={(v) => setSucursalId(Number(v))}
              options={sucursales.map((s) => ({ value: s.id, label: s.nombre }))}
            />
          </div>
        </div>

        {/* Items del carrito */}
        <div className="flex-1 overflow-y-auto p-4 space-y-3">
          {items.length === 0 ? (
            <div className="text-center py-8 text-gray-400">
              <ShoppingCart className="h-12 w-12 mx-auto mb-2 opacity-50" />
              <p>Carrito vacío</p>
            </div>
          ) : (
            items.map((item) => (
              <div
                key={item.id}
                className="bg-gray-50 rounded-lg p-3 space-y-2"
              >
                <div className="flex justify-between items-start">
                  <div className="flex-1">
                    <p className="font-medium text-gray-900 text-sm">{item.nombre}</p>
                    <p className="text-xs text-gray-500">{item.descripcion}</p>
                  </div>
                  <button
                    onClick={() => removeItem(item.id)}
                    className="text-gray-400 hover:text-red-500 p-1"
                  >
                    <X className="h-4 w-4" />
                  </button>
                </div>
                
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => updateQuantity(item.id, item.cantidad - 1)}
                      className="p-1 rounded bg-gray-200 hover:bg-gray-300"
                    >
                      <Minus className="h-3 w-3" />
                    </button>
                    <span className="w-8 text-center font-medium">{item.cantidad}</span>
                    <button
                      onClick={() => updateQuantity(item.id, item.cantidad + 1)}
                      className="p-1 rounded bg-gray-200 hover:bg-gray-300"
                    >
                      <Plus className="h-3 w-3" />
                    </button>
                  </div>
                  <span className="font-semibold text-amber-600">
                    {formatCurrency(item.subtotal)}
                  </span>
                </div>
              </div>
            ))
          )}
        </div>

        {/* Totales y botón de pago */}
        <div className="border-t border-gray-200 p-4 space-y-3">
          <div className="flex justify-between text-sm">
            <span className="text-gray-500">Subtotal</span>
            <span>{formatCurrency(getSubtotal())}</span>
          </div>
          <div className="flex justify-between text-sm">
            <span className="text-gray-500">Descuento</span>
            <input
              type="number"
              value={descuento}
              onChange={(e) => setDescuento(Number(e.target.value))}
              className="w-20 text-right border border-gray-300 rounded px-2 py-1 text-sm"
              min="0"
            />
          </div>
          <div className="flex justify-between text-lg font-bold border-t border-gray-200 pt-3">
            <span>Total</span>
            <span className="text-amber-600">{formatCurrency(getTotal())}</span>
          </div>
          
          <Button
            onClick={procesarVenta}
            loading={procesando}
            disabled={items.length === 0}
            className="w-full"
            size="lg"
          >
            Procesar Venta
          </Button>
        </div>
      </div>

      {/* Modal de Personalización */}
      <Modal
        isOpen={modalProducto.isOpen}
        onClose={() => setModalProducto({ isOpen: false, categoria: null, presentacion: null })}
        title="Personalizar Producto"
        size="md"
      >
        {modalProducto.categoria && modalProducto.presentacion && (
          <div className="space-y-4">
            <div className="text-center pb-4 border-b border-gray-200">
              <span className="text-4xl">{modalProducto.categoria.icono}</span>
              <h3 className="font-semibold text-lg mt-2">
                {modalProducto.categoria.productos[0].nombre}
              </h3>
              <p className="text-gray-500">{modalProducto.presentacion.nombre}</p>
            </div>

            {/* Atributos */}
            {modalProducto.categoria.atributos.map((atributo) => (
              <div key={atributo.id}>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  {atributo.nombre}
                  {atributo.esRequerido && <span className="text-red-500">*</span>}
                </label>
                <div className="grid grid-cols-2 gap-2">
                  {atributo.opciones.map((opcion) => (
                    <button
                      key={opcion.id}
                      onClick={() =>
                        setPersonalizacion((prev) => ({
                          ...prev,
                          [atributo.codigo]: opcion.id,
                        }))
                      }
                      className={`p-3 rounded-lg border text-left transition-colors ${
                        personalizacion[atributo.codigo] === opcion.id
                          ? 'border-amber-500 bg-amber-50 text-amber-700'
                          : 'border-gray-200 hover:border-gray-300'
                      }`}
                    >
                      <span className="font-medium text-sm">{opcion.nombre}</span>
                      {opcion.precioExtra > 0 && (
                        <span className="block text-xs text-gray-500">
                          +{formatCurrency(opcion.precioExtra)}
                        </span>
                      )}
                    </button>
                  ))}
                </div>
              </div>
            ))}

            {/* Cantidad */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Cantidad
              </label>
              <div className="flex items-center gap-4">
                <button
                  onClick={() => setCantidad(Math.max(1, cantidad - 1))}
                  className="p-2 rounded-lg bg-gray-100 hover:bg-gray-200"
                >
                  <Minus className="h-5 w-5" />
                </button>
                <span className="text-xl font-bold w-12 text-center">{cantidad}</span>
                <button
                  onClick={() => setCantidad(cantidad + 1)}
                  className="p-2 rounded-lg bg-gray-100 hover:bg-gray-200"
                >
                  <Plus className="h-5 w-5" />
                </button>
              </div>
            </div>

            {/* Precio total */}
            <div className="bg-gray-50 rounded-lg p-4">
              <div className="flex justify-between text-sm text-gray-500">
                <span>Precio base</span>
                <span>{formatCurrency(modalProducto.presentacion.precio)}</span>
              </div>
              {calcularPrecioExtras() > 0 && (
                <div className="flex justify-between text-sm text-gray-500">
                  <span>Extras</span>
                  <span>+{formatCurrency(calcularPrecioExtras())}</span>
                </div>
              )}
              <div className="flex justify-between text-lg font-bold mt-2 pt-2 border-t border-gray-200">
                <span>Total</span>
                <span className="text-amber-600">
                  {formatCurrency(
                    (modalProducto.presentacion.precio + calcularPrecioExtras()) * cantidad
                  )}
                </span>
              </div>
            </div>

            {/* Botón agregar */}
            <Button onClick={agregarAlCarrito} className="w-full" size="lg">
              Agregar al Carrito
            </Button>
          </div>
        )}
      </Modal>
    </div>
  );
}
