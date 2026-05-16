import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<void> signIn(String email, String password) async =>
      await _supabase.auth.signInWithPassword(email: email, password: password);

  Future<void> signUp(
    String email,
    String password,
    String fullName,
    String nis,
  ) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'nis': nis,
        'role': 'siswa',
      },
    );
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      try {
        await _supabase.from('profiles').upsert({
          'id': userId,
          'nis': nis,
          'full_name': fullName,
          // role default 'siswa' biar gak error karena enum
        });
      } catch (e) {
        print('Upsert profile gagal (mungkin masalah Enum/RLS): $e');
      }
    }
  }

  Future<void> signOut() async => await _supabase.auth.signOut();

  Session? get currentSession => _supabase.auth.currentSession;
  User? get currentUser => _supabase.auth.currentUser;
}
