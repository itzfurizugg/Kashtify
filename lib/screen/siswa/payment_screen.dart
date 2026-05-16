import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/iuran_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/siswa_bottom_nav.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unpaidAsync = ref.watch(myUnpaidPaymentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bayar Kas')),
      body: unpaidAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Gagal memuat tagihan: $e',
              style: const TextStyle(color: AppTheme.danger)),
        ),
        data: (payments) {
          if (payments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 72, color: AppTheme.secondary),
                  SizedBox(height: 16),
                  Text('Semua tagihan sudah lunas!',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                  SizedBox(height: 4),
                  Text('Tidak ada tagihan yang perlu dibayar.',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myUnpaidPaymentsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (ctx, i) {
                final p = payments[i];
                final iuran = p['iuran'] as Map<String, dynamic>? ?? {};
                final status = p['status'] as String? ?? 'belum_lunas';
                final notes = p['notes'] as String?;
                final isPending = notes == 'menunggu_konfirmasi';

                Color statusColor;
                String statusLabel;
                if (isPending) {
                  statusColor = AppTheme.warning;
                  statusLabel = 'Menunggu Konfirmasi';
                } else if (status == 'terlambat') {
                  statusColor = AppTheme.danger;
                  statusLabel = 'Terlambat';
                } else {
                  statusColor = AppTheme.textSecondary;
                  statusLabel = 'Belum Bayar';
                }

                final dueDate = iuran['due_date'] != null
                    ? DateTime.tryParse(iuran['due_date'])
                    : null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: isPending
                        ? null
                        : () => context.push('/payment/qris', extra: {
                              'iuranId': p['iuran_id'] as String,
                              'amount': iuran['amount'] ?? 0,
                              'title': iuran['title'] ?? '-',
                            }),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.receipt_long,
                                color: statusColor, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(iuran['title'] ?? '-',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15)),
                                const SizedBox(height: 2),
                                Text(
                                  formatRupiah(iuran['amount'] ?? 0),
                                  style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w600),
                                ),
                                if (dueDate != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Batas: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(statusLabel,
                                    style: TextStyle(
                                        color: statusColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ),
                              if (!isPending) ...[
                                const SizedBox(height: 6),
                                const Icon(Icons.chevron_right,
                                    color: AppTheme.textSecondary),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const SiswaBottomNav(currentIndex: 0),
    );
  }
}
