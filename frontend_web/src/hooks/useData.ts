import { useState, useEffect } from 'react';
import { catalogoService, dashboardService, inventarioService, sucursalService } from '../services/api';
import type { CatalogoCompleto, Dashboard, MateriaPrima, Sucursal } from '../types';

// Hook para cargar el catálogo
export function useCatalogo() {
  const [catalogo, setCatalogo] = useState<CatalogoCompleto | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchCatalogo = async () => {
    try {
      setLoading(true);
      const data = await catalogoService.getCatalogo();
      setCatalogo(data);
      setError(null);
    } catch (err) {
      setError('Error al cargar el catálogo');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCatalogo();
  }, []);

  return { catalogo, loading, error, refetch: fetchCatalogo };
}

// Hook para cargar el dashboard
export function useDashboard(sucursalId?: number) {
  const [dashboard, setDashboard] = useState<Dashboard | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchDashboard = async () => {
    try {
      setLoading(true);
      const data = await dashboardService.getDashboard(sucursalId);
      setDashboard(data);
      setError(null);
    } catch (err) {
      setError('Error al cargar el dashboard');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDashboard();
  }, [sucursalId]);

  return { dashboard, loading, error, refetch: fetchDashboard };
}

// Hook para cargar inventario
export function useInventario() {
  const [materias, setMaterias] = useState<MateriaPrima[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchMaterias = async () => {
    try {
      setLoading(true);
      const data = await inventarioService.getMaterias();
      setMaterias(data);
      setError(null);
    } catch (err) {
      setError('Error al cargar el inventario');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchMaterias();
  }, []);

  return { materias, loading, error, refetch: fetchMaterias };
}

// Hook para cargar sucursales
export function useSucursales() {
  const [sucursales, setSucursales] = useState<Sucursal[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchSucursales = async () => {
    try {
      setLoading(true);
      const data = await sucursalService.getAll();
      setSucursales(data);
      setError(null);
    } catch (err) {
      setError('Error al cargar sucursales');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchSucursales();
  }, []);

  return { sucursales, loading, error, refetch: fetchSucursales };
}
