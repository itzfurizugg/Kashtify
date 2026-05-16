import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/iuran_service.dart';

final iuranServiceProvider = Provider<IuranService>((ref) => IuranService());

final myPaymentsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  return ref.read(iuranServiceProvider).getMyPayments(userId);
});

final myUnpaidPaymentsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  return ref.read(iuranServiceProvider).getMyUnpaidPayments(userId);
});

final myRecentPaymentsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser!.id;
  return ref.read(iuranServiceProvider).getMyRecentPayments(userId);
});

final pendingVerifikasiProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.read(iuranServiceProvider).getPendingVerifikasi();
});

final iuranSummaryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.read(iuranServiceProvider).getIuranSummary();
});

final siswaSummaryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.read(iuranServiceProvider).getSiswaSummary();
});
