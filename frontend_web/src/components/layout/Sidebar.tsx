import { NavLink } from 'react-router-dom';
import {
  LayoutDashboard,
  ShoppingCart,
  Package,
  Boxes,
  ClipboardList,
  Store,
  MessageSquare,
  Settings,
} from 'lucide-react';

const navigation = [
  { name: 'Dashboard', href: '/', icon: LayoutDashboard },
  { name: 'Punto de Venta', href: '/ventas/nuevo', icon: ShoppingCart },
  { name: 'Historial Ventas', href: '/ventas', icon: ClipboardList },
  { name: 'Inventario', href: '/inventario', icon: Package },
  { name: 'Combos', href: '/combos', icon: Boxes },
  { name: 'Sucursales', href: '/sucursales', icon: Store },
  { name: 'Asistente IA', href: '/asistente', icon: MessageSquare },
];

export function Sidebar() {
  return (
    <aside className="fixed left-0 top-0 h-full w-64 bg-gray-900 text-white flex flex-col">
      {/* Logo */}
      <div className="p-6 border-b border-gray-800">
        <div className="flex items-center gap-3">
          <span className="text-3xl"></span>
          <div>
            <h1 className="font-bold text-lg">La Cazuela</h1>
            <p className="text-xs text-gray-400">Chapina</p>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4 space-y-1 overflow-y-auto">
        {navigation.map((item) => (
          <NavLink
            key={item.name}
            to={item.href}
            className={({ isActive }) =>
              `flex items-center gap-3 px-4 py-3 rounded-lg transition-colors ${
                isActive
                  ? 'bg-amber-600 text-white'
                  : 'text-gray-300 hover:bg-gray-800 hover:text-white'
              }`
            }
          >
            <item.icon className="h-5 w-5" />
            <span>{item.name}</span>
          </NavLink>
        ))}
      </nav>

      {/* Footer */}
      <div className="p-4 border-t border-gray-800">
        <NavLink
          to="/configuracion"
          className="flex items-center gap-3 px-4 py-3 rounded-lg text-gray-300 hover:bg-gray-800 hover:text-white transition-colors"
        >
          <Settings className="h-5 w-5" />
          <span>Configuración</span>
        </NavLink>
      </div>
    </aside>
  );
}
