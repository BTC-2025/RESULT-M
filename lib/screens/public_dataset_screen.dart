import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'dataset_search_screen.dart';

/// PublicDatasetScreen now simply delegates to DatasetSearchScreen,
/// which handles the full lookup flow with the real backend.
class PublicDatasetScreen extends StatefulWidget {
  final String datasetId;
  final String datasetName;
  final String domainType;

  const PublicDatasetScreen({
    super.key,
    required this.datasetId,
    required this.datasetName,
    required this.domainType,
  });

  @override
  State<PublicDatasetScreen> createState() => _PublicDatasetScreenState();
}

class _PublicDatasetScreenState extends State<PublicDatasetScreen> {
  @override
  void initState() {
    super.initState();
    // Redirect immediately after frame build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DatasetSearchScreen(
              datasetId: widget.datasetId,
              datasetName: widget.datasetName,
              domainType: widget.domainType,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Shown briefly before the redirect fires
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: context.colors.orange),
            const SizedBox(height: 16),
            Text(
              'Loading ${widget.datasetName}...',
              style: TextStyle(
                color: context.colors.inkMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
