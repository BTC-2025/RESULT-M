import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PrivateBlockedView extends StatelessWidget {
  const PrivateBlockedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.colors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_rounded, size: 40, color: Colors.red),
              ),
              const SizedBox(height: 24),
              Text(
                'Private Dataset',
                style: TextStyle(
                  color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This dataset is marked as Private/Internal. It can only be viewed by whitelisted team members via the Admin Console.',
                style: TextStyle(color: context.colors.inkMuted, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.surfaceAlt,
                  foregroundColor: context.colors.ink,
                  elevation: 0,
                  side: BorderSide(color: context.colors.border),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
