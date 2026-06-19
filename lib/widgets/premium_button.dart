import 'package:flutter/material.dart';
import '../core/theme.dart';

class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final Widget? icon;
  final bool isLoading;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.isLoading = false,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = widget.onPressed == null || widget.isLoading;

    final primaryBg = widget.isPrimary
        ? MUOPTheme.primaryYellow
        : const Color(0xFF161616);
    final hoverBg = widget.isPrimary
        ? MUOPTheme.primaryYellow.withBlue(50) // Shift color slightly
        : const Color(0xFF222222);
    
    final textColor = widget.isPrimary ? Colors.black : Colors.white;
    final borderColor = widget.isPrimary 
        ? Colors.transparent 
        : (_isHovered ? MUOPTheme.primaryYellow : MUOPTheme.border);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered && !disabled ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: disabled ? primaryBg.withOpacity(0.5) : (_isHovered ? hoverBg : primaryBg),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: _isHovered && !disabled && widget.isPrimary
                ? MUOPTheme.glowShadow(radius: 18)
                : (_isHovered && !disabled && !widget.isPrimary
                    ? MUOPTheme.glowShadow(color: Colors.white.withOpacity(0.05), radius: 10)
                    : []),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: disabled ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(30),
              splashColor: widget.isPrimary ? Colors.white24 : Colors.white10,
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading) ...[
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ] else if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: disabled ? textColor.withOpacity(0.6) : textColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
