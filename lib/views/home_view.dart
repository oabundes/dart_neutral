import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../viewmodels/monitor_viewmodel.dart';
import '../config/app_theme.dart';
import 'widgets/tank_widget.dart';
import 'widgets/ph_widget.dart';
import 'widgets/step_widget.dart';
import 'settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    try {
      if (Firebase.apps.isEmpty) return;

      final messaging = FirebaseMessaging.instance;

      // Solicitar permiso de notificaciones (Android 13+, iOS)
      await messaging.requestPermission();

      // Obtener token del dispositivo — necesario para enviar notificaciones desde Railway
      final token = await messaging.getToken();
      print('[FCM Token] $token');

      // Escuchar mensajes cuando la app está en primer plano
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.data.isNotEmpty && mounted) {
          final vm = Provider.of<MonitorViewModel>(context, listen: false);
          vm.updateFromFCM(message.data);
        }
      });

      // Escuchar cuando el usuario toca la notificación estando en segundo plano
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.data.isNotEmpty && mounted) {
          final vm = Provider.of<MonitorViewModel>(context, listen: false);
          vm.updateFromFCM(message.data);
        }
      });

      // Procesar si la app estaba completamente cerrada y se abrió tocando la notificación
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null && initialMessage.data.isNotEmpty && mounted) {
        final vm = Provider.of<MonitorViewModel>(context, listen: false);
        vm.updateFromFCM(initialMessage.data);
      }

    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Image.asset(
          'assets/solenis_logo.png',
          height: 36,
          errorBuilder: (context, error, stackTrace) => const Text(
            'Solenis',
            style: TextStyle(
              color: AppTheme.diverseyNavy,
              fontWeight: FontWeight.w900,
              fontSize: 24,
            ),
          ),
        ),
        actions: [
          Consumer<MonitorViewModel>(
            builder: (context, vm, child) {
              return IconButton(
                icon: vm.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: AppTheme.solenisMint, strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                onPressed: vm.isLoading ? null : () => vm.refreshData(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsView()),
              );
            },
          ),
        ],
      ),
      body: Consumer<MonitorViewModel>(
        builder: (context, vm, child) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // --- Error de polling (datos del tanque) ---
                  if (vm.errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        vm.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // --- Título ---
                  const Text(
                    'Tanque de Neutralización',
                    style: TextStyle(
                      color: AppTheme.diverseyNavy,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // --- pH ---
                  PhWidget(phValue: vm.data.ph),
                  const SizedBox(height: 32),

                  // --- Tanque ---
                  TankWidget(level: vm.data.level),
                  const SizedBox(height: 32),

                  // --- Paso actual ---
                  StepWidget(
                    step: vm.data.step,
                    description: vm.data.stepDescription,
                  ),
                  const SizedBox(height: 32),

                  // --- Botón de consulta al Boron ---
                  _BoronCommandButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget separado para el botón de comando al Boron.
///
/// Al extraerlo de la lambda del Consumer principal se evita reconstruir
/// todo el árbol cada vez que cambia [enviandoComando] o [mensajeComando].
/// Solo este widget se redibuja cuando el usuario presiona el botón.
class _BoronCommandButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MonitorViewModel>(
      builder: (context, vm, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Separador visual antes del botón de acción
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity, // botón ancho completo, igual que los widgets
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.diverseyNavy,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppTheme.diverseyNavy.withValues(alpha: 0.4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // null en onPressed deshabilita el botón y aplica disabledBackgroundColor
                onPressed: vm.enviandoComando
                    ? null
                    : () => vm.solicitarComando('consulta'),
                icon: vm.enviandoComando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.sensors),
                label: Text(
                  vm.enviandoComando ? 'Enviando consulta…' : 'Consultar Boron',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Mensaje de resultado — solo visible tras la primera llamada
            if (vm.mensajeComando.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  // Verde si ok == true, rojo si ok == false
                  color: (vm.comandoExitoso == true
                          ? Colors.green
                          : Colors.red)
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (vm.comandoExitoso == true
                            ? Colors.green
                            : Colors.red)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      vm.comandoExitoso == true
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      size: 16,
                      color: vm.comandoExitoso == true
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vm.mensajeComando,
                        style: TextStyle(
                          fontSize: 13,
                          color: vm.comandoExitoso == true
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8), // respiro al final del scroll
          ],
        );
      },
    );
  }
}
