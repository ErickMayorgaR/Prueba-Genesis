import { useState, useEffect } from 'react';
import { useInventario } from '../hooks/useData';
import { inventarioService } from '../services/api';
import { Card, Button, Badge, Spinner, Modal, Input, Select } from '../components/ui';
import { Plus, Package, ArrowUpCircle, ArrowDownCircle, AlertTriangle } from 'lucide-react';
import toast from 'react-hot-toast';
import type { MateriaPrima, Movimiento, CrearMovimiento } from '../types';

export default function Inventario() {
  const { materias, loading, refetch } = useInventario();
  const [movimientos, setMovimientos] = useState<Movimiento[]>([]);
  const [loadingMovimientos, setLoadingMovimientos] = useState(false);
  const [tab, setTab] = useState<'materias' | 'movimientos'>('materias');
  
  // Modal de movimiento
  const [modalMovimiento, setModalMovimiento] = useState(false);
  const [nuevoMovimiento, setNuevoMovimiento] = useState<CrearMovimiento>({
    materiaPrimaId: 0,
    tipo: 'E',
    cantidad: 0,
    costoUnitario: undefined,
    motivo: '',
  });
  const [procesando, setProcesando] = useState(false);

  const fetchMovimientos = async () => {
    try {
      setLoadingMovimientos(true);
      const data = await inventarioService.getMovimientos();
      setMovimientos(data);
    } catch (error) {
      console.error('Error al cargar movimientos:', error);
    } finally {
      setLoadingMovimientos(false);
    }
  };

  useEffect(() => {
    if (tab === 'movimientos') {
      fetchMovimientos();
    }
  }, [tab]);

  const registrarMovimiento = async () => {
    if (!nuevoMovimiento.materiaPrimaId || nuevoMovimiento.cantidad <= 0) {
      toast.error('Completa todos los campos requeridos');
      return;
    }

    try {
      setProcesando(true);
      await inventarioService.registrarMovimiento(nuevoMovimiento);
      toast.success('Movimiento registrado correctamente');
      setModalMovimiento(false);
      setNuevoMovimiento({
        materiaPrimaId: 0,
        tipo: 'E',
        cantidad: 0,
        costoUnitario: undefined,
        motivo: '',
      });
      refetch();
      if (tab === 'movimientos') fetchMovimientos();
    } catch (error: any) {
      toast.error(error.response?.data?.mensaje || 'Error al registrar movimiento');
    } finally {
      setProcesando(false);
    }
  };

  const formatCurrency = (value: number) =>
    `Q${value.toLocaleString('es-GT', { minimumFractionDigits: 2 })}`;

  const formatDate = (date: string) =>
    new Date(date).toLocaleString('es-GT', {
      dateStyle: 'short',
      timeStyle: 'short',
    });

  // Agrupar materias por categoría
  const materiasPorCategoria = materias.reduce((acc, materia) => {
    if (!acc[materia.categoria]) {
      acc[materia.categoria] = [];
    }
    acc[materia.categoria].push(materia);
    return acc;
  }, {} as Record<string, MateriaPrima[]>);

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Inventario</h1>
          <p className="text-gray-500">Gestión de materias primas y movimientos</p>
        </div>
        <Button onClick={() => setModalMovimiento(true)}>
          <Plus className="h-4 w-4 mr-2" />
          Registrar Movimiento
        </Button>
      </div>

      {/* Tabs */}
      <div className="flex gap-2 border-b border-gray-200">
        <button
          onClick={() => setTab('materias')}
          className={`px-4 py-2 font-medium border-b-2 transition-colors ${
            tab === 'materias'
              ? 'border-amber-600 text-amber-600'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
        >
          Materias Primas
        </button>
        <button
          onClick={() => setTab('movimientos')}
          className={`px-4 py-2 font-medium border-b-2 transition-colors ${
            tab === 'movimientos'
              ? 'border-amber-600 text-amber-600'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
        >
          Movimientos
        </button>
      </div>

      {/* Contenido de tabs */}
      {tab === 'materias' ? (
        loading ? (
          <div className="flex justify-center py-12">
            <Spinner size="lg" />
          </div>
        ) : (
          <div className="space-y-6">
            {Object.entries(materiasPorCategoria).map(([categoria, items]) => (
              <Card key={categoria} title={categoria}>
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead>
                      <tr className="border-b border-gray-200">
                        <th className="text-left py-3 px-4 font-medium text-gray-600">Producto</th>
                        <th className="text-center py-3 px-4 font-medium text-gray-600">Unidad</th>
                        <th className="text-right py-3 px-4 font-medium text-gray-600">Stock</th>
                        <th className="text-right py-3 px-4 font-medium text-gray-600">Mínimo</th>
                        <th className="text-right py-3 px-4 font-medium text-gray-600">Crítico</th>
                        <th className="text-right py-3 px-4 font-medium text-gray-600">Costo Prom.</th>
                        <th className="text-center py-3 px-4 font-medium text-gray-600">Estado</th>
                      </tr>
                    </thead>
                    <tbody>
                      {items.map((materia) => (
                        <tr key={materia.id} className="border-b border-gray-100 hover:bg-gray-50">
                          <td className="py-3 px-4 font-medium">{materia.nombre}</td>
                          <td className="py-3 px-4 text-center text-gray-600">
                            {materia.unidadMedida}
                          </td>
                          <td className="py-3 px-4 text-right font-semibold">
                            {materia.stockActual}
                          </td>
                          <td className="py-3 px-4 text-right text-gray-600">
                            {materia.stockMinimo}
                          </td>
                          <td className="py-3 px-4 text-right text-gray-600">
                            {materia.puntoCritico}
                          </td>
                          <td className="py-3 px-4 text-right">
                            {formatCurrency(materia.costoPromedio)}
                          </td>
                          <td className="py-3 px-4 text-center">
                            {materia.enPuntoCritico ? (
                              <Badge variant="danger">
                                <AlertTriangle className="h-3 w-3 mr-1" />
                                Crítico
                              </Badge>
                            ) : materia.bajoMinimo ? (
                              <Badge variant="warning">Bajo</Badge>
                            ) : (
                              <Badge variant="success">OK</Badge>
                            )}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </Card>
            ))}
          </div>
        )
      ) : loadingMovimientos ? (
        <div className="flex justify-center py-12">
          <Spinner size="lg" />
        </div>
      ) : (
        <Card>
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-200">
                  <th className="text-left py-3 px-4 font-medium text-gray-600">Fecha</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-600">Materia Prima</th>
                  <th className="text-center py-3 px-4 font-medium text-gray-600">Tipo</th>
                  <th className="text-right py-3 px-4 font-medium text-gray-600">Cantidad</th>
                  <th className="text-right py-3 px-4 font-medium text-gray-600">Costo Unit.</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-600">Motivo</th>
                </tr>
              </thead>
              <tbody>
                {movimientos.map((mov) => (
                  <tr key={mov.id} className="border-b border-gray-100 hover:bg-gray-50">
                    <td className="py-3 px-4 text-gray-600">{formatDate(mov.fecha)}</td>
                    <td className="py-3 px-4 font-medium">{mov.materiaPrimaNombre}</td>
                    <td className="py-3 px-4 text-center">
                      {mov.tipo === 'E' ? (
                        <Badge variant="success">
                          <ArrowUpCircle className="h-3 w-3 mr-1" />
                          Entrada
                        </Badge>
                      ) : mov.tipo === 'S' ? (
                        <Badge variant="info">
                          <ArrowDownCircle className="h-3 w-3 mr-1" />
                          Salida
                        </Badge>
                      ) : (
                        <Badge variant="danger">
                          <AlertTriangle className="h-3 w-3 mr-1" />
                          Merma
                        </Badge>
                      )}
                    </td>
                    <td className="py-3 px-4 text-right font-semibold">{mov.cantidad}</td>
                    <td className="py-3 px-4 text-right">
                      {mov.costoUnitario ? formatCurrency(mov.costoUnitario) : '-'}
                    </td>
                    <td className="py-3 px-4 text-gray-600">{mov.motivo || '-'}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>
      )}

      {/* Modal de nuevo movimiento */}
      <Modal
        isOpen={modalMovimiento}
        onClose={() => setModalMovimiento(false)}
        title="Registrar Movimiento"
      >
        <div className="space-y-4">
          <Select
            label="Materia Prima"
            value={nuevoMovimiento.materiaPrimaId}
            onChange={(v) =>
              setNuevoMovimiento({ ...nuevoMovimiento, materiaPrimaId: Number(v) })
            }
            options={materias.map((m) => ({
              value: m.id,
              label: `${m.nombre} (${m.categoria})`,
            }))}
            placeholder="Seleccionar..."
          />

          <Select
            label="Tipo de Movimiento"
            value={nuevoMovimiento.tipo}
            onChange={(v) => setNuevoMovimiento({ ...nuevoMovimiento, tipo: v })}
            options={[
              { value: 'E', label: '📥 Entrada' },
              { value: 'S', label: '📤 Salida' },
              { value: 'M', label: '⚠️ Merma' },
            ]}
          />

          <Input
            label="Cantidad"
            type="number"
            min="0.01"
            step="0.01"
            value={nuevoMovimiento.cantidad || ''}
            onChange={(e) =>
              setNuevoMovimiento({
                ...nuevoMovimiento,
                cantidad: parseFloat(e.target.value) || 0,
              })
            }
          />

          {nuevoMovimiento.tipo === 'E' && (
            <Input
              label="Costo Unitario (opcional)"
              type="number"
              min="0"
              step="0.01"
              value={nuevoMovimiento.costoUnitario || ''}
              onChange={(e) =>
                setNuevoMovimiento({
                  ...nuevoMovimiento,
                  costoUnitario: parseFloat(e.target.value) || undefined,
                })
              }
            />
          )}

          <Input
            label="Motivo (opcional)"
            value={nuevoMovimiento.motivo || ''}
            onChange={(e) =>
              setNuevoMovimiento({ ...nuevoMovimiento, motivo: e.target.value })
            }
            placeholder="Ej: Compra semanal, Uso en producción, etc."
          />

          <div className="flex gap-3 pt-4">
            <Button
              variant="secondary"
              onClick={() => setModalMovimiento(false)}
              className="flex-1"
            >
              Cancelar
            </Button>
            <Button
              onClick={registrarMovimiento}
              loading={procesando}
              className="flex-1"
            >
              Registrar
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}
