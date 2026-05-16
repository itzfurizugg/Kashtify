import 'package:supabase_flutter/supabase_flutter.dart';

class IuranService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getMyPayments(String siswaId) async =>
      await _supabase
          .from('iuran_payments')
          .select('*, iuran(title, amount, due_date)')
          .eq('siswa_id', siswaId)
          .order('created_at', ascending: false);

  Future<List<Map<String, dynamic>>> getMyUnpaidPayments(
          String siswaId) async =>
      await _supabase
          .from('iuran_payments')
          .select('*, iuran(title, amount, due_date, description)')
          .eq('siswa_id', siswaId)
          .neq('status', 'lunas')
          .order('created_at', ascending: false);

  Future<List<Map<String, dynamic>>> getMyRecentPayments(
          String siswaId) async =>
      await _supabase
          .from('iuran_payments')
          .select('*, iuran(title, amount, due_date)')
          .eq('siswa_id', siswaId)
          .order('created_at', ascending: false)
          .limit(3);

  Future<List<Map<String, dynamic>>> getPendingVerifikasi() async =>
      await _supabase
          .from('iuran_payments')
          .select('*, profiles(full_name, nis), iuran(title, amount)')
          .eq('notes', 'menunggu_konfirmasi')
          .neq('status', 'lunas');

  Future<void> createIuran(Map<String, dynamic> data) async =>
      await _supabase.from('iuran').insert(data);

  Future<void> konfirmasiLunas(String paymentId, String bendaharaId) async =>
      await _supabase.from('iuran_payments').update({
        'status': 'lunas',
        'confirmed_by': bendaharaId,
        'paid_at': DateTime.now().toIso8601String(),
        'notes': null,
      }).eq('id', paymentId);

  Future<void> tolakPembayaran(String paymentId) async =>
      await _supabase.from('iuran_payments').update({
        'notes': null,
      }).eq('id', paymentId);

  Future<void> submitPayment(String iuranId, String siswaId) async =>
      await _supabase
          .from('iuran_payments')
          .update({
            'notes': 'menunggu_konfirmasi',
          })
          .eq('iuran_id', iuranId)
          .eq('siswa_id', siswaId);

  Future<List<Map<String, dynamic>>> getIuranSummary() async => await _supabase
      .from('iuran_summary')
      .select()
      .order('due_date', ascending: false);

  Future<List<Map<String, dynamic>>> getSiswaSummary() async => await _supabase
      .from('siswa_payment_summary')
      .select()
      .order('total_tunggakan', ascending: false);
}
