import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/kas_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/siswa_bottom_nav.dart';

class MoneyScreen extends ConsumerWidget {
  const MoneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kasAsync = ref.watch(kasSummaryProvider);
    final txAsync = ref.watch(transactionsThisMonthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kas Kelas')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(kasSummaryProvider);
          ref.invalidate(transactionsThisMonthProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: kasAsync.when(
                  loading: () => const SizedBox(
                      height: 130,
                      child: Center(child: CircularProgressIndicator())),
                  error: (e, _) => Text('Error: $e',
                      style: const TextStyle(color: AppTheme.danger)),
                  data: (kas) => _KasSummaryCard(kas: kas),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month,
                        size: 18, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Transaksi Bulan Ini',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
            ),
            txAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: $e',
                      style: const TextStyle(color: AppTheme.danger)),
                ),
              ),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 56, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          const Text('Belum ada transaksi bulan ini',
                              style: TextStyle(color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final tx = transactions[i];
                      final type = tx['type'] as String? ?? '';
                      final isPemasukan = type == 'pemasukan';
                      final color =
                          isPemasukan ? AppTheme.secondary : AppTheme.danger;
                      final date = tx['date'] != null
                          ? DateTime.tryParse(tx['date'])
                          : null;
                      final profiles = tx['profiles'] as Map<String, dynamic>?;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withOpacity(0.1),
                              child: Icon(
                                isPemasukan
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: color,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              tx['description'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              '${profiles?['full_name'] ?? '-'} • ${date != null ? '${date.day}/${date.month}/${date.year}' : '-'}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Text(
                              '${isPemasukan ? '+' : '-'}${formatRupiah(tx['amount'] ?? 0)}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: transactions.length,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      bottomNavigationBar: const SiswaBottomNav(currentIndex: 2),
    );
  }
}

class _KasSummaryCard extends StatelessWidget {
  final Map<String, dynamic> kas;
  const _KasSummaryCard({required this.kas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Saldo Kas Kelas',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            formatRupiah(kas['saldo'] ?? 0),
            style: const TextStyle(
                color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatChip(
                  label: 'Pemasukan',
                  value: formatRupiah(kas['total_pemasukan'] ?? 0),
                  icon: Icons.arrow_upward,
                  color: const Color(0xFF69F0AE)),
              const SizedBox(width: 16),
              _StatChip(
                  label: 'Pengeluaran',
                  value: formatRupiah(kas['total_pengeluaran'] ?? 0),
                  icon: Icons.arrow_downward,
                  color: const Color(0xFFFF5252)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatChip(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 4),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ]),
    ]);
  }
}
