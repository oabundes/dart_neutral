import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class ApiService {
  final Random _random = Random();

  /// Fetches process data from the middleware.
  /// If [isDemoMode] is true or [url] is empty, returns simulated data.
  Future<Map<String, dynamic>> fetchProcessData(String url, bool isDemoMode) async {
    if (isDemoMode || url.trim().isEmpty) {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));
      return {
        'nivel': 40.0 + _random.nextDouble() * 20.0, // Nivel entre 40 y 60
        'ph': 6.5 + _random.nextDouble() * 1.5,      // pH entre 6.5 y 8.0
        'step': _random.nextInt(5),                  // Paso entre 0 y 4
      };
    }

    try {
      final uri = Uri.parse('${url.replaceAll(RegExp(r'/$'), '')}/estado');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        // Verificar si el servidor devolvió HTML (probablemente la página raíz por defecto)
        if (response.body.trim().startsWith('<')) {
          throw Exception('La ruta proporcionada en RAILWAY_URL ($url) devuelve una página web, no datos. Verifica si falta añadir el endpoint (ej. /estado o /api/data).');
        }
        
        try {
          final data = json.decode(response.body);
          return {
            'nivel': (data['level'] ?? data['nivel'] ?? 0).toDouble(), // Soporta 'level' que viene de Redis
            'ph': (data['ph'] ?? 0).toDouble(),
            'step': data['step'] ?? 0,
          };
        } catch (e) {
          throw Exception('El servidor no devolvió un JSON válido: $e');
        }
      } else {
        throw Exception('El servidor respondió con código HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  /// Sends a command to the Boron device via the Railway middleware.
  ///
  /// [baseUrl] is the Railway root URL (same one stored in settings, e.g.
  ///   "https://my-app.up.railway.app"). The method appends "/comando-boron".
  /// [comando] is the command string, e.g. "consulta".
  /// [isDemoMode] skips the real request and returns a simulated success.
  ///
  /// Returns a [ComandoResult] with [ok] and a human-readable [mensaje].
  Future<ComandoResult> enviarComandoBoron(
    String baseUrl,
    String comando, 
    String apiKey,
    {   bool isDemoMode = false,
  }) async {
    // In demo mode, simulate a short delay and return success
    if (isDemoMode || baseUrl.trim().isEmpty) {
      await Future.delayed(const Duration(milliseconds: 600));
      return ComandoResult(ok: true, mensaje: '[Demo] Comando "$comando" simulado');
    }

    // Build the endpoint URL — strip any trailing slash from baseUrl first
    final uri = Uri.parse('${baseUrl.trimRight()}/comando-boron');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json',
                  'x-api-key': apiKey
                  },
        body: jsonEncode({'comando': comando}),
      ).timeout(
        // Hard timeout so the UI doesn't hang if Railway is unresponsive
        const Duration(seconds: 8),
        onTimeout: () => throw Exception('Timeout: el middleware no respondió'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final bool ok = data['ok'] == true;
        final String mensaje = (data['mensaje'] ?? data['error'] ?? '').toString();
        return ComandoResult(ok: ok, mensaje: mensaje);
      } else {
        return ComandoResult(
          ok: false,
          mensaje: 'Error HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      // Re-wrap so the ViewModel gets a clean ComandoResult instead of a raw exception
      return ComandoResult(ok: false, mensaje: 'Error de conexión: $e');
    }
  }
}

/// Simple value object that carries the result of [enviarComandoBoron].
///
/// Using a dedicated class (instead of Map<String,dynamic>) makes the
/// ViewModel and UI code more readable and type-safe.
class ComandoResult {
  final bool ok;
  final String mensaje;

  const ComandoResult({required this.ok, required this.mensaje});
}
