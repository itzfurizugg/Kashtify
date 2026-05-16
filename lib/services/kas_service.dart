import 'package:supabase_flutter/supabase_flutter.dart';

class KasService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getKasSummary() async =>
      await _supabase.from('kas_summary').select().single();

  Future<List<Map<String, dynamic>>> getTransactions() async => await _supabase
      .from('transactions')
      .select('*, profiles(full_name)')
      .order('date', ascending: false);

  Future<List<Map<String, dynamic>>> getTransactionsThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    return await _supabase
        .from('transactions')
        .select('*, profiles(full_name)')
        .gte('date', startOfMonth)
        .order('date', ascending: false);
  }

  Future<void> insertTransaction(Map<String, dynamic> data) async =>
      await _supabase.from('transactions').insert(data);
}
