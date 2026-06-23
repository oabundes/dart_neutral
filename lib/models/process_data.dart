class ProcessData {
  final double level;
  final double ph;
  final int step;
  final String stepDescription;

  ProcessData({
    required this.level,
    required this.ph,
    required this.step,
    required this.stepDescription,
  });

  factory ProcessData.empty() {
    return ProcessData(
      level: 0.0,
      ph: 0.0,
      step: 0,
      stepDescription: 'Cargando...',
    );
  }

  ProcessData copyWith({
    double? level,
    double? ph,
    int? step,
    String? stepDescription,
  }) {
    return ProcessData(
      level: level ?? this.level,
      ph: ph ?? this.ph,
      step: step ?? this.step,
      stepDescription: stepDescription ?? this.stepDescription,
    );
  }
}
