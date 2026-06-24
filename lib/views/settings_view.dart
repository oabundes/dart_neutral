import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/monitor_viewmodel.dart';
import '../config/app_theme.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _isDemoMode = true;
  bool _showBoronButton = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<MonitorViewModel>();
    _isDemoMode = vm.isDemoMode;
    _showBoronButton = vm.showBoronButton;
  }

  void _saveSettings() {
    context.read<MonitorViewModel>().saveSettings(
      demoMode: _isDemoMode,
      showBoron: _showBoronButton,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Modo Demo (Simulación)'),
              subtitle: const Text('Utiliza datos generados localmente'),
              activeThumbColor: AppTheme.solenisMint,
              value: _isDemoMode,
              onChanged: (val) {
                setState(() {
                  _isDemoMode = val;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Consulta a Boron'),
              activeThumbColor: AppTheme.solenisMint,
              value: _showBoronButton,
              onChanged: (val) {
                setState(() {
                  _showBoronButton = val;
                });
              },
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.solenisMint,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
                ),
                child: const Text('Guardar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
