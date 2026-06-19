import 'package:flutter/material.dart';
import '../core/theme.dart';

class GlassCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool animateHover;
  final Color? hoverBorderColor;
  final Color? hoverGlowColor;
  final VoidCallback? onTap;
  final bool isHighlighted;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(24),
    this.animateHover = true,
    this.hoverBorderColor,
    this.hoverGlowColor,
    this.onTap,
    this.isHighlighted = false,
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeHover = widget.animateHover && _isHovered;
    final isHighlighted = widget.isHighlighted;
    
    // Borders
    Color currentBorderColor = MUOPTheme.border;
    if (isHighlighted) {
      currentBorderColor = MUOPTheme.primaryYellow;
    } else if (activeHover) {
      currentBorderColor = widget.hoverBorderColor ?? MUOPTheme.primaryYellow.withOpacity(0.6);
    }

    // Shadows
    List<BoxShadow> currentShadows = [];
    if (isHighlighted) {
      currentShadows = MUOPTheme.glowShadow(radius: 20);
    } else if (activeHover) {
      currentShadows = MUOPTheme.glowShadow(
        color: widget.hoverGlowColor ?? MUOPTheme.glowColor,
        radius: 25,
      );
    }

    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      transform: activeHover 
          ? (Matrix4.identity()..translate(0, -6, 0)) 
          : Matrix4.identity(),
      decoration: BoxDecoration(
        color: MUOPTheme.cardBg.withOpacity(0.85),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: MUOPTheme.glassBorder(color: currentBorderColor),
        boxShadow: currentShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Padding(
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap != null) {
      cardContent = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: cardContent,
        ),
      );
    } else if (widget.animateHover) {
      cardContent = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: cardContent,
      );
    }

    return cardContent;
  }
}
