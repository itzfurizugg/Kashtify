import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../services/iuran_service.dart';

const _qrisString = 'YOUR_QRIS_STRING';

class QRISScreen extends ConsumerStatefulWidget {
  final String iuranId;
  final num amount;
  final String title;
  const QRISScreen({
    super.key,
    required this.iuranId,
    required this.amount,
    required this.title,
  });

  @override
  ConsumerState<QRISScreen> createState() => _QRISScreenState();
}

class _QRISScreenState extends ConsumerState<QRISScreen> {
  bool _loading = false;

  Future<void> _sudahBayar() async {
    setState(() => _loading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      await IuranService().submitPayment(widget.iuranId, userId);
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.pending_outlined, color: AppTheme.warning),
              SizedBox(width: 8),
              Text('Menunggu Verifikasi'),
            ],
          ),
          content: const Text(
            'Pembayaran sedang diverifikasi oleh bendahara. Kami akan memberi tahu kamu setelah dikonfirmasi.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${e.toString()}'),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran QRIS')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.receipt_long,
                      color: AppTheme.primary, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(widget.amount),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // QR Code
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'QRIS',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    QrImageView(
                      data: _qrisString,
                      size: 220,
                      version: QrVersions.auto,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Berlaku untuk semua e-wallet & m-banking',
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cara Bayar',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    ...[
                      '1. Buka aplikasi e-wallet atau mobile banking',
                      '2. Pilih menu scan QR / QRIS',
                      '3. Arahkan kamera ke QR Code di atas',
                      '4. Masukkan nominal sesuai tagihan',
                      '5. Konfirmasi pembayaran',
                      '6. Tekan tombol "Saya Sudah Bayar" di bawah',
                    ].map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(s,
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.textSecondary)),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _sudahBayar,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline),
                label: const Text('Saya Sudah Bayar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
