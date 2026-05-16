import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final profileServiceProvider =
    Provider<ProfileService>((ref) => ProfileService());

final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final profileProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('Not authenticated');
  return ref.read(profileServiceProvider).getProfile(user.id);
});

final userRoleProvider = FutureProvider.autoDispose<String>((ref) async {
  return ref.read(profileServiceProvider).getMyRole();
});
