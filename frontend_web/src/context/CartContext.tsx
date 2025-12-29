import { createContext, useContext, useState, ReactNode } from 'react';
import type { ItemCarrito, CrearVenta, CrearVentaItem } from '../types';

interface CartContextType {
  items: ItemCarrito[];
  sucursalId: number;
  setSucursalId: (id: number) => void;
  addItem: (item: ItemCarrito) => void;
  removeItem: (id: string) => void;
  updateQuantity: (id: string, cantidad: number) => void;
  clearCart: () => void;
  getTotal: () => number;
  getSubtotal: () => number;
  descuento: number;
  setDescuento: (descuento: number) => void;
  toCrearVenta: () => CrearVenta;
}

const CartContext = createContext<CartContextType | undefined>(undefined);

export function CartProvider({ children }: { children: ReactNode }) {
  const [items, setItems] = useState<ItemCarrito[]>([]);
  const [sucursalId, setSucursalId] = useState<number>(1);
  const [descuento, setDescuento] = useState<number>(0);

  const addItem = (item: ItemCarrito) => {
    setItems((prev) => [...prev, { ...item, id: crypto.randomUUID() }]);
  };

  const removeItem = (id: string) => {
    setItems((prev) => prev.filter((item) => item.id !== id));
  };

  const updateQuantity = (id: string, cantidad: number) => {
    if (cantidad < 1) {
      removeItem(id);
      return;
    }
    setItems((prev) =>
      prev.map((item) =>
        item.id === id
          ? {
              ...item,
              cantidad,
              subtotal: (item.precioUnitario + item.precioExtras) * cantidad,
            }
          : item
      )
    );
  };

  const clearCart = () => {
    setItems([]);
    setDescuento(0);
  };

  const getSubtotal = () => {
    return items.reduce((acc, item) => acc + item.subtotal, 0);
  };

  const getTotal = () => {
    return getSubtotal() - descuento;
  };

  const toCrearVenta = (): CrearVenta => {
    const ventaItems: CrearVentaItem[] = items.map((item) => ({
      presentacionId: item.tipo === 'producto' ? item.presentacionId : undefined,
      comboId: item.tipo === 'combo' ? item.comboId : undefined,
      cantidad: item.cantidad,
      personalizacion: item.personalizacion,
    }));

    return {
      sucursalId,
      descuento,
      items: ventaItems,
    };
  };

  return (
    <CartContext.Provider
      value={{
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
      }}
    >
      {children}
    </CartContext.Provider>
  );
}

export function useCart() {
  const context = useContext(CartContext);
  if (context === undefined) {
    throw new Error('useCart must be used within a CartProvider');
  }
  return context;
}
