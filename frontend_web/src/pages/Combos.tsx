import { useState, useEffect } from 'react';
import { comboService, catalogoService } from '../services/api';
import { Card, Button, Badge, Spinner, Modal, Input, Select } from '../components/ui';
import { Plus, Edit, Trash2, Gift } from 'lucide-react';
import toast from 'react-hot-toast';
import type { Combo, CrearCombo, CrearComboItem, Presentacion, Categoria } from '../types';

export default function Combos() {
  const [combos, setCombos] = useState<Combo[]>([]);
  const [loading, setLoading] = useState(true);
  const [presentaciones, setPresentaciones] = useState<(Presentacion & { productoNombre: string })[]>([]);
  
  // Modal
  const [modalOpen, setModalOpen] = useState(false);
  const [editando, setEditando] = useState<Combo | null>(null);
  const [form, setForm] = useState<CrearCombo>({
    nombre: '',
    descripcion: '',
    precio: 0,
    tipo: 'FIJO',
    fechaInicio: undefined,
    fechaFin: undefined,
    items: [],
  });
  const [procesando, setProcesando] = useState(false);

  const fetchCombos = async () => {
    try {
      setLoading(true);
      const data = await comboService.getAll();
      setCombos(data);
    } catch (error) {
      console.error('Error al cargar combos:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchPresentaciones = async () => {
    try {
      const catalogo = await catalogoService.getCatalogo();
      const prods: (Presentacion & { productoNombre: string })[] = [];
      catalogo.categorias.forEach((cat: Categoria) => {
        cat.productos.forEach((prod) => {
          prod.presentaciones.forEach((pres) => {
            prods.push({
              ...pres,
              productoNombre: `${prod.nombre} - ${pres.nombre}`,
            });
          });
        });
      });
      setPresentaciones(prods);
    } catch (error) {
      console.error('Error al cargar presentaciones:', error);
    }
  };

  useEffect(() => {
    fetchCombos();
    fetchPresentaciones();
  }, []);

  const abrirModal = (combo?: Combo) => {
    if (combo) {
      setEditando(combo);
      setForm({
        nombre: combo.nombre,
        descripcion: combo.descripcion || '',
        precio: combo.precio,
        tipo: combo.tipo,
        fechaInicio: combo.fechaInicio,
        fechaFin: combo.fechaFin,
        items: combo.items.map((item) => ({
          presentacionId: item.presentacionId,
          cantidad: item.cantidad,
          notas: item.notas || '',
        })),
      });
    } else {
      setEditando(null);
      setForm({
        nombre: '',
        descripcion: '',
        precio: 0,
        tipo: 'FIJO',
        fechaInicio: undefined,
        fechaFin: undefined,
        items: [],
      });
    }
    setModalOpen(true);
  };

  const agregarItem = () => {
    setForm({
      ...form,
      items: [...form.items, { presentacionId: 0, cantidad: 1, notas: '' }],
    });
  };

  const actualizarItem = (index: number, field: keyof CrearComboItem, value: any) => {
    const newItems = [...form.items];
    newItems[index] = { ...newItems[index], [field]: value };
    setForm({ ...form, items: newItems });
  };

  const eliminarItem = (index: number) => {
    setForm({
      ...form,
      items: form.items.filter((_, i) => i !== index),
    });
  };

  const guardarCombo = async () => {
    if (!form.nombre || form.precio <= 0 || form.items.length === 0) {
      toast.error('Completa todos los campos requeridos');
      return;
    }

    try {
      setProcesando(true);
      if (editando) {
        await comboService.update(editando.id, form);
        toast.success('Combo actualizado correctamente');
      } else {
        await comboService.create(form);
        toast.success('Combo creado correctamente');
      }
      setModalOpen(false);
      fetchCombos();
    } catch (error) {
      toast.error('Error al guardar el combo');
    } finally {
      setProcesando(false);
    }
  };

  const eliminarCombo = async (id: number) => {
    if (!confirm('¿Estás seguro de eliminar este combo?')) return;

    try {
      await comboService.delete(id);
      toast.success('Combo eliminado');
      fetchCombos();
    } catch (error) {
      toast.error('Error al eliminar el combo');
    }
  };

  const formatCurrency = (value: number) =>
    `Q${value.toLocaleString('es-GT', { minimumFractionDigits: 2 })}`;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Combos</h1>
          <p className="text-gray-500">Gestiona los combos y promociones</p>
        </div>
        <Button onClick={() => abrirModal()}>
          <Plus className="h-4 w-4 mr-2" />
          Nuevo Combo
        </Button>
      </div>

      {loading ? (
        <div className="flex justify-center py-12">
          <Spinner size="lg" />
        </div>
      ) : combos.length === 0 ? (
        <Card>
          <div className="text-center py-12 text-gray-500">
            <Gift className="h-12 w-12 mx-auto mb-4 opacity-50" />
            <p>No hay combos creados</p>
            <Button onClick={() => abrirModal()} className="mt-4">
              Crear primer combo
            </Button>
          </div>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {combos.map((combo) => (
            <Card key={combo.id}>
              <div className="flex justify-between items-start mb-4">
                <div className="flex items-center gap-3">
                  <div className="h-12 w-12 bg-amber-100 rounded-lg flex items-center justify-center">
                    <Gift className="h-6 w-6 text-amber-600" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900">{combo.nombre}</h3>
                    <Badge variant={combo.tipo === 'FIJO' ? 'default' : 'info'}>
                      {combo.tipo}
                    </Badge>
                  </div>
                </div>
                <div className="flex gap-1">
                  <Button variant="ghost" size="sm" onClick={() => abrirModal(combo)}>
                    <Edit className="h-4 w-4" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => eliminarCombo(combo.id)}
                  >
                    <Trash2 className="h-4 w-4 text-red-500" />
                  </Button>
                </div>
              </div>

              {combo.descripcion && (
                <p className="text-sm text-gray-500 mb-4">{combo.descripcion}</p>
              )}

              <div className="space-y-2 mb-4">
                <p className="text-sm font-medium text-gray-700">Incluye:</p>
                {combo.items.map((item, index) => (
                  <div
                    key={index}
                    className="flex justify-between text-sm text-gray-600 bg-gray-50 px-3 py-2 rounded"
                  >
                    <span>
                      {item.cantidad}x {item.productoNombre}
                    </span>
                    {item.notas && (
                      <span className="text-gray-400 italic">{item.notas}</span>
                    )}
                  </div>
                ))}
              </div>

              {combo.tipo === 'ESTACIONAL' && combo.fechaInicio && combo.fechaFin && (
                <p className="text-xs text-gray-400 mb-4">
                  Válido: {new Date(combo.fechaInicio).toLocaleDateString()} -{' '}
                  {new Date(combo.fechaFin).toLocaleDateString()}
                </p>
              )}

              <div className="pt-4 border-t border-gray-200">
                <p className="text-2xl font-bold text-amber-600">
                  {formatCurrency(combo.precio)}
                </p>
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* Modal de Combo */}
      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editando ? 'Editar Combo' : 'Nuevo Combo'}
        size="lg"
      >
        <div className="space-y-4">
          <Input
            label="Nombre del Combo"
            value={form.nombre}
            onChange={(e) => setForm({ ...form, nombre: e.target.value })}
            placeholder="Ej: Combo Familiar"
          />

          <Input
            label="Descripción"
            value={form.descripcion || ''}
            onChange={(e) => setForm({ ...form, descripcion: e.target.value })}
            placeholder="Descripción del combo..."
          />

          <Input
            label="Precio"
            type="number"
            min="0"
            step="0.01"
            value={form.precio || ''}
            onChange={(e) =>
              setForm({ ...form, precio: parseFloat(e.target.value) || 0 })
            }
          />

          <Select
            label="Tipo"
            value={form.tipo}
            onChange={(v) => setForm({ ...form, tipo: v })}
            options={[
              { value: 'FIJO', label: 'Fijo (siempre disponible)' },
              { value: 'ESTACIONAL', label: 'Estacional (por fechas)' },
            ]}
          />

          {form.tipo === 'ESTACIONAL' && (
            <div className="grid grid-cols-2 gap-4">
              <Input
                label="Fecha Inicio"
                type="date"
                value={form.fechaInicio?.split('T')[0] || ''}
                onChange={(e) => setForm({ ...form, fechaInicio: e.target.value })}
              />
              <Input
                label="Fecha Fin"
                type="date"
                value={form.fechaFin?.split('T')[0] || ''}
                onChange={(e) => setForm({ ...form, fechaFin: e.target.value })}
              />
            </div>
          )}

          {/* Items del combo */}
          <div>
            <div className="flex justify-between items-center mb-2">
              <label className="block text-sm font-medium text-gray-700">
                Productos incluidos
              </label>
              <Button variant="ghost" size="sm" onClick={agregarItem}>
                <Plus className="h-4 w-4 mr-1" />
                Agregar
              </Button>
            </div>

            <div className="space-y-2">
              {form.items.map((item, index) => (
                <div key={index} className="flex gap-2 items-center bg-gray-50 p-2 rounded-lg">
                  <Select
                    value={item.presentacionId}
                    onChange={(v) => actualizarItem(index, 'presentacionId', Number(v))}
                    options={presentaciones.map((p) => ({
                      value: p.id,
                      label: p.productoNombre,
                    }))}
                    placeholder="Seleccionar producto"
                    className="flex-1"
                  />
                  <Input
                    type="number"
                    min="1"
                    value={item.cantidad}
                    onChange={(e) =>
                      actualizarItem(index, 'cantidad', parseInt(e.target.value) || 1)
                    }
                    className="w-20"
                  />
                  <Input
                    value={item.notas || ''}
                    onChange={(e) => actualizarItem(index, 'notas', e.target.value)}
                    placeholder="Notas"
                    className="w-32"
                  />
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => eliminarItem(index)}
                  >
                    <Trash2 className="h-4 w-4 text-red-500" />
                  </Button>
                </div>
              ))}

              {form.items.length === 0 && (
                <p className="text-sm text-gray-400 text-center py-4">
                  Agrega productos al combo
                </p>
              )}
            </div>
          </div>

          <div className="flex gap-3 pt-4">
            <Button
              variant="secondary"
              onClick={() => setModalOpen(false)}
              className="flex-1"
            >
              Cancelar
            </Button>
            <Button onClick={guardarCombo} loading={procesando} className="flex-1">
              {editando ? 'Actualizar' : 'Crear'} Combo
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}
