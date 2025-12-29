import 'package:flutter/foundation.dart';
import '../models/models.dart';

class CarritoProvider extends ChangeNotifier {
  final List<ItemCarrito> _items = [];
  int _sucursalId = 1;
  double _descuento = 0;

  List<ItemCarrito> get items => _items;
  int get sucursalId => _sucursalId;
  double get descuento => _descuento;
  double get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);
  double get total => subtotal - _descuento;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.cantidad);

  void setSucursal(int id) { 
    _sucursalId = id; 
    notifyListeners(); 
  }
  
  void setDescuento(double d) { 
    _descuento = d; 
    notifyListeners(); 
  }

  void agregarItem(ItemCarrito item) {
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx >= 0) { 
      _items[idx].updateCantidad(_items[idx].cantidad + item.cantidad); 
    } else { 
      _items.add(item); 
    }
    notifyListeners();
  }

  void eliminarItem(String id) { 
    _items.removeWhere((i) => i.id == id); 
    notifyListeners(); 
  }

  void actualizarCantidad(String id, int cant) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      if (cant <= 0) { 
        _items.removeAt(idx); 
      } else { 
        _items[idx].updateCantidad(cant); 
      }
      notifyListeners();
    }
  }

  void limpiar() { 
    _items.clear(); 
    _descuento = 0; 
    notifyListeners(); 
  }

  Map<String, dynamic> toVentaJson() {
    return {
      'sucursalId': _sucursalId,
      'descuento': _descuento,
      'items': _items.map((item) {
        final Map<String, dynamic> j = {'cantidad': item.cantidad};
        if (item.presentacionId != null) j['presentacionId'] = item.presentacionId;
        if (item.comboId != null) j['comboId'] = item.comboId;
        if (item.personalizacion != null) j['personalizacion'] = item.personalizacion;
        return j;
      }).toList(),
    };
  }
}
