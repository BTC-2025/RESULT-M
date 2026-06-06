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
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const xl = 28.0;
  static const full = 999.0;
}

// ─── Theme Factory ────────────────────────────────────────────────────────────
class AppTheme {
  // Dark Palette
  static const _darkExt = AppColorsExtension(
    bg: Color(0xFF101624),
    surface: Color(0xFF172033),
    surfaceAlt: Color(0xFF202B42),
    border: Color(0xFF2A354A),
    borderBold: Color(0xFF3B4961),
    ink: Color(0xFFF8FAFC),
    inkMuted: Color(0xFFB6C2D2),
    inkFaint: Color(0xFF7A879A),
    orange: Color(0xFFFF7043),
    orangeGlow: Color(0xFFFF8A5B),
    liveRed: Color(0xFFFF4D5E),
    green: Color(0xFF34D399),
    blue: Color(0xFF60A5FA),
    purple: Color(0xFFA78BFA),
    amber: Color(0xFFFBBF24),
    teal: Color(0xFF2DD4BF),
    pink: Color(0xFFFB7185),
    rail: Color(0xFF141C2C),
    railActive: Color(0xFF24314A),
  );

  // Light Palette
  static const _lightExt = AppColorsExtension(
    bg: Color(0xFFF7F8FB),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF0F3F8),
    border: Color(0xFFE1E6EF),
    borderBold: Color(0xFFC8D1DF),
    ink: Color(0xFF182230),
    inkMuted: Color(0xFF667085),
    inkFaint: Color(0xFF98A2B3),
    orange: Color(0xFFF3653D),
    orangeGlow: Color(0xFFFF8A63),
    liveRed: Color(0xFFE5485B),
    green: Color(0xFF16A36A),
    blue: Color(0xFF2F6FE4),
    purple: Color(0xFF7C5CE6),
    amber: Color(0xFFE09022),
    teal: Color(0xFF0E9384),
    pink: Color(0xFFD9467A),
    rail: Color(0xFFFFFFFF),
    railActive: Color(0xFFFFF1EC),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
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
  static const bg = Color(0xFFF7F8FB);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF0F3F8);
  static const border = Color(0xFFE1E6EF);
  static const borderBold = Color(0xFFC8D1DF);
  static const ink = Color(0xFF182230);
  static const inkMuted = Color(0xFF667085);
  static const inkFaint = Color(0xFF98A2B3);
  static const orange = Color(0xFFF3653D);
  static const orangeGlow = Color(0xFFFF8A63);
  static const liveRed = Color(0xFFE5485B);
  static const green = Color(0xFF16A36A);
  static const blue = Color(0xFF2F6FE4);
  static const purple = Color(0xFF7C5CE6);
  static const amber = Color(0xFFE09022);
  static const teal = Color(0xFF0E9384);
  static const pink = Color(0xFFD9467A);
  static const rail = Color(0xFFFFFFFF);
  static const railActive = Color(0xFFFFF1EC);
  
  static const canvas = bg;
  static const line = border;
  static const yellow = amber;
  static const red = liveRed;
}
