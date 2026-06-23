import 'package:flutter/material.dart';

class TankWidget extends StatelessWidget {
  final double level; // 0.0 to 100.0

  const TankWidget({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    // Ensure level is clamped between 0 and 100
    final validLevel = level.clamp(0.0, 100.0);
    final fillFraction = validLevel / 100.0;

    return Center(
      child: Container(
        width: 170,
        height: 280,
        decoration: BoxDecoration(
          // Cylinder shape: curved top and bottom
          borderRadius: const BorderRadius.vertical(
            top: Radius.elliptical(85, 12),
            bottom: Radius.elliptical(85, 12),
          ),
          // Metallic gradient
          gradient: const LinearGradient(
            colors: [
              Color(0xFF505050), // far left shadow
              Color(0xFFF0F0F0), // main highlight
              Color(0xFF909090), // mid body
              Color(0xFF303030), // far right shadow
            ],
            stops: [0.0, 0.25, 0.6, 1.0],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 15,
              offset: Offset(0, 10),
            )
          ],
          border: Border.all(
            color: Colors.black87,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            // Top rim shadow/highlight to simulate 3D cylinder edge
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.elliptical(85, 12),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            
            // Sight Glass (Left side)
            Positioned(
              left: 15,
              top: 25,
              bottom: 25,
              width: 65,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF101010), // Very dark interior
                      border: Border.all(color: Colors.grey.shade400, width: 2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOut,
                          height: constraints.maxHeight * fillFraction,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF00E5FF),
                                Color(0xFF0088CC),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          // Liquid glass highlight
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.6),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: const [0.0, 0.4],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Percentage Text (Right side)
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  '${validLevel.toInt()} %',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.black, // Dark text like the image
                    shadows: [
                      Shadow(
                        color: Colors.white54,
                        offset: Offset(1, 1),
                        blurRadius: 1,
                      )
                    ]
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
