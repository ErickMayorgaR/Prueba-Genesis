import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class SucursalesScreen extends StatefulWidget {
  const SucursalesScreen({super.key});

  @override
  State<SucursalesScreen> createState() => _SucursalesScreenState();
}

class _SucursalesScreenState extends State<SucursalesScreen> {
  final ApiService _api = ApiService();
  List<Sucursal> _sucursales = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final s = await _api.getSucursales();
      setState(() {
        _sucursales = s;
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
        title: const Text('Sucursales'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _load,
            icon: Icon(Icons.refresh_rounded, color: AppTheme.primaryBlue),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewSucursal,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Sucursal'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sucursales.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppTheme.primaryBlue,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _sucursales.length,
                    itemBuilder: (ctx, i) => _buildSucursalCard(_sucursales[i]),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store_outlined,
              size: 48,
              color: AppTheme.primaryBlue.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sin sucursales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega tu primera sucursal',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _showNewSucursal,
            icon: const Icon(Icons.add),
            label: const Text('Crear Sucursal'),
          ),
        ],
      ),
    );
  }

  Widget _buildSucursalCard(Sucursal s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderRadiusMedium,
        boxShadow: AppTheme.softShadow,
        border: s.activo ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: s.activo
                    ? AppTheme.success.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: AppTheme.borderRadiusMedium,
              ),
              child: Icon(
                Icons.store,
                color: s.activo ? AppTheme.success : Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: s.activo ? AppTheme.textPrimary : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: s.activo
                              ? AppTheme.success.withOpacity(0.1)
                              : Colors.grey.shade100,
                          borderRadius: AppTheme.borderRadiusSmall,
                        ),
                        child: Text(
                          s.activo ? 'Activa' : 'Inactiva',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: s.activo ? AppTheme.success : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (s.direccion != null && s.direccion!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            s.direccion!,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (s.telefono != null && s.telefono!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          s.telefono!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton(
              icon: Icon(Icons.more_vert, color: AppTheme.textSecondary),
              shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusMedium),
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  onTap: () => Future.delayed(Duration.zero, () => _deleteSucursal(s)),
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                      const SizedBox(width: 12),
                      Text('Eliminar', style: TextStyle(color: AppTheme.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNewSucursal() {
    final nombreCtrl = TextEditingController();
    final dirCtrl = TextEditingController();
    final telCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: AppTheme.borderRadiusMedium,
                      ),
                      child: const Icon(Icons.store, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Nueva Sucursal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Nombre *', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                TextField(
                  controller: nombreCtrl,
                  decoration: InputDecoration(
                    hintText: 'Ej: Sucursal Centro',
                    prefixIcon: Icon(Icons.store_outlined, color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surfaceBlue,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Dirección', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                TextField(
                  controller: dirCtrl,
                  decoration: InputDecoration(
                    hintText: 'Dirección completa...',
                    prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surfaceBlue,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Teléfono', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                TextField(
                  controller: telCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Ej: 5555-1234',
                    prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surfaceBlue,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () async {
                    if (nombreCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('El nombre es requerido'),
                          backgroundColor: AppTheme.error,
                        ),
                      );
                      return;
                    }
                    try {
                      await _api.createSucursal({
                        'nombre': nombreCtrl.text,
                        'direccion': dirCtrl.text,
                        'telefono': telCtrl.text,
                        'activo': true,
                      });
                      Navigator.pop(ctx);
                      _load();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 12),
                                Text('Sucursal creada'),
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
                  },
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  child: const Text('Crear Sucursal', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteSucursal(Sucursal s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.borderRadiusLarge),
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.error.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.delete_outline, color: AppTheme.error, size: 32),
        ),
        title: const Text('Eliminar Sucursal'),
        content: Text('¿Eliminar la sucursal "${s.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _api.deleteSucursal(s.id);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Sucursal eliminada'),
              ],
            ),
            backgroundColor: AppTheme.warning,
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
