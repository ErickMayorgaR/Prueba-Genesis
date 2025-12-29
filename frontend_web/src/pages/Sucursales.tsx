import { useState } from 'react';
import { useSucursales } from '../hooks/useData';
import { sucursalService } from '../services/api';
import { Card, Button, Badge, Spinner, Modal, Input } from '../components/ui';
import { Plus, Edit, Trash2, Store, MapPin, Phone } from 'lucide-react';
import toast from 'react-hot-toast';
import type { Sucursal, CrearSucursal } from '../types';

export default function Sucursales() {
  const { sucursales, loading, refetch } = useSucursales();
  
  // Modal
  const [modalOpen, setModalOpen] = useState(false);
  const [editando, setEditando] = useState<Sucursal | null>(null);
  const [form, setForm] = useState<CrearSucursal>({
    nombre: '',
    direccion: '',
    telefono: '',
  });
  const [procesando, setProcesando] = useState(false);

  const abrirModal = (sucursal?: Sucursal) => {
    if (sucursal) {
      setEditando(sucursal);
      setForm({
        nombre: sucursal.nombre,
        direccion: sucursal.direccion || '',
        telefono: sucursal.telefono || '',
      });
    } else {
      setEditando(null);
      setForm({ nombre: '', direccion: '', telefono: '' });
    }
    setModalOpen(true);
  };

  const guardarSucursal = async () => {
    if (!form.nombre) {
      toast.error('El nombre es requerido');
      return;
    }

    try {
      setProcesando(true);
      if (editando) {
        await sucursalService.update(editando.id, form);
        toast.success('Sucursal actualizada');
      } else {
        await sucursalService.create(form);
        toast.success('Sucursal creada');
      }
      setModalOpen(false);
      refetch();
    } catch (error) {
      toast.error('Error al guardar sucursal');
    } finally {
      setProcesando(false);
    }
  };

  const eliminarSucursal = async (id: number) => {
    if (!confirm('¿Estás seguro de eliminar esta sucursal?')) return;

    try {
      await sucursalService.delete(id);
      toast.success('Sucursal eliminada');
      refetch();
    } catch (error) {
      toast.error('Error al eliminar sucursal');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Sucursales</h1>
          <p className="text-gray-500">Gestiona las sucursales del negocio</p>
        </div>
        <Button onClick={() => abrirModal()}>
          <Plus className="h-4 w-4 mr-2" />
          Nueva Sucursal
        </Button>
      </div>

      {loading ? (
        <div className="flex justify-center py-12">
          <Spinner size="lg" />
        </div>
      ) : sucursales.length === 0 ? (
        <Card>
          <div className="text-center py-12 text-gray-500">
            <Store className="h-12 w-12 mx-auto mb-4 opacity-50" />
            <p>No hay sucursales creadas</p>
            <Button onClick={() => abrirModal()} className="mt-4">
              Crear primera sucursal
            </Button>
          </div>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {sucursales.map((sucursal) => (
            <Card key={sucursal.id}>
              <div className="flex justify-between items-start mb-4">
                <div className="flex items-center gap-3">
                  <div className="h-12 w-12 bg-blue-100 rounded-lg flex items-center justify-center">
                    <Store className="h-6 w-6 text-blue-600" />
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900">{sucursal.nombre}</h3>
                    <Badge variant={sucursal.activo ? 'success' : 'danger'}>
                      {sucursal.activo ? 'Activa' : 'Inactiva'}
                    </Badge>
                  </div>
                </div>
                <div className="flex gap-1">
                  <Button variant="ghost" size="sm" onClick={() => abrirModal(sucursal)}>
                    <Edit className="h-4 w-4" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => eliminarSucursal(sucursal.id)}
                  >
                    <Trash2 className="h-4 w-4 text-red-500" />
                  </Button>
                </div>
              </div>

              <div className="space-y-2 text-sm">
                {sucursal.direccion && (
                  <div className="flex items-center gap-2 text-gray-600">
                    <MapPin className="h-4 w-4" />
                    <span>{sucursal.direccion}</span>
                  </div>
                )}
                {sucursal.telefono && (
                  <div className="flex items-center gap-2 text-gray-600">
                    <Phone className="h-4 w-4" />
                    <span>{sucursal.telefono}</span>
                  </div>
                )}
              </div>
            </Card>
          ))}
        </div>
      )}

      {/* Modal */}
      <Modal
        isOpen={modalOpen}
        onClose={() => setModalOpen(false)}
        title={editando ? 'Editar Sucursal' : 'Nueva Sucursal'}
      >
        <div className="space-y-4">
          <Input
            label="Nombre"
            value={form.nombre}
            onChange={(e) => setForm({ ...form, nombre: e.target.value })}
            placeholder="Ej: Sucursal Zona 10"
          />

          <Input
            label="Dirección"
            value={form.direccion || ''}
            onChange={(e) => setForm({ ...form, direccion: e.target.value })}
            placeholder="Dirección completa..."
          />

          <Input
            label="Teléfono"
            value={form.telefono || ''}
            onChange={(e) => setForm({ ...form, telefono: e.target.value })}
            placeholder="Ej: 2222-3333"
          />

          <div className="flex gap-3 pt-4">
            <Button
              variant="secondary"
              onClick={() => setModalOpen(false)}
              className="flex-1"
            >
              Cancelar
            </Button>
            <Button onClick={guardarSucursal} loading={procesando} className="flex-1">
              {editando ? 'Actualizar' : 'Crear'}
            </Button>
          </div>
        </div>
      </Modal>
    </div>
  );
}
