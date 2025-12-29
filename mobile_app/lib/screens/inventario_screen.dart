import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final formatter = NumberFormat.currency(locale: 'es_GT', symbol: 'Q');
  late TabController _tabCtrl;
  List<MateriaPrima> _materias = [];
  List<Movimiento> _movimientos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
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
      final r = await Future.wait([_api.getMateriasPrimas(), _api.getMovimientos()]);
      setState(() {
        _materias = r[0] as List<MateriaPrima>;
        _movimientos = r[1] as List<Movimiento>;
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
        title: const Text('Inventario'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _load,
            icon: Icon(Icons.refresh_rounded, color: AppTheme.primaryBlue),
          ),
        ],
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
                Tab(text: '📦 Stock'),
                Tab(text: '📋 Movimientos'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewMov,
        icon: const Icon(Icons.add),
        label: const Text('Movimiento'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildMaterias(),
                _buildMovimientos(),
              ],
            ),
    );
  }

  Widget _buildMaterias() {
    if (_materias.isEmpty) {
      return _buildEmpty('Sin materias primas', Icons.inventory_2_outlined);
    }

    final grouped = <String, List<MateriaPrima>>{};
    for (var m in _materias) {
      grouped.putIfAbsent(m.categoria, () => []).add(m);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: AppTheme.borderRadiusSmall,
                    ),
                    child: Icon(Icons.category, color: AppTheme.primaryBlue, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            ...entry.value.map((m) => _buildMateriaCard(m)),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildMateriaCard(MateriaPrima m) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (m.stockActual <= m.stockMinimo * 0.5) {
      statusColor = AppTheme.error;
      statusText = 'CRÍTICO';
      statusIcon = Icons.error;
    } else if (m.stockActual <= m.stockMinimo) {
      statusColor = AppTheme.warning;
      statusText = 'BAJO';
      statusIcon = Icons.warning;
    } else {
      statusColor = AppTheme.success;
      statusText = 'OK';
      statusIcon = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderRadiusMedium,
        boxShadow: AppTheme.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: AppTheme.borderRadiusMedium,
              ),
              child: Icon(statusIcon, color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Stock: ',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      Text(
                        '${m.stockActual.toStringAsFixed(1)} ${m.unidadMedida}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        ' / Min: ${m.stockMinimo} ${m.unidadMedida}',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (m.stockActual / (m.stockMinimo * 2)).clamp(0, 1),
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(statusColor),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: AppTheme.borderRadiusSmall,
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovimientos() {
    if (_movimientos.isEmpty) {
      return _buildEmpty('Sin movimientos', Icons.history);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _movimientos.length,
      itemBuilder: (ctx, i) {
        final m = _movimientos[i];
        Color typeColor;
        IconData typeIcon;

        switch (m.tipo) {
          case 'ENTRADA':
            typeColor = AppTheme.success;
            typeIcon = Icons.add_circle;
            break;
          case 'SALIDA':
            typeColor = AppTheme.accentBlue;
            typeIcon = Icons.remove_circle;
            break;
          case 'MERMA':
            typeColor = AppTheme.error;
            typeIcon = Icons.delete;
            break;
          default:
            typeColor = AppTheme.textSecondary;
            typeIcon = Icons.swap_horiz;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppTheme.borderRadiusMedium,
            boxShadow: AppTheme.softShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: AppTheme.borderRadiusMedium,
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.materiaPrimaNombre,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.1),
                              borderRadius: AppTheme.borderRadiusSmall,
                            ),
                            child: Text(
                              m.tipo,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: typeColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(m.fecha),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (m.motivo != null && m.motivo!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          m.motivo!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${m.tipo == 'ENTRADA' ? '+' : '-'}${m.cantidad.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                    if (m.costoUnitario != null && m.costoUnitario! > 0)
                      Text(
                        formatter.format(m.costoUnitario),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
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

  Widget _buildEmpty(String text, IconData icon) {
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
            child: Icon(icon, size: 48, color: AppTheme.primaryBlue.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showNewMov() {
    int? materiaId;
    String tipo = 'ENTRADA';
    final cantCtrl = TextEditingController();
    final costoCtrl = TextEditingController();
    final motivoCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) {
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
                          child: const Icon(Icons.add_box, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Nuevo Movimiento',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Materia Prima',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceBlue,
                        borderRadius: AppTheme.borderRadiusMedium,
                      ),
                      child: DropdownButtonFormField<int>(
                        value: materiaId,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        hint: const Text('Seleccionar'),
                        items: _materias.map((m) {
                          return DropdownMenuItem(value: m.id, child: Text(m.nombre));
                        }).toList(),
                        onChanged: (v) => setSt(() => materiaId = v),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Tipo de Movimiento',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['ENTRADA', 'SALIDA', 'MERMA'].map((t) {
                        final sel = tipo == t;
                        Color c;
                        switch (t) {
                          case 'ENTRADA':
                            c = AppTheme.success;
                            break;
                          case 'SALIDA':
                            c = AppTheme.accentBlue;
                            break;
                          default:
                            c = AppTheme.error;
                        }
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setSt(() => tipo = t),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: sel ? c : c.withOpacity(0.1),
                                borderRadius: AppTheme.borderRadiusMedium,
                              ),
                              child: Center(
                                child: Text(
                                  t,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: sel ? Colors.white : c,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: cantCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '0.0',
                                  filled: true,
                                  fillColor: AppTheme.surfaceBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Costo (Q)', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: costoCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  filled: true,
                                  fillColor: AppTheme.surfaceBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Motivo', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: motivoCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Descripción del movimiento...',
                        filled: true,
                        fillColor: AppTheme.surfaceBlue,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () async {
                        if (materiaId == null || cantCtrl.text.isEmpty) return;
                        try {
                          await _api.registrarMovimiento({
                            'materiaPrimaId': materiaId,
                            'tipo': tipo,
                            'cantidad': double.parse(cantCtrl.text),
                            'costo': costoCtrl.text.isNotEmpty ? double.parse(costoCtrl.text) : 0,
                            'motivo': motivoCtrl.text,
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
                                    Text('Movimiento registrado'),
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
                      child: const Text('Registrar Movimiento', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
