import 'package:flutter/material.dart';
import 'package:client_app/core/theme/app_colors.dart';

/// Vignette overlay for the Unity creature viewport
///
/// Creates a radial gradient that darkens the edges of the screen,
/// adding depth and focus to the central creature.
///
/// This widget is placed as Layer 1 in the home screen Stack:
/// Stack → UnityWidget → VignetteOverlay → HUD
///
/// Design spec: "The glass of the containment chamber"
class VignetteOverlay extends StatelessWidget {
  const VignetteOverlay({
    super.key,
    this.intensity = 0.7,
  });

  /// Vignette darkness intensity (0.0 = none, 1.0 = maximum)
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Colors.transparent, // Center stays transparent
              AppColors.voidBlack.withOpacity(intensity), // Edges darken
            ],
            stops: const [
              0.3, // Gradient starts fading at 30% from center
              1.0, // Full darkness at edges
            ],
          ),
        ),
      ),
    );
  }
}
