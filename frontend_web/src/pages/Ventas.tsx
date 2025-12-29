import { useState, useEffect } from 'react';
import { ventaService } from '../services/api';
import { Card, Button, Badge, Spinner, Modal, Input } from '../components/ui';
import { Eye, X, Search, Calendar } from 'lucide-react';
import type { Venta } from '../types';

export default function Ventas() {
  const [ventas, setVentas] = useState<Venta[]>([]);
  const [loading, setLoading] = useState(true);
  const [ventaDetalle, setVentaDetalle] = useState<Venta | null>(null);
  const [filtros, setFiltros] = useState({
    desde: '',
    hasta: '',
  });

  const fetchVentas = async () => {
    try {
      setLoading(true);
      const data = await ventaService.getAll({
        desde: filtros.desde || undefined,
        hasta: filtros.hasta || undefined,
      });
      setVentas(data);
    } catch (error) {
      console.error('Error al cargar ventas:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchVentas();
  }, []);

  const anularVenta = async (id: number) => {
    if (!confirm('¿Estás seguro de anular esta venta?')) return;
    
    try {
      await ventaService.anular(id);
      fetchVentas();
      setVentaDetalle(null);
    } catch (error) {
      console.error('Error al anular venta:', error);
    }
  };

  const formatCurrency = (value: number) =>
    `Q${value.toLocaleString('es-GT', { minimumFractionDigits: 2 })}`;

  const formatDate = (date: string) =>
    new Date(date).toLocaleString('es-GT', {
      dateStyle: 'short',
      timeStyle: 'short',
    });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Historial de Ventas</h1>
          <p className="text-gray-500">Consulta y gestiona las ventas realizadas</p>
        </div>
      </div>

      {/* Filtros */}
      <Card>
        <div className="flex gap-4 items-end">
          <Input
            label="Desde"
            type="date"
            value={filtros.desde}
            onChange={(e) => setFiltros({ ...filtros, desde: e.target.value })}
          />
          <Input
            label="Hasta"
            type="date"
            value={filtros.hasta}
            onChange={(e) => setFiltros({ ...filtros, hasta: e.target.value })}
          />
          <Button onClick={fetchVentas}>
            <Search className="h-4 w-4 mr-2" />
            Buscar
          </Button>
        </div>
      </Card>

      {/* Tabla de ventas */}
      <Card>
        {loading ? (
          <div className="flex justify-center py-12">
            <Spinner size="lg" />
          </div>
        ) : ventas.length === 0 ? (
          <div className="text-center py-12 text-gray-500">
            <Calendar className="h-12 w-12 mx-auto mb-4 opacity-50" />
            <p>No hay ventas para mostrar</p>
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-200">
                  <th className="text-left py-3 px-4 font-medium text-gray-600">Código</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-600">Fecha</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-600">Sucursal</th>
                  <th className="text-right py-3 px-4 font-medium text-gray-600">Total</th>
                  <th className="text-center py-3 px-4 font-medium text-gray-600">Estado</th>
                  <th className="text-center py-3 px-4 font-medium text-gray-600">Acciones</th>
                </tr>
              </thead>
              <tbody>
                {ventas.map((venta) => (
                  <tr key={venta.id} className="border-b border-gray-100 hover:bg-gray-50">
                    <td className="py-3 px-4 font-mono text-sm">{venta.codigo}</td>
                    <td className="py-3 px-4 text-gray-600">{formatDate(venta.fecha)}</td>
                    <td className="py-3 px-4 text-gray-600">{venta.sucursalNombre}</td>
                    <td className="py-3 px-4 text-right font-semibold">
                      {formatCurrency(venta.total)}
                    </td>
                    <td className="py-3 px-4 text-center">
                      <Badge
                        variant={venta.estado === 'COMPLETADA' ? 'success' : 'danger'}
                      >
                        {venta.estado}
                      </Badge>
                    </td>
                    <td className="py-3 px-4 text-center">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => setVentaDetalle(venta)}
                      >
                        <Eye className="h-4 w-4" />
                      </Button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </Card>

      {/* Modal de detalle */}
      <Modal
        isOpen={!!ventaDetalle}
        onClose={() => setVentaDetalle(null)}
        title={`Detalle de Venta ${ventaDetalle?.codigo || ''}`}
        size="lg"
      >
        {ventaDetalle && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4 text-sm">
              <div>
                <span className="text-gray-500">Fecha:</span>
                <p className="font-medium">{formatDate(ventaDetalle.fecha)}</p>
              </div>
              <div>
                <span className="text-gray-500">Sucursal:</span>
                <p className="font-medium">{ventaDetalle.sucursalNombre}</p>
              </div>
              <div>
                <span className="text-gray-500">Estado:</span>
                <p>
                  <Badge
                    variant={ventaDetalle.estado === 'COMPLETADA' ? 'success' : 'danger'}
                  >
                    {ventaDetalle.estado}
                  </Badge>
                </p>
              </div>
            </div>

            <div className="border-t border-gray-200 pt-4">
              <h4 className="font-medium mb-3">Productos</h4>
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="text-left py-2">Producto</th>
                    <th className="text-center py-2">Cant.</th>
                    <th className="text-right py-2">Precio</th>
                    <th className="text-right py-2">Subtotal</th>
                  </tr>
                </thead>
                <tbody>
                  {ventaDetalle.items.map((item) => (
                    <tr key={item.id} className="border-b border-gray-100">
                      <td className="py-2">
                        <p className="font-medium">{item.descripcion}</p>
                        {item.personalizacion && (
                          <p className="text-xs text-gray-500">
                            {Object.values(item.personalizacion)
                              .map((p) => p.nombre)
                              .join(', ')}
                          </p>
                        )}
                      </td>
                      <td className="py-2 text-center">{item.cantidad}</td>
                      <td className="py-2 text-right">
                        {formatCurrency(item.precioUnitario + item.precioExtras)}
                      </td>
                      <td className="py-2 text-right font-medium">
                        {formatCurrency(item.subtotal)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            <div className="border-t border-gray-200 pt-4 space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">Subtotal</span>
                <span>{formatCurrency(ventaDetalle.subtotal)}</span>
              </div>
              {ventaDetalle.descuento > 0 && (
                <div className="flex justify-between text-sm">
                  <span className="text-gray-500">Descuento</span>
                  <span className="text-red-500">-{formatCurrency(ventaDetalle.descuento)}</span>
                </div>
              )}
              <div className="flex justify-between text-lg font-bold">
                <span>Total</span>
                <span className="text-amber-600">{formatCurrency(ventaDetalle.total)}</span>
              </div>
            </div>

            {ventaDetalle.estado === 'COMPLETADA' && (
              <div className="flex justify-end pt-4 border-t border-gray-200">
                <Button
                  variant="danger"
                  onClick={() => anularVenta(ventaDetalle.id)}
                >
                  <X className="h-4 w-4 mr-2" />
                  Anular Venta
                </Button>
              </div>
            )}
          </div>
        )}
      </Modal>
    </div>
  );
}
