import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getProfile(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return data ?? {'full_name': 'Siswa Baru', 'nis': '-', 'role': 'siswa'};
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async =>
      await _supabase.from('profiles').update(data).eq('id', userId);

  Future<String> getMyRole() async {
    final profile = await getProfile(_supabase.auth.currentUser!.id);
    return profile['role'] as String;
  }
}
