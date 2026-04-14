import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/payment.dart';
import '../models/tontine.dart';
import '../models/zone_model.dart';
import '../services/firestore_service.dart';
import '../widgets/chart_widgets.dart';
import '../widgets/main_layout.dart';
import '../widgets/metric_card.dart';
import 'payments_screen.dart';
import 'tontines_screen.dart';
import 'users_screen.dart';
import 'zones_screen.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/dashboard';

  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreService _service = FirestoreService();
  List<ZoneModel>? _zones;
  List<TontineModel>? _tontines;
  List<PaymentModel>? _payments;
  List<AppUser>? _users;
  bool _isLoading = true;
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void _loadData() {
    setState(() => _isLoading = true);
    
    _subscriptions.add(_service.zonesStream().listen((zones) {
      if (mounted) {
        setState(() {
          _zones = zones;
          _isLoading = false;
        });
      }
    }));

    _subscriptions.add(_service.tontinesStream().listen((tontines) {
      if (mounted) {
        setState(() {
          _tontines = tontines;
        });
      }
    }));

    _subscriptions.add(_service.payementsStream().listen((payments) {
      if (mounted) {
        setState(() {
          _payments = payments;
        });
      }
    }));

    _subscriptions.add(_service.utilisateursStream().listen((users) {
      if (mounted) {
        setState(() {
          _users = users;
        });
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Tableau de bord',
      selectedIndex: 0,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: const _HeroCard(),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _buildMetricsGrid(),
              ),
            ),
          if (!_isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _buildChartsSection(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    if (_zones == null || _tontines == null || _payments == null || _users == null) {
      return const SizedBox.shrink();
    }

    final zones = _zones!;
    final tontines = _tontines!;
    final payments = _payments!;
    final users = _users!;

    final incomingPayments = payments.where((p) => p.type.toLowerCase() == 'depot' || p.type.toLowerCase() == 'entrant').toList();
    final outgoingPayments = payments.where((p) => p.type.toLowerCase() == 'retrait' || p.type.toLowerCase() == 'sortant').toList();

    final incomingTotal = incomingPayments.fold<double>(0, (sum, p) => sum + p.montant);
    final outgoingTotal = outgoingPayments.fold<double>(0, (sum, p) => sum + p.montant);
    final totalPayments = incomingTotal + outgoingTotal;

    final admins = users.where((u) => u.role.toLowerCase() == 'admin').toList();
    final agents = users.where((u) => u.role.toLowerCase() == 'agent').toList();
    final cotisants = users.where((u) => u.role.toLowerCase() == 'membre' || u.role.toLowerCase() == 'cotisant').toList();

    final activeTontines = tontines.length;
    final cancelledTontines = 0;

    return Column(
      children: [
        MetricCard(
          title: 'Zones',
          value: '${zones.length}',
          icon: Icons.location_on,
          color: const Color(0xFF866900),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Tontines',
                value: '${tontines.length}',
                subtitle: 'En cours: $activeTontines',
                icon: Icons.groups,
                color: const Color(0xFF866900),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                title: 'Annulées',
                value: '$cancelledTontines',
                icon: Icons.cancel,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Dépôts',
                value: '${incomingPayments.length}',
                subtitle: '${incomingTotal.toStringAsFixed(0)} CFA',
                icon: Icons.arrow_downward,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                title: 'Sorties',
                value: '${outgoingPayments.length}',
                subtitle: '${outgoingTotal.toStringAsFixed(0)} CFA',
                icon: Icons.arrow_upward,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MetricCard(
          title: 'Total Paiements',
          value: '${payments.length}',
          subtitle: '${totalPayments.toStringAsFixed(0)} CFA',
          icon: Icons.account_balance_wallet,
          color: const Color(0xFFFFC800),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Admins',
                value: '${admins.length}',
                icon: Icons.admin_panel_settings,
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricCard(
                title: 'Agents',
                value: '${agents.length}',
                icon: Icons.badge,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MetricCard(
          title: 'Cotisants',
          value: '${cotisants.length}',
          icon: Icons.people,
          color: const Color(0xFF866900),
        ),
        const SizedBox(height: 12),
        MetricCard(
          title: 'Total Utilisateurs',
          value: '${users.length}',
          icon: Icons.person,
          color: const Color(0xFFFFC800),
        ),
      ],
    );
  }

  Widget _buildChartsSection() {
    if (_zones == null || _tontines == null || _payments == null || _users == null) {
      return const SizedBox.shrink();
    }

    final zones = _zones!;
    final tontines = _tontines!;
    final payments = _payments!;
    final users = _users!;

    final incomingPayments = payments.where((p) => p.type.toLowerCase() == 'depot' || p.type.toLowerCase() == 'entrant').toList();
    final outgoingPayments = payments.where((p) => p.type.toLowerCase() == 'retrait' || p.type.toLowerCase() == 'sortant').toList();

    final admins = users.where((u) => u.role.toLowerCase() == 'admin').toList();
    final agents = users.where((u) => u.role.toLowerCase() == 'agent').toList();
    final cotisants = users.where((u) => u.role.toLowerCase() == 'membre' || u.role.toLowerCase() == 'cotisant').toList();

    final activeTontines = tontines.length;
    final cancelledTontines = 0;

    final tontinesPieData = [
      PieChartSectionData(
        value: activeTontines.toDouble(),
        title: 'En cours',
        color: const Color(0xFF866900),
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: cancelledTontines.toDouble(),
        title: 'Annulées',
        color: Colors.red,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];

    final paymentsPieData = [
      PieChartSectionData(
        value: incomingPayments.length.toDouble(),
        title: 'Dépôts',
        color: Colors.green,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: outgoingPayments.length.toDouble(),
        title: 'Sorties',
        color: Colors.red,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];

    final usersBarData = [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(
            toY: admins.length.toDouble(),
            color: Colors.purple,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(
            toY: agents.length.toDouble(),
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: cotisants.length.toDouble(),
            color: const Color(0xFF866900),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    ];

    final zonesBarData = zones.asMap().entries.map((entry) {
      final zoneId = entry.value.id;
      final tontinesInZone = tontines.where((t) => t.zoneID == zoneId).length;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: tontinesInZone.toDouble(),
            color: const Color(0xFF866900),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    final zoneLabels = zones.map((z) => z.nom.length > 3 ? z.nom.substring(0, 3) : z.nom).toList();

    return Column(
      children: [
        const SizedBox(height: 16),
        PieChartWidget(
          title: 'Répartition des Tontines',
          sections: tontinesPieData,
        ),
        const SizedBox(height: 16),
        PieChartWidget(
          title: 'Répartition des Paiements',
          sections: paymentsPieData,
        ),
        const SizedBox(height: 16),
        BarChartWidget(
          title: 'Utilisateurs par Rôle',
          barGroups: usersBarData,
          labels: ['Admins', 'Agents', 'Cotisants'],
        ),
        const SizedBox(height: 16),
        if (zones.isNotEmpty)
          BarChartWidget(
            title: 'Tontines par Zone',
            barGroups: zonesBarData,
            labels: zoneLabels,
          ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF866900),
            const Color(0xFF5C4706),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF866900).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenue sur DiagoTono',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gérez vos tontines, zones et paiements',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
