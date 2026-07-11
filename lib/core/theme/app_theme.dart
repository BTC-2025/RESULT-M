import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Theme Extension ──────────────────────────────────────────────────────────
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color borderBold;

  final Color ink;
  final Color inkMuted;
  final Color inkFaint;

  final Color orange;
  final Color orangeGlow;
  final Color liveRed;
  final Color green;
  final Color blue;
  final Color purple;
  final Color amber;
  final Color teal;
  final Color pink;

  final Color rail;
  final Color railActive;

  // Backward-compatible aliases for old tokens
  Color get canvas => bg;
  Color get line => border;
  Color get yellow => amber;
  Color get red => liveRed;
  Color get primary => orange;

  const AppColorsExtension({
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.borderBold,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.orange,
    required this.orangeGlow,
    required this.liveRed,
    required this.green,
    required this.blue,
    required this.purple,
    required this.amber,
    required this.teal,
    required this.pink,
    required this.rail,
    required this.railActive,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith() => this;

  @override
  ThemeExtension<AppColorsExtension> lerp(ThemeExtension<AppColorsExtension>? other, double t) => this;
}

// ─── Context Extension ────────────────────────────────────────────────────────
extension ThemeX on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;
}

// ─── Constants ────────────────────────────────────────────────────────────────
class AppRadii {
  static const xs = 0.0;
  static const sm = 0.0;
  static const md = 4.0;
  static const lg = 8.0;
  static const xl = 12.0;
  static const full = 999.0;
}

// ─── Theme Factory ────────────────────────────────────────────────────────────
class AppTheme {
  // Dark Palette
  static const _darkExt = AppColorsExtension(
    bg: Color(0xFF0D1117), // Rich dark slate/github style
    surface: Color(0xFF161B22), // Elevated surface
    surfaceAlt: Color(0xFF21262D),
    border: Color(0xFF30363D),
    borderBold: Color(0xFF484F58),
    ink: Color(0xFFE6EDF3), // Softer, premium white
    inkMuted: Color(0xFF8B949E),
    inkFaint: Color(0xFF6E7681),
    orange: Color(0xFFFF5A36), // Vibrant modern coral/orange
    orangeGlow: Color(0xFFFF7A5C),
    liveRed: Color(0xFFF85149), // Sleek alert red
    green: Color(0xFF238636), // Rich emerald green
    blue: Color(0xFF2F81F7), // Vivid royal blue
    purple: Color(0xFFA371F7), // Elegant deep purple
    amber: Color(0xFFD29922),
    teal: Color(0xFF1C7A70),
    pink: Color(0xFFED468B),
    rail: Color(0xFF0D1117),
    railActive: Color(0xFF161B22),
  );

  // Light Palette
  static const _lightExt = AppColorsExtension(
    bg: Color(0xFFFFFFFF), // Pure white for a seamless feed
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF7F9F9), // Very subtle off-white for filled inputs
    border: Color(0xFFEFF3F4), // Ultra-light border (Twitter style)
    borderBold: Color(0xFFCFD9DE),
    ink: Color(0xFF0F1419), // Deep rich black for primary text
    inkMuted: Color(0xFF536471), // Balanced slate for secondary text
    inkFaint: Color(0xFF8B98A5),
    orange: Color(0xFFFF5A36), // Vibrant modern coral
    orangeGlow: Color(0xFFFF7A5C),
    liveRed: Color(0xFFF91880), // Rich magenta-red
    green: Color(0xFF00BA7C), // Vibrant mint green
    blue: Color(0xFF1D9BF0), // Classic social electric blue
    purple: Color(0xFF8B5CF6), // Rich violet
    amber: Color(0xFFFFD400),
    teal: Color(0xFF14B8A6),
    pink: Color(0xFFF91880),
    rail: Color(0xFFFFFFFF),
    railActive: Color(0xFFF7F9F9),
  );

  static ThemeData dark(BuildContext context) => _build(Brightness.dark, _darkExt);
  static ThemeData light(BuildContext context) => _build(Brightness.light, _lightExt);

  static ThemeData _build(Brightness brightness, AppColorsExtension ext) {
    final isDark = brightness == Brightness.dark;

    final cs = ColorScheme(
      brightness: brightness,
      primary: ext.orange,
      onPrimary: Colors.white,
      secondary: ext.blue,
      onSecondary: Colors.white,
      error: ext.liveRed,
      onError: Colors.white,
      surface: ext.bg,
      onSurface: ext.ink,
    );

    final textTheme = GoogleFonts.interTextTheme().apply(
      bodyColor: ext.ink,
      displayColor: ext.ink,
    );

    return ThemeData(
      colorScheme: cs,
      scaffoldBackgroundColor: ext.bg,
      useMaterial3: true,
      textTheme: textTheme,
      extensions: [ext],

      appBarTheme: AppBarTheme(
        backgroundColor: ext.bg,
        foregroundColor: ext.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w900,
          color: ext.ink,
        ),
      ),

      cardTheme: CardThemeData(
        color: ext.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: ext.border),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ext.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ext.surface,
          foregroundColor: ext.ink,
          elevation: 0,
          side: BorderSide(color: ext.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ext.ink,
          side: BorderSide(color: ext.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.full),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ext.surface,
        hintStyle: TextStyle(color: ext.inkFaint),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: ext.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: ext.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          borderSide: BorderSide(color: ext.orange, width: 1.5),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ext.rail,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        elevation: 0,
        height: 62,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected) ? ext.orange : ext.inkMuted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? ext.orange : ext.inkMuted,
            size: 22,
          ),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: ext.border,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: ext.surfaceAlt,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white : Colors.black),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          side: BorderSide(color: ext.border),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: ext.surface,
        side: BorderSide(color: ext.border),
        labelStyle: TextStyle(
          color: ext.inkMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.full),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ext.orange,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.full)),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: ext.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
        ),
      ),
    );
  }
}

// ─── Shadows ─────────────────────────────────────────────────────────────────
class AppShadows {
  static List<BoxShadow> orangeGlow = [
    BoxShadow(
      color: const Color(0xFFF3653D).withValues(alpha: 0.26),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class AppChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const AppChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12), // Sleek, modern subtle tint
        borderRadius: BorderRadius.circular(100), // Perfect pill shape
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color, // Text matches the rich base color
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class LiveBadge extends StatefulWidget {
  const LiveBadge({super.key});

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: context.colors.liveRed,
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) => Opacity(
              opacity: _pulse.value,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: context.colors.inkMuted,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ─── Legacy Fallback ─────────────────────────────────────────────────────────
// This is to prevent the app from immediately failing to compile before we run
// the search and replace. Once replaced, this can optionally be removed.
class AppColors {
  static const bg = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF1F5F9);
  static const border = Color(0xFFE2E8F0);
  static const borderBold = Color(0xFFCBD5E1);
  static const ink = Color(0xFF0F172A);
  static const inkMuted = Color(0xFF64748B);
  static const inkFaint = Color(0xFF94A3B8);
  static const orange = Color(0xFFFF5A36);
  static const orangeGlow = Color(0xFFFF7A5C);
  static const liveRed = Color(0xFFE11D48);
  static const green = Color(0xFF10B981);
  static const blue = Color(0xFF1D9BF0);
  static const purple = Color(0xFF8B5CF6);
  static const amber = Color(0xFFF59E0B);
  static const teal = Color(0xFF14B8A6);
  static const pink = Color(0xFFEC4899);
  static const rail = Color(0xFFFFFFFF);
  static const railActive = Color(0xFFFFF1EE);
  
  static const canvas = bg;
  static const line = border;
  static const yellow = amber;
  static const red = liveRed;
  static const primary = orange;
}
