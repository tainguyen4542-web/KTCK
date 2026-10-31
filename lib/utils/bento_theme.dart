import 'package:flutter/material.dart';

class BentoColors {
  static const Color background = Color(0xFFF6F7F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);

  static const Color deepForest = Color(0xFF0F3D2E);
  static const Color forestMuted = Color(0xFF1B5E47);
  static const Color mintEmerald = Color(0xFF10B981);
  static const Color mintSoft = Color(0xFFECFDF5);

  static const Color warmCoral = Color(0xFFF97316);
  static const Color coralSoft = Color(0xFFFFF7ED);

  static const Color skyBlue = Color(0xFF0284C7);
  static const Color skySoft = Color(0xFFF0F9FF);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color danger = Color(0xFFDC2626);
}

class BentoTextStyles {
  static const String fontFamily = 'Plus Jakarta Sans';

  static TextStyle statLarge({
    double fontSize = 28,
    Color color = BentoColors.textPrimary,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.15,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle statMedium({
    double fontSize = 20,
    Color color = BentoColors.textPrimary,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.2,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle subCaption({
    Color color = BentoColors.textMuted,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: color,
    );
  }
}

class BentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final String? featureCode;
  final bool showFeatureBadge;

  const BentoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.backgroundColor = BentoColors.surface,
    this.borderColor = BentoColors.border,
    this.borderRadius = 20,
    this.featureCode,
    this.showFeatureBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showFeatureBadge && featureCode != null) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                featureCode!.toUpperCase(),
                style: BentoTextStyles.subCaption(),
              ),
            ),
            const SizedBox(height: 4),
          ],
          child,
        ],
      ),
    );
  }
}

class BentoIconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;
  final double iconSize;

  const BentoIconBadge({
    super.key,
    required this.icon,
    this.color = BentoColors.deepForest,
    this.backgroundColor = BentoColors.mintSoft,
    this.size = 40,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}

