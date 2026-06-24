import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/process_data.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

class MonitorViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SupabaseService _supabaseService = SupabaseService();

  ProcessData _data = ProcessData.empty();
  ProcessData get data => _data;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // --- Estado del comando Boron ---
  // Separado de _isLoading para que el botón tenga su propio spinner
  // sin bloquear el polling de datos del tanque.
  bool _enviandoComando = false;
  bool get enviandoComando => _enviandoComando;

  /// null = sin resultado todavía | true = OK | false = error
  bool? _comandoExitoso;
  bool? get comandoExitoso => _comandoExitoso;

  String _mensajeComando = '';
  String get mensajeComando => _mensajeComando;

  // Settings
  bool isDemoMode = true;
  bool showBoronButton = false;
  String get railwayUrl => dotenv.env['RAILWAY_URL'] ?? '';
  String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  String get supabaseKey => dotenv.env['SUPABASE_KEY'] ?? '';

  MonitorViewModel() {
    _loadSettings().then((_) {
      refreshData();
    });
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isDemoMode = prefs.getBool('isDemoMode') ?? true;
    showBoronButton = prefs.getBool('showBoronButton') ?? false;
    
    await _initSupabase();
  }

  Future<void> saveSettings({
    required bool demoMode,
    required bool showBoron,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDemoMode', demoMode);
    await prefs.setBool('showBoronButton', showBoron);

    isDemoMode = demoMode;
    showBoronButton = showBoron;
    
    notifyListeners();
    refreshData();
  }

  Future<void> _initSupabase() async {
    if (isDemoMode || supabaseUrl.isEmpty || supabaseKey.isEmpty) return;
    
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseKey,
      );
      _supabaseService.setClient(Supabase.instance.client);
    } catch (e) {
      debugPrint('Supabase init error: $e');
    }
  }

  Future<void> refreshData() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Obtenemos los datos desde el servicio en Railway (o datos simulados si isDemoMode == true)
      final rawData = await _apiService.fetchProcessData(railwayUrl, isDemoMode);
      final double level = rawData['nivel'];
      final double ph = rawData['ph'];
      final int step = rawData['step'];

      final desc = await _supabaseService.getStepDescription(step, isDemoMode);

      _data = ProcessData(
        level: level,
        ph: ph,
        step: step,
        stepDescription: desc,
      );
    } catch (e) {
      _errorMessage = 'Error al actualizar datos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Envía el comando [comando] al Boron a través del middleware de Railway.
  ///
  /// Usa [railwayUrl] (ya guardado en settings) como base URL.
  /// El estado [enviandoComando] se expone para que la UI deshabilite
  /// el botón y muestre un spinner durante la llamada.
  /// El resultado queda en [comandoExitoso] y [mensajeComando].
  Future<void> solicitarComando(String comando) async {
    // Evitar doble tap: si ya hay una petición en vuelo, ignorar
    if (_enviandoComando) return;

    _enviandoComando = true;
    _comandoExitoso = null;   // limpiar resultado anterior
    _mensajeComando = '';
    notifyListeners();

    String apiKey = dotenv.env['APP_API_KEY'] ?? '';

    // ApiService devuelve ComandoResult (nunca lanza), así que no
    // necesitamos try/catch aquí — el error ya viene empaquetado.
    final result = await _apiService.enviarComandoBoron(
      railwayUrl,
      comando,
      apiKey,
      isDemoMode: isDemoMode,
    );

    _enviandoComando = false;
    _comandoExitoso = result.ok;
    _mensajeComando = result.mensaje;
    notifyListeners();
  }

  /// Actualiza los datos de la vista usando la carga útil de FCM.
  void updateFromFCM(Map<String, dynamic> messageData) async {
    try {
      final String? levelStr = messageData['level']?.toString();
      final String? phStr = messageData['ph']?.toString();
      final String? stepStr = messageData['step']?.toString();

      if (levelStr == null && phStr == null && stepStr == null) return;

      final double newLevel = double.tryParse(levelStr ?? '') ?? _data.level;
      final double newPh = double.tryParse(phStr ?? '') ?? _data.ph;
      final int newStep = int.tryParse(stepStr ?? '') ?? _data.step;

      String newDesc = _data.stepDescription;

      // Si el paso cambió, obtener la nueva descripción de Supabase
      if (newStep != _data.step) {
        newDesc = await _supabaseService.getStepDescription(newStep, isDemoMode);
      }

      _data = ProcessData(
        level: newLevel,
        ph: newPh,
        step: newStep,
        stepDescription: newDesc,
      );
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error al actualizar desde FCM: $e');
    }
  }
}
