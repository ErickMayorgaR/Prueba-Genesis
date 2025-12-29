// ==================== CATALOGO ====================
class CatalogoCompleto {
  final List<Categoria> categorias;
  final List<Combo> combos;

  CatalogoCompleto({required this.categorias, required this.combos});

  factory CatalogoCompleto.fromJson(Map<String, dynamic> json) {
    return CatalogoCompleto(
      categorias: (json['categorias'] as List?)?.map((e) => Categoria.fromJson(e)).toList() ?? [],
      combos: (json['combos'] as List?)?.map((e) => Combo.fromJson(e)).toList() ?? [],
    );
  }
}

class Categoria {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? icono;
  final List<Producto> productos;
  final List<Atributo> atributos;

  Categoria({required this.id, required this.nombre, this.descripcion, this.icono, required this.productos, required this.atributos});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      icono: json['icono'],
      productos: (json['productos'] as List?)?.map((e) => Producto.fromJson(e)).toList() ?? [],
      atributos: (json['atributos'] as List?)?.map((e) => Atributo.fromJson(e)).toList() ?? [],
    );
  }
}

class Producto {
  final int id;
  final String? codigo;
  final String nombre;
  final String? descripcion;
  final List<Presentacion> presentaciones;

  Producto({required this.id, this.codigo, required this.nombre, this.descripcion, required this.presentaciones});

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      codigo: json['codigo'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      presentaciones: (json['presentaciones'] as List?)?.map((e) => Presentacion.fromJson(e)).toList() ?? [],
    );
  }
}

class Presentacion {
  final int id;
  final String nombre;
  final int cantidad;
  final double precio;

  Presentacion({required this.id, required this.nombre, required this.cantidad, required this.precio});

  factory Presentacion.fromJson(Map<String, dynamic> json) {
    return Presentacion(
      id: json['id'],
      nombre: json['nombre'],
      cantidad: json['cantidad'] ?? 1,
      precio: (json['precio'] as num).toDouble(),
    );
  }
}

class Atributo {
  final int id;
  final String nombre;
  final String codigo;
  final bool esMultiple;
  final bool esRequerido;
  final List<Opcion> opciones;

  Atributo({required this.id, required this.nombre, required this.codigo, required this.esMultiple, required this.esRequerido, required this.opciones});

  factory Atributo.fromJson(Map<String, dynamic> json) {
    return Atributo(
      id: json['id'],
      nombre: json['nombre'],
      codigo: json['codigo'],
      esMultiple: json['esMultiple'] ?? false,
      esRequerido: json['esRequerido'] ?? false,
      opciones: (json['opciones'] as List?)?.map((e) => Opcion.fromJson(e)).toList() ?? [],
    );
  }
}

class Opcion {
  final int id;
  final String nombre;
  final String codigo;
  final double precioExtra;

  Opcion({required this.id, required this.nombre, required this.codigo, required this.precioExtra});

  factory Opcion.fromJson(Map<String, dynamic> json) {
    return Opcion(
      id: json['id'],
      nombre: json['nombre'],
      codigo: json['codigo'],
      precioExtra: (json['precioExtra'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ==================== COMBO ====================
class Combo {
  final int id;
  final String nombre;
  final String? descripcion;
  final double precio;
  final String tipo;
  final List<ComboItem> items;

  Combo({required this.id, required this.nombre, this.descripcion, required this.precio, required this.tipo, required this.items});

  factory Combo.fromJson(Map<String, dynamic> json) {
    return Combo(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: (json['precio'] as num).toDouble(),
      tipo: json['tipo'] ?? 'FIJO',
      items: (json['items'] as List?)?.map((e) => ComboItem.fromJson(e)).toList() ?? [],
    );
  }
}

class ComboItem {
  final int id;
  final int presentacionId;
  final String presentacionNombre;
  final String productoNombre;
  final int cantidad;

  ComboItem({required this.id, required this.presentacionId, required this.presentacionNombre, required this.productoNombre, required this.cantidad});

  factory ComboItem.fromJson(Map<String, dynamic> json) {
    return ComboItem(
      id: json['id'],
      presentacionId: json['presentacionId'],
      presentacionNombre: json['presentacionNombre'] ?? '',
      productoNombre: json['productoNombre'] ?? '',
      cantidad: json['cantidad'] ?? 1,
    );
  }
}

// ==================== INVENTARIO ====================
class MateriaPrima {
  final int id;
  final String categoria;
  final String nombre;
  final String unidadMedida;
  final double stockActual;
  final double stockMinimo;
  final double puntoCritico;
  final double costoPromedio;
  final bool enPuntoCritico;
  final bool bajoMinimo;

  MateriaPrima({
    required this.id, required this.categoria, required this.nombre, required this.unidadMedida,
    required this.stockActual, required this.stockMinimo, required this.puntoCritico,
    required this.costoPromedio, required this.enPuntoCritico, required this.bajoMinimo,
  });

  factory MateriaPrima.fromJson(Map<String, dynamic> json) {
    return MateriaPrima(
      id: json['id'],
      categoria: json['categoria'] ?? '',
      nombre: json['nombre'],
      unidadMedida: json['unidadMedida'] ?? '',
      stockActual: (json['stockActual'] as num?)?.toDouble() ?? 0,
      stockMinimo: (json['stockMinimo'] as num?)?.toDouble() ?? 0,
      puntoCritico: (json['puntoCritico'] as num?)?.toDouble() ?? 0,
      costoPromedio: (json['costoPromedio'] as num?)?.toDouble() ?? 0,
      enPuntoCritico: json['enPuntoCritico'] ?? false,
      bajoMinimo: json['bajoMinimo'] ?? false,
    );
  }
}

class Movimiento {
  final int id;
  final int materiaPrimaId;
  final String materiaPrimaNombre;
  final String tipo;
  final double cantidad;
  final double? costoUnitario;
  final String? motivo;
  final DateTime fecha;

  Movimiento({
    required this.id, required this.materiaPrimaId, required this.materiaPrimaNombre,
    required this.tipo, required this.cantidad, this.costoUnitario, this.motivo, required this.fecha,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'],
      materiaPrimaId: json['materiaPrimaId'],
      materiaPrimaNombre: json['materiaPrimaNombre'] ?? '',
      tipo: json['tipo'],
      cantidad: (json['cantidad'] as num).toDouble(),
      costoUnitario: (json['costoUnitario'] as num?)?.toDouble(),
      motivo: json['motivo'],
      fecha: DateTime.parse(json['fecha']),
    );
  }
}

// ==================== VENTA ====================
class Venta {
  final int id;
  final String? codigo;
  final int sucursalId;
  final String sucursalNombre;
  final DateTime fecha;
  final double subtotal;
  final double descuento;
  final double total;
  final String estado;
  final List<VentaItem> items;

  Venta({
    required this.id, this.codigo, required this.sucursalId, required this.sucursalNombre,
    required this.fecha, required this.subtotal, required this.descuento, required this.total,
    required this.estado, required this.items,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id'],
      codigo: json['codigo'],
      sucursalId: json['sucursalId'],
      sucursalNombre: json['sucursalNombre'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      subtotal: (json['subtotal'] as num).toDouble(),
      descuento: (json['descuento'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      estado: json['estado'],
      items: (json['items'] as List?)?.map((e) => VentaItem.fromJson(e)).toList() ?? [],
    );
  }
}

class VentaItem {
  final int id;
  final String tipoItem;
  final int? presentacionId;
  final int? comboId;
  final String descripcion;
  final int cantidad;
  final double precioUnitario;
  final double precioExtras;
  final double subtotal;

  VentaItem({
    required this.id, required this.tipoItem, this.presentacionId, this.comboId,
    required this.descripcion, required this.cantidad, required this.precioUnitario,
    required this.precioExtras, required this.subtotal,
  });

  factory VentaItem.fromJson(Map<String, dynamic> json) {
    return VentaItem(
      id: json['id'],
      tipoItem: json['tipoItem'] ?? '',
      presentacionId: json['presentacionId'],
      comboId: json['comboId'],
      descripcion: json['descripcion'] ?? '',
      cantidad: json['cantidad'],
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      precioExtras: (json['precioExtras'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}

// ==================== SUCURSAL ====================
class Sucursal {
  final int id;
  final String nombre;
  final String? direccion;
  final String? telefono;
  final bool activo;

  Sucursal({required this.id, required this.nombre, this.direccion, this.telefono, required this.activo});

  factory Sucursal.fromJson(Map<String, dynamic> json) {
    return Sucursal(
      id: json['id'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      activo: json['activo'] ?? true,
    );
  }
}

// ==================== DASHBOARD ====================
class Dashboard {
  final double ventasHoy;
  final double ventasMes;
  final int totalVentasHoy;
  final int totalVentasMes;
  final List<ProductoVendido> productosMasVendidos;
  final ProporcionPicante proporcionPicante;
  final List<InventarioAlerta> alertasInventario;
  final double desperdicioMes;

  Dashboard({
    required this.ventasHoy, required this.ventasMes, required this.totalVentasHoy,
    required this.totalVentasMes, required this.productosMasVendidos,
    required this.proporcionPicante, required this.alertasInventario, required this.desperdicioMes,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      ventasHoy: (json['ventasHoy'] as num?)?.toDouble() ?? 0,
      ventasMes: (json['ventasMes'] as num?)?.toDouble() ?? 0,
      totalVentasHoy: json['totalVentasHoy'] ?? 0,
      totalVentasMes: json['totalVentasMes'] ?? 0,
      productosMasVendidos: (json['productosMasVendidos'] as List?)?.map((e) => ProductoVendido.fromJson(e)).toList() ?? [],
      proporcionPicante: ProporcionPicante.fromJson(json['proporcionPicante'] ?? {}),
      alertasInventario: (json['alertasInventario'] as List?)?.map((e) => InventarioAlerta.fromJson(e)).toList() ?? [],
      desperdicioMes: (json['desperdicioMes'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ProductoVendido {
  final String producto;
  final String presentacion;
  final int cantidadVendida;
  final double totalVendido;

  ProductoVendido({required this.producto, required this.presentacion, required this.cantidadVendida, required this.totalVendido});

  factory ProductoVendido.fromJson(Map<String, dynamic> json) {
    return ProductoVendido(
      producto: json['producto'] ?? '',
      presentacion: json['presentacion'] ?? '',
      cantidadVendida: json['cantidadVendida'] ?? 0,
      totalVendido: (json['totalVendido'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ProporcionPicante {
  final int conPicante;
  final int sinPicante;
  final double porcentajeConPicante;

  ProporcionPicante({required this.conPicante, required this.sinPicante, required this.porcentajeConPicante});

  factory ProporcionPicante.fromJson(Map<String, dynamic> json) {
    return ProporcionPicante(
      conPicante: json['conPicante'] ?? 0,
      sinPicante: json['sinPicante'] ?? 0,
      porcentajeConPicante: (json['porcentajeConPicante'] as num?)?.toDouble() ?? 0,
    );
  }
}

class InventarioAlerta {
  final int id;
  final String nombre;
  final String categoria;
  final double stockActual;
  final double puntoCritico;
  final String nivel;

  InventarioAlerta({required this.id, required this.nombre, required this.categoria, required this.stockActual, required this.puntoCritico, required this.nivel});

  factory InventarioAlerta.fromJson(Map<String, dynamic> json) {
    return InventarioAlerta(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      categoria: json['categoria'] ?? '',
      stockActual: (json['stockActual'] as num?)?.toDouble() ?? 0,
      puntoCritico: (json['puntoCritico'] as num?)?.toDouble() ?? 0,
      nivel: json['nivel'] ?? '',
    );
  }
}

// ==================== CARRITO ====================
class ItemCarrito {
  final String id;
  final String tipo;
  final int? presentacionId;
  final int? comboId;
  final String nombre;
  final String descripcion;
  int cantidad;
  final double precioUnitario;
  final double precioExtras;
  double subtotal;
  final Map<String, dynamic>? personalizacion;

  ItemCarrito({
    required this.id, required this.tipo, this.presentacionId, this.comboId,
    required this.nombre, required this.descripcion, required this.cantidad,
    required this.precioUnitario, required this.precioExtras, required this.subtotal,
    this.personalizacion,
  });

  void updateCantidad(int nuevaCantidad) {
    cantidad = nuevaCantidad;
    subtotal = (precioUnitario + precioExtras) * cantidad;
  }
}
