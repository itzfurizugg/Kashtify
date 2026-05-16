import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kas_provider.dart';
import '../../providers/iuran_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../widgets/siswa_bottom_nav.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final kasAsync = ref.watch(kasSummaryProvider);
    final recentPayAsync = ref.watch(myRecentPaymentsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(profileProvider);
          ref.invalidate(kasSummaryProvider);
          ref.invalidate(myRecentPaymentsProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
                  child: profileAsync.when(
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                    data: (p) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Halo, ${p['full_name'] ?? 'Siswa'} 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'NIS: ${p['nis'] ?? '-'}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.white),
                  onPressed: () => context.push('/profile'),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Kas Summary Card
                  kasAsync.when(
                    loading: () => const _LoadingCard(height: 140),
                    error: (e, _) => _ErrorCard(message: e.toString()),
                    data: (kas) => _KasSummaryCard(kas: kas),
                  ),
                  const SizedBox(height: 20),

                  // Quick Actions
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.qr_code,
                          label: 'Bayar Kas',
                          color: AppTheme.primary,
                          onTap: () => context.push('/payment'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.request_page,
                          label: 'Ajukan Dana',
                          color: AppTheme.secondary,
                          onTap: () => context.push('/request-fund'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Status Iuran
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Status Iuran Saya',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/history'),
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  recentPayAsync.when(
                    loading: () => const _LoadingCard(height: 120),
                    error: (e, _) => _ErrorCard(message: e.toString()),
                    data: (payments) => payments.isEmpty
                        ? const _EmptyState(
                            icon: Icons.check_circle_outline,
                            message: 'Tidak ada tagihan aktif',
                          )
                        : Column(
                            children: payments
                                .map((p) => _PaymentItem(payment: p))
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const SiswaBottomNav(currentIndex: 0),
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
          colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
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
          const Text('Saldo Kas Kelas',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            formatRupiah(kas['saldo'] ?? 0),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _KasStatItem(
                  label: 'Pemasukan',
                  value: formatRupiah(kas['total_pemasukan'] ?? 0),
                  icon: Icons.arrow_upward,
                  color: const Color(0xFF69F0AE),
                ),
              ),
              Expanded(
                child: _KasStatItem(
                  label: 'Pengeluaran',
                  value: formatRupiah(kas['total_pengeluaran'] ?? 0),
                  icon: Icons.arrow_downward,
                  color: const Color(0xFFFF5252),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KasStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _KasStatItem(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white60, fontSize: 11)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class _PaymentItem extends StatelessWidget {
  final Map<String, dynamic> payment;
  const _PaymentItem({required this.payment});

  @override
  Widget build(BuildContext context) {
    final iuran = payment['iuran'] as Map<String, dynamic>? ?? {};
    final status = payment['status'] as String? ?? 'belum_lunas';
    final notes = payment['notes'] as String?;

    String label;
    Color color;
    if (notes == 'menunggu_konfirmasi') {
      label = 'Menunggu Konfirmasi';
      color = AppTheme.pending;
    } else if (status == 'lunas') {
      label = 'Lunas';
      color = AppTheme.secondary;
    } else if (status == 'terlambat') {
      label = 'Terlambat';
      color = AppTheme.danger;
    } else {
      label = 'Belum Bayar';
      color = AppTheme.textSecondary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.receipt_long, color: color, size: 20),
        ),
        title: Text(
          iuran['title'] ?? '-',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(formatRupiah(iuran['amount'] ?? 0)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({required this.height});

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error: $message',
              style: const TextStyle(color: AppTheme.danger)),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
}
