import 'package:flutter/material.dart';
import '../core/theme.dart';

class GlowBackground extends StatelessWidget {
  final Widget child;

  const GlowBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Background black color
        Container(
          color: MUOPTheme.background,
        ),
        
        // Top right soft yellow glow
        Positioned(
          top: -size.height * 0.2,
          right: -size.width * 0.15,
          child: IgnorePointer(
            child: Container(
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    MUOPTheme.primaryYellow.withOpacity(0.08),
                    MUOPTheme.primaryYellow.withOpacity(0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Left middle soft orange/yellow glow
        Positioned(
          top: size.height * 0.4,
          left: -size.width * 0.2,
          child: IgnorePointer(
            child: Container(
              width: size.width * 0.6,
              height: size.width * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    MUOPTheme.primaryYellow.withOpacity(0.06),
                    MUOPTheme.primaryYellow.withOpacity(0.01),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Bottom right soft glow
        Positioned(
          bottom: -size.height * 0.1,
          right: -size.width * 0.1,
          child: IgnorePointer(
            child: Container(
              width: size.width * 0.4,
              height: size.width * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    MUOPTheme.primaryYellow.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // Main app content
        child,
      ],
    );
  }
}
