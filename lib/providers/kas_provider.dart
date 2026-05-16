import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/kas_service.dart';

final kasServiceProvider = Provider<KasService>((ref) => KasService());

final kasSummaryProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.read(kasServiceProvider).getKasSummary();
});

final transactionsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.read(kasServiceProvider).getTransactions();
});

final transactionsThisMonthProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.read(kasServiceProvider).getTransactionsThisMonth();
});
