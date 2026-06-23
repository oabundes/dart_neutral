import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseClient? _client;

  /// Initializes the Supabase client with the provided URL and Anon Key.
  Future<void> initialize(String url, String anonKey) async {
    if (url.trim().isEmpty || anonKey.trim().isEmpty) return;
    
    // Only initialize if not already initialized with the same credentials
    if (_client != null) {
      // In a real scenario we'd dispose the old client, but supabase_flutter 
      // uses a singleton for Supabase.instance. We'll handle the instance setup in ViewModel.
      return;
    }
  }

  void setClient(SupabaseClient client) {
    _client = client;
  }

  /// Fetches the description for a given step.
  Future<String> getStepDescription(int step, bool isDemoMode) async {
    if (isDemoMode || _client == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      return 'Descripción simulada para el paso $step (Modo Demo)';
    }

    try {
      final response = await _client!
          .from('pasos')
          .select()
          .eq('step', step)
          .maybeSingle();

      print('--- SUPABASE RESPONSE for step $step ---');
      print(response);

      if (response != null) {
        // Intenta buscar tanto en minúsculas como en mayúsculas de manera directa
        if (response.containsKey('descripcion')) {
          return response['descripcion'].toString();
        } else if (response.containsKey('DESCRIPCION')) {
          return response['DESCRIPCION'].toString();
        }
      }
      return 'Descripción no encontrada (response: $response)';
    } catch (e) {
      print('--- SUPABASE ERROR for step $step ---');
      print(e);
      return 'Error al obtener descripción: $e';
    }
  }
}
