import 'package:flutter/material.dart';
import '../theme/auvix_theme.dart';

class MoneyScreen extends StatelessWidget {
  const MoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dinheiro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seu dinheiro',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Organize o dinheiro que você está reservando para investir.',
              style: TextStyle(
                color: AuvixTheme.muted,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AuvixTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF183A4A),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 32,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Reservado para investir',
                    style: TextStyle(
                      color: AuvixTheme.muted,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'R\$ 0,00',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    icon: Icons.savings_rounded,
                    title: 'Meta',
                    value: 'R\$ 0,00',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoCard(
                    icon: Icons.calendar_month_rounded,
                    title: 'Por mês',
                    value: 'R\$ 0,00',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            const Text(
              'Planejamento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.add_circle_outline_rounded,
              title: 'Registrar dinheiro',
              subtitle: 'Adicione um valor reservado para investir.',
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.flag_outlined,
              title: 'Definir meta',
              subtitle: 'Escolha quanto você pretende acumular.',
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _ActionCard(
              icon: Icons.history_rounded,
              title: 'Histórico de aportes',
              subtitle: 'Veja quanto você já conseguiu guardar.',
              onTap: () {},
            ),

            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AuvixTheme.surface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.insights_rounded,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'O objetivo do AUVIX é ajudar você a organizar o dinheiro antes, durante e depois dos seus investimentos.',
                      style: TextStyle(
                        color: AuvixTheme.muted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AuvixTheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 25),
          const SizedBox(height: 10),
          Text(
            title,
            style: const
