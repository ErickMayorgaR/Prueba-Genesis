import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../providers/cart_provider.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});
  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final formatter = NumberFormat.currency(locale: 'es_GT', symbol: 'Q');
  CatalogoCompleto? _catalogo;
  List<Sucursal> _sucursales = [];
  bool _loading = true;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final r = await Future.wait([_api.getCatalogo(), _api.getSucursales()]);
      setState(() {
        _catalogo = r[0] as CatalogoCompleto;
        _sucursales = r[1] as List<Sucursal>;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceBlue,
      appBar: AppBar(
        title: const Text('Punto de Venta'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: AppTheme.borderRadiusMedium,
            ),
            child: TabBar(
              controller: _tabCtrl,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: AppTheme.borderRadiusMedium,
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.primaryBlue,
              tabs: const [
                Tab(text: '🫔 Tamales'),
                Tab(text: '☕ Bebidas'),
                Tab(text: '🎁 Combos'),
              ],
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _buildCat(0),
                      _buildCat(1),
                      _buildCombos(),
                    ],
                  ),
                ),
                _buildCart(),
              ],
            ),
    );
  }

  Widget _buildCat(int idx) {
    if (_catalogo == null || _catalogo!.categorias.length <= idx) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('Sin productos', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }
    final cat = _catalogo!.categorias[idx];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cat.productos.length,
      itemBuilder: (ctx, i) {
        final p = cat.productos[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.borderRadiusMedium,
            boxShadow: AppTheme.softShadow,
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: AppTheme.borderRadiusSmall,
                ),
                child: Text(cat.icono ?? '🫔', style: const TextStyle(fontSize: 20)),
              ),
              title: Text(
                p.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: Text(
                p.descripcion ?? '',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              children: p.presentaciones.map((pr) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceBlue,
                    borderRadius: AppTheme.borderRadiusSmall,
                  ),
                  child: ListTile(
                    dense: true,
                    title: Text(pr.nombre, style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.1),
                            borderRadius: AppTheme.borderRadiusSmall,
                          ),
                          child: Text(
                            formatter.format(pr.precio),
                            style: TextStyle(
                              color: AppTheme.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: AppTheme.primaryBlue,
                          borderRadius: AppTheme.borderRadiusSmall,
                          child: InkWell(
                            onTap: () => _showCustom(cat, p, pr),
                            borderRadius: AppTheme.borderRadiusSmall,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.add, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCombos() {
    if (_catalogo == null || _catalogo!.combos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_offer_outlined, size: 64, color: AppTheme.textSecondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('Sin combos', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _catalogo!.combos.length,
      itemBuilder: (ctx, i) {
        final c = _catalogo!.combos[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.borderRadiusMedium,
            boxShadow: AppTheme.softShadow,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.1),
                borderRadius: AppTheme.borderRadiusSmall,
              ),
              child: Icon(Icons.local_offer, color: AppTheme.accentBlue),
            ),
            title: Text(
              c.nombre,
              style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (c.descripcion != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      c.descripcion!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.lightBlue,
                        borderRadius: AppTheme.borderRadiusSmall,
                      ),
                      child: Text(
                        c.tipo,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: AppTheme.borderRadiusSmall,
                      ),
                      child: Text(
                        formatter.format(c.precio),
                        style: TextStyle(
                          color: AppTheme.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Material(
              color: AppTheme.primaryBlue,
              borderRadius: AppTheme.borderRadiusMedium,
              child: InkWell(
                onTap: () => _addCombo(c),
                borderRadius: AppTheme.borderRadiusMedium,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.add_shopping_cart, color: Colors.white),
                ),
              ),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _buildCart() {
    return Consumer<CartProvider>(
      builder: (ctx, cart, _) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.lightBlue,
                            borderRadius: AppTheme.borderRadiusSmall,
                          ),
                          child: Icon(Icons.shopping_cart, color: AppTheme.primaryBlue, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${cart.itemCount} items',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      formatter.format(cart.total),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: cart.items.isEmpty ? null : _showCartSheet,
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Ver Carrito'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: cart.items.isEmpty ? null : _pay,
                        icon: const Icon(Icons.payment),
                        label: const Text('Cobrar'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCustom(Categoria cat, Producto prod, Presentacion pres) {
    final Map<String, int> sel = {};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: AppTheme.borderRadiusMedium,
                              ),
                              child: const Text('🫔', style: TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prod.nombre,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    pres.nombre,
                                    style: TextStyle(color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withOpacity(0.1),
                                borderRadius: AppTheme.borderRadiusSmall,
                              ),
                              child: Text(
                                formatter.format(pres.precio),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: cat.atributos.map((a) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.nombre,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: a.opciones.map((o) {
                                    final isSel = sel[a.codigo] == o.id;
                                    return GestureDetector(
                                      onTap: () => setSt(() {
                                        if (isSel) {
                                          sel.remove(a.codigo);
                                        } else {
                                          sel[a.codigo] = o.id;
                                        }
                                      }),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSel ? AppTheme.primaryBlue : AppTheme.lightBlue,
                                          borderRadius: AppTheme.borderRadiusMedium,
                                          border: Border.all(
                                            color: isSel ? AppTheme.primaryBlue : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                        child: Text(
                                          o.nombre + (o.precioExtra > 0 ? ' (+Q${o.precioExtra.toStringAsFixed(0)})' : ''),
                                          style: TextStyle(
                                            color: isSel ? Colors.white : AppTheme.primaryBlue,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: FilledButton(
                      onPressed: () {
                        _addProd(prod, pres, cat.atributos, sel);
                        Navigator.pop(ctx);
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: const Text('Agregar al Carrito', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addProd(Producto p, Presentacion pr, List<Atributo> attrs, Map<String, int> sel) {
    double ext = 0;
    final Map<String, dynamic> pers = {};
    for (var a in attrs) {
      final id = sel[a.codigo];
      if (id != null) {
        final o = a.opciones.firstWhere((x) => x.id == id);
        ext += o.precioExtra;
        pers[a.codigo] = {
          'opcionId': o.id,
          'nombre': o.nombre,
          'precioExtra': o.precioExtra,
        };
      }
    }
    final item = ItemCarrito(
      id: '${pr.id}-${DateTime.now().millisecondsSinceEpoch}',
      tipo: 'PRODUCTO',
      presentacionId: pr.id,
      nombre: '${p.nombre} - ${pr.nombre}',
      descripcion: sel.entries.map((e) {
        final at = attrs.firstWhere((x) => x.codigo == e.key);
        return at.opciones.firstWhere((x) => x.id == e.value).nombre;
      }).join(', '),
      cantidad: 1,
      precioUnitario: pr.precio,
      precioExtras: ext,
      subtotal: pr.precio + ext,
      personalizacion: pers,
    );
    context.read<CartProvider>().addItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('${p.nombre} agregado'),
          ],
        ),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addCombo(Combo c) {
    final item = ItemCarrito(
      id: 'combo-${c.id}-${DateTime.now().millisecondsSinceEpoch}',
      tipo: 'COMBO',
      comboId: c.id,
      nombre: c.nombre,
      descripcion: c.descripcion ?? '',
      cantidad: 1,
      precioUnitario: c.precio,
      precioExtras: 0,
      subtotal: c.precio,
    );
    context.read<CartProvider>().addItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('${c.nombre} agregado'),
          ],
        ),
        backgroundColor: AppTheme.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Consumer<CartProvider>(
            builder: (ctx, cart, _) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tu Carrito',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => cart.clear(),
                          icon: Icon(Icons.delete_outline, color: AppTheme.error),
                          label: Text('Vaciar', style: TextStyle(color: AppTheme.error)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: cart.items.length,
                      itemBuilder: (ctx, i) {
                        final it = cart.items[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceBlue,
                            borderRadius: AppTheme.borderRadiusMedium,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.nombre,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    if (it.descripcion.isNotEmpty)
                                      Text(
                                        it.descripcion,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => cart.updateQuantity(it.id, it.cantidad - 1),
                                    icon: Icon(Icons.remove_circle_outline, color: AppTheme.primaryBlue),
                                    iconSize: 28,
                                  ),
                                  Text(
                                    '${it.cantidad}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => cart.updateQuantity(it.id, it.cantidad + 1),
                                    icon: Icon(Icons.add_circle, color: AppTheme.primaryBlue),
                                    iconSize: 28,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatter.format(it.subtotal * it.cantidad),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.success,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          formatter.format(cart.total),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _pay() async {
    final cart = context.read<CartProvider>();
    final sucId = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusLarge),
        title: Row(
          children: [
            Icon(Icons.store, color: AppTheme.primaryBlue),
            const SizedBox(width: 12),
            const Text('Seleccionar Sucursal'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _sucursales.map((s) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceBlue,
                borderRadius: AppTheme.borderRadiusMedium,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryBlue,
                  child: const Icon(Icons.store, color: Colors.white, size: 20),
                ),
                title: Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(s.direccion ?? '', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                onTap: () => Navigator.pop(ctx, s.id),
              ),
            );
          }).toList(),
        ),
      ),
    );
    if (sucId == null) return;
    cart.setSucursal(sucId);
    try {
      final v = await _api.crearVenta(cart.toVentaJson());
      cart.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Venta ${v.codigo} registrada'),
              ],
            ),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.error),
        );
      }
    }
  }
}
