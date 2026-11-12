import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'profile_screen.dart';

import '../models/asset_position.dart';
import '../services/portfolio_service.dart';
import '../theme/auvix_theme.dart';
import '../widgets/market_ticker.dart';
import '../widgets/home_sections.dart';
import '../widgets/economy_news_section.dart';

import 'add_asset_screen.dart';
import 'asset_detail_screen.dart';
import 'compound_interest_screen.dart';
import 'my_assets_screen.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({
    super.key,
    this.onOpenAlerts,
  });

  final VoidCallback? onOpenAlerts;

  @override
  State<PortfolioScreen> createState() => PortfolioScreenState();
}

class PortfolioScreenState extends State<PortfolioScreen> {
  static const List<String> _avatarAssets = [
    'assets/avatars/avatar_01.png',
    'assets/avatars/avatar_02.png',
    'assets/avatars/avatar_03.png',
    'assets/avatars/avatar_04.png',
    'assets/avatars/avatar_05.png',
    'assets/avatars/avatar_06.png',
    'assets/avatars/avatar_07.png',
    'assets/avatars/avatar_08.png',
    'assets/avatars/avatar_09.png',
    'assets/avatars/avatar_10.png',
    'assets/avatars/avatar_11.png',
    'assets/avatars/avatar_12.png',
  ];

  late List<AssetPosition> positions;
  double _personalAssetsTotal = 0;
  String _profileName = '';
  int _profileAvatar = 0;

  @override
  void initState() {
    super.initState();
    positions = PortfolioService.demoPortfolio();
    _loadPersonalAssetsTotal();
    refreshProfileData();
  }

  Future<void> refreshProfileData() async {
    final user = Supabase.instance.client.auth.currentUser;
    final preferences = await SharedPreferences.getInstance();

    final savedName = user?.userMetadata?['full_name'];
    final userId = user?.id ?? 'unknown';
    final savedAvatar =
        preferences.getInt('auvix_profile_avatar_$userId') ?? 0;

    if (!mounted) return;

    setState(() {
      _profileName = savedName is String ? savedName.trim() : '';
      _profileAvatar = savedAvatar >= 0 && savedAvatar < _avatarAssets.length
          ? savedAvatar
          : 0;
    });
  }

  Future<void> _openProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );

    if (mounted) {
      await refreshProfileData();
    }
  }

  double get total => positions.fold(0, (sum, item) => sum + item.currentValue);

  double get invested => positions.fold(0, (sum, item) => sum + item.invested);

  double get profit => total - invested;

  void _addAsset() async {
    final position = await Navigator.of(context).push<AssetPosition>(
      MaterialPageRoute(builder: (_) => const AddAssetScreen()),
    );

    if (position != null) {
      setState(() {
        positions.add(position);
      });
    }
  }

  Future<void> _loadPersonalAssetsTotal() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('auvix_personal_assets');
    double sum = 0;

    if (saved != null) {
      try {
        final items = (jsonDecode(saved) as List);
        for (final item in items) {
          sum += (item['value'] as num).toDouble();
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _personalAssetsTotal = sum);
    }
  }

  Future<void> _openPersonalAssets() async {
    await Navigator.of(context)
        .push<void>(MaterialPageRoute(builder: (_) => const MyAssetsScreen()));

    await _loadPersonalAssetsTotal();
  }

  @override
  Widget build(BuildContext context) {
    final profitPercent = invested == 0 ? 0 : profit / invested * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AUVIX',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        actions: [
          IconButton(
            onPressed: widget.onOpenAlerts,
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: InkWell(
              onTap: _openProfile,
              customBorder: const CircleBorder(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AuvixTheme.surface2,
                  shape: BoxShape.circle,
                  border: Border.all(color: AuvixTheme.accent, width: 1.8),
                ),
                child: ClipOval(
                  child: Image.asset(
                    _avatarAssets[_profileAvatar],
                    fit: BoxFit.contain,
                    width: 34,
                    height: 34,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Row(
            children: [
              const Text(
                'Olá! 👋',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              if (_profileName.isNotEmpty) ...[
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    _profileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AuvixTheme.accent,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 4),

          const Text(
            'Seu portfólio está em movimento.',
            style: TextStyle(color: AuvixTheme.muted),
          ),

          const MarketTicker(),
          const SizedBox(height: 18),

          _PortfolioCard(
            total: _personalAssetsTotal,
            onTap: _openPersonalAssets,
          ),

          const SizedBox(height: 18),
          const WealthAndDebtCards(),

          const HomeShortcuts(),
          const SizedBox(height: 22),
          const EconomyNewsSection(),
          const SizedBox(height: 22),
          const LearnInvestingBanner(),
          const SizedBox(height: 22),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AuvixTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF183A4A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calculate_rounded, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Calculadora',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  'Simule o crescimento do seu dinheiro com juros compostos.',
                  style: TextStyle(color: AuvixTheme.muted),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CompoundInterestScreen(),
                        ),
                      );
                    },
                    child: const Text('🧮 CALCULAR'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),
        ],
      ),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  final double total;
  final VoidCallback onTap;

  const _PortfolioCard({required this.total, required this.onTap});

  String money(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AuvixTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF183A4A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patrimônio total',
              style: TextStyle(color: AuvixTheme.muted),
            ),
            const SizedBox(height: 4),
            Text(
              money(total),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Toque para gerenciar seus bens',
              style: TextStyle(
                color: AuvixTheme.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssetTile extends StatelessWidget {
  final AssetPosition position;
  final VoidCallback onTap;

  const _AssetTile({required this.position, required this.onTap});

  String money(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final variation = position.currentValue - position.invested;

    return Card(
      color: AuvixTheme.surface,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(
            position.ticker.substring(
              0,
              position.ticker.length > 2 ? 2 : position.ticker.length,
            ),
          ),
        ),
        title: Text(
          position.ticker,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('${position.quantity} ativos'),
        trailing: Text(
          money(variation),
          style: TextStyle(
            color: variation >= 0 ? AuvixTheme.accent : Colors.redAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
