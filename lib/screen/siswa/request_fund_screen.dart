import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/kas_service.dart';
import '../../core/theme/app_theme.dart';

class RequestFundScreen extends ConsumerStatefulWidget {
  const RequestFundScreen({super.key});

  @override
  ConsumerState<RequestFundScreen> createState() => _RequestFundScreenState();
}

class _RequestFundScreenState extends ConsumerState<RequestFundScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keperluanCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _keperluanCtrl.dispose();
    _jumlahCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _ajukan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final amount = int.tryParse(
              _jumlahCtrl.text.replaceAll('.', '').replaceAll(',', '')) ??
          0;
      await KasService().insertTransaction({
        'created_by': userId,
        'type': 'pengeluaran',
        'amount': amount,
        'description':
            '[PENGAJUAN] ${_keperluanCtrl.text.trim()} - ${_deskripsiCtrl.text.trim()}',
        'date': DateTime.now().toIso8601String(),
      });
      if (!mounted) return;
      _formKey.currentState!.reset();
      _keperluanCtrl.clear();
      _jumlahCtrl.clear();
      _deskripsiCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Pengajuan berhasil, menunggu persetujuan bendahara'),
          backgroundColor: AppTheme.secondary,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengajukan: ${e.toString()}'),
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
      appBar: AppBar(title: const Text('Ajukan Dana')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.warning, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pengajuan dana akan diteruskan ke bendahara untuk disetujui.',
                        style: TextStyle(fontSize: 13, color: AppTheme.warning),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _keperluanCtrl,
                decoration: const InputDecoration(
                  labelText: 'Keperluan',
                  prefixIcon: Icon(Icons.edit_note),
                  hintText: 'Contoh: Pembelian alat tulis',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Keperluan wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Dana (Rp)',
                  prefixIcon: Icon(Icons.payments_outlined),
                  hintText: 'Contoh: 150000',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Jumlah wajib diisi';
                  final n =
                      int.tryParse(v.replaceAll('.', '').replaceAll(',', ''));
                  if (n == null || n <= 0) return 'Masukkan nominal yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi / Alasan',
                  prefixIcon: Icon(Icons.description_outlined),
                  hintText: 'Jelaskan keperluan penggunaan dana...',
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _ajukan,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send),
                  label: const Text('Ajukan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
