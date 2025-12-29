import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { Layout } from './components/layout/Layout';
import { CartProvider } from './context/CartContext';

// Pages
import Dashboard from './pages/Dashboard';
import PuntoVenta from './pages/PuntoVenta';
import Ventas from './pages/Ventas';
import Inventario from './pages/Inventario';
import Combos from './pages/Combos';
import Sucursales from './pages/Sucursales';
import Asistente from './pages/Asistente';

function App() {
  return (
    <BrowserRouter>
      <CartProvider>
        <Layout>
          <Routes>
            <Route path="/" element={<Dashboard />} />
            <Route path="/ventas/nuevo" element={<PuntoVenta />} />
            <Route path="/ventas" element={<Ventas />} />
            <Route path="/inventario" element={<Inventario />} />
            <Route path="/combos" element={<Combos />} />
            <Route path="/sucursales" element={<Sucursales />} />
            <Route path="/asistente" element={<Asistente />} />
          </Routes>
        </Layout>
        <Toaster
          position="top-right"
          toastOptions={{
            duration: 3000,
            style: {
              borderRadius: '10px',
              background: '#333',
              color: '#fff',
            },
          }}
        />
      </CartProvider>
    </BrowserRouter>
  );
}

export default App;
