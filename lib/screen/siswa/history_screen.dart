import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/iuran_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/siswa_bottom_nav.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(myPaymentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Iuran')),
      body: paymentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child:
              Text('Error: $e', style: const TextStyle(color: AppTheme.danger)),
        ),
        data: (payments) {
          if (payments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 72, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Belum ada riwayat iuran',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myPaymentsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (ctx, i) {
                final p = payments[i];
                final iuran = p['iuran'] as Map<String, dynamic>? ?? {};
                final status = p['status'] as String? ?? 'belum_lunas';
                final notes = p['notes'] as String?;
                final paidAt = p['paid_at'] != null
                    ? DateTime.tryParse(p['paid_at'])
                    : null;

                Color badgeColor;
                String badgeLabel;
                IconData statusIcon;

                if (notes == 'menunggu_konfirmasi') {
                  badgeColor = AppTheme.pending;
                  badgeLabel = 'Menunggu Konfirmasi';
                  statusIcon = Icons.hourglass_top;
                } else if (status == 'lunas') {
                  badgeColor = AppTheme.secondary;
                  badgeLabel = 'Lunas';
                  statusIcon = Icons.check_circle;
                } else if (status == 'terlambat') {
                  badgeColor = AppTheme.danger;
                  badgeLabel = 'Terlambat';
                  statusIcon = Icons.warning_amber;
                } else {
                  badgeColor = AppTheme.textSecondary;
                  badgeLabel = 'Belum Bayar';
                  statusIcon = Icons.radio_button_unchecked;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(statusIcon, color: badgeColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                iuran['title'] ?? '-',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatRupiah(iuran['amount'] ?? 0),
                                style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600),
                              ),
                              if (paidAt != null)
                                Text(
                                  'Dibayar: ${paidAt.day}/${paidAt.month}/${paidAt.year}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            badgeLabel,
                            style: TextStyle(
                                color: badgeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const SiswaBottomNav(currentIndex: 1),
    );
  }
}
