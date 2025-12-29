import { useDashboard } from '../hooks/useData';
import { StatCard, Card, Spinner, Badge } from '../components/ui';
import {
  DollarSign,
  ShoppingBag,
  TrendingUp,
  AlertTriangle,
  Flame,
} from 'lucide-react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Legend,
} from 'recharts';

const COLORS = ['#f59e0b', '#10b981', '#3b82f6', '#ef4444', '#8b5cf6'];

export default function Dashboard() {
  const { dashboard, loading, error } = useDashboard();

  if (loading) {
    return (
      <div className="flex items-center justify-center h-96">
        <Spinner size="lg" />
      </div>
    );
  }

  if (error || !dashboard) {
    return (
      <div className="text-center py-12">
        <p className="text-red-500">{error || 'Error al cargar el dashboard'}</p>
      </div>
    );
  }

  const formatCurrency = (value: number) => `Q${value.toLocaleString('es-GT', { minimumFractionDigits: 2 })}`;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-500">Resumen de indicadores clave del negocio</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard
          title="Ventas Hoy"
          value={formatCurrency(dashboard.ventasHoy)}
          icon={<DollarSign className="h-6 w-6" />}
          color="amber"
        />
        <StatCard
          title="Ventas del Mes"
          value={formatCurrency(dashboard.ventasMes)}
          icon={<TrendingUp className="h-6 w-6" />}
          color="green"
        />
        <StatCard
          title="Transacciones Hoy"
          value={dashboard.totalVentasHoy}
          icon={<ShoppingBag className="h-6 w-6" />}
          color="blue"
        />
        <StatCard
          title="Desperdicio del Mes"
          value={formatCurrency(dashboard.desperdicioMes)}
          icon={<AlertTriangle className="h-6 w-6" />}
          color="red"
        />
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Productos más vendidos */}
        <Card title="Productos Más Vendidos" subtitle="Top 10 del mes">
          <div className="h-80">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart
                data={dashboard.productosMasVendidos.slice(0, 5)}
                layout="vertical"
                margin={{ top: 5, right: 30, left: 100, bottom: 5 }}
              >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis type="number" />
                <YAxis dataKey="producto" type="category" width={90} tick={{ fontSize: 12 }} />
                <Tooltip
                  formatter={(value: number) => [value, 'Cantidad']}
                  contentStyle={{ borderRadius: '8px' }}
                />
                <Bar dataKey="cantidadVendida" fill="#f59e0b" radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </Card>

        {/* Proporción Picante */}
        <Card title="Proporción Picante vs No Picante" subtitle="Preferencias de los clientes">
          <div className="h-80">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={[
                    { name: 'Con Picante', value: dashboard.proporcionPicante.conPicante },
                    { name: 'Sin Picante', value: dashboard.proporcionPicante.sinPicante },
                  ]}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={100}
                  paddingAngle={5}
                  dataKey="value"
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                >
                  <Cell fill="#ef4444" />
                  <Cell fill="#10b981" />
                </Pie>
                <Tooltip />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </div>
          <div className="flex justify-center gap-8 mt-4">
            <div className="flex items-center gap-2">
              <Flame className="h-5 w-5 text-red-500" />
              <span className="text-sm">Chapín: {dashboard.proporcionPicante.porcentajeConPicante}%</span>
            </div>
          </div>
        </Card>
      </div>

      {/* Second Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Utilidades por Línea */}
        <Card title="Utilidades por Línea" subtitle="Margen de ganancia por categoría">
          <div className="h-80">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={dashboard.utilidadesPorLinea}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="linea" />
                <YAxis />
                <Tooltip
                  formatter={(value: number) => [formatCurrency(value), '']}
                  contentStyle={{ borderRadius: '8px' }}
                />
                <Bar dataKey="ventas" name="Ventas" fill="#3b82f6" radius={[4, 4, 0, 0]} />
                <Bar dataKey="utilidad" name="Utilidad" fill="#10b981" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </Card>

        {/* Bebidas por Horario */}
        <Card title="Bebidas Preferidas por Horario" subtitle="Tendencias de consumo">
          <div className="space-y-4">
            {dashboard.bebidasPorHorario.length > 0 ? (
              dashboard.bebidasPorHorario.map((item, index) => (
                <div
                  key={index}
                  className="flex items-center justify-between p-4 bg-gray-50 rounded-lg"
                >
                  <div>
                    <p className="font-medium text-gray-900">{item.horario}</p>
                    <p className="text-sm text-gray-500">{item.bebida}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-2xl font-bold text-amber-600">{item.cantidad}</p>
                    <p className="text-xs text-gray-500">vendidos</p>
                  </div>
                </div>
              ))
            ) : (
              <p className="text-gray-500 text-center py-8">No hay datos de bebidas aún</p>
            )}
          </div>
        </Card>
      </div>

      {/* Alertas de Inventario */}
      <Card title="Alertas de Inventario" subtitle="Productos con stock bajo o crítico">
        {dashboard.alertasInventario.length > 0 ? (
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="border-b border-gray-200">
                  <th className="text-left py-3 px-4 font-medium text-gray-600">Producto</th>
                  <th className="text-left py-3 px-4 font-medium text-gray-600">Categoría</th>
                  <th className="text-right py-3 px-4 font-medium text-gray-600">Stock Actual</th>
                  <th className="text-right py-3 px-4 font-medium text-gray-600">Punto Crítico</th>
                  <th className="text-center py-3 px-4 font-medium text-gray-600">Estado</th>
                </tr>
              </thead>
              <tbody>
                {dashboard.alertasInventario.map((alerta) => (
                  <tr key={alerta.id} className="border-b border-gray-100 hover:bg-gray-50">
                    <td className="py-3 px-4 font-medium text-gray-900">{alerta.nombre}</td>
                    <td className="py-3 px-4 text-gray-600">{alerta.categoria}</td>
                    <td className="py-3 px-4 text-right text-gray-900">{alerta.stockActual}</td>
                    <td className="py-3 px-4 text-right text-gray-600">{alerta.puntoCritico}</td>
                    <td className="py-3 px-4 text-center">
                      <Badge variant={alerta.nivel === 'CRITICO' ? 'danger' : 'warning'}>
                        {alerta.nivel}
                      </Badge>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="text-center py-8">
            <p className="text-green-600 font-medium">✓ Todos los productos tienen stock suficiente</p>
          </div>
        )}
      </Card>
    </div>
  );
}
