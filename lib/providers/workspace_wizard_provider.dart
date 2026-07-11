import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class WorkspaceCreationState {
  final int currentStep;
  final String organizationName;
  final String organizationType;
  final String workspaceSlug;
  final String visibility;
  final String? logoPath;
  final String description;
  final bool isSubmitting;
  final String? error;
  final String? workspaceId;

  WorkspaceCreationState({
    this.currentStep = 0,
    this.organizationName = '',
    this.organizationType = 'Educational',
    this.workspaceSlug = '',
    this.visibility = 'Public',
    this.logoPath,
    this.description = '',
    this.isSubmitting = false,
    this.error,
    this.workspaceId,
  });

  WorkspaceCreationState copyWith({
    int? currentStep,
    String? organizationName,
    String? organizationType,
    String? workspaceSlug,
    String? visibility,
    String? logoPath,
    String? description,
    bool? isSubmitting,
    String? error,
    String? workspaceId,
  }) {
    return WorkspaceCreationState(
      currentStep: currentStep ?? this.currentStep,
      organizationName: organizationName ?? this.organizationName,
      organizationType: organizationType ?? this.organizationType,
      workspaceSlug: workspaceSlug ?? this.workspaceSlug,
      visibility: visibility ?? this.visibility,
      logoPath: logoPath ?? this.logoPath,
      description: description ?? this.description,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }
}

class WorkspaceWizardNotifier extends Notifier<WorkspaceCreationState> {
  @override
  WorkspaceCreationState build() {
    return WorkspaceCreationState();
  }

  void nextStep() {
    if (state.currentStep < 5) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updateName(String name) {
    // Auto-generate slug
    final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
    state = state.copyWith(organizationName: name, workspaceSlug: slug);
  }

  void updateType(String type) => state = state.copyWith(organizationType: type);
  void updateVisibility(String vis) => state = state.copyWith(visibility: vis);
  void updateLogo(String path) => state = state.copyWith(logoPath: path);
  void updateDescription(String desc) => state = state.copyWith(description: desc);

  void selectWorkspace({
    required String id,
    required String name,
    required String slug,
    required String visibility,
    required String description,
  }) {
    state = WorkspaceCreationState(
      currentStep: 5,
      organizationName: name,
      workspaceSlug: slug,
      visibility: visibility,
      description: description,
      workspaceId: id,
    );
  }

  Future<bool> submit() async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final visibilityMapped = switch (state.visibility) {
        'Password Protected' => 'PASSWORD_PROTECTED',
        'Private' => 'PRIVATE',
        _ => 'PUBLIC',
      };

      final Map<String, dynamic> data = {
        'name': state.organizationName.trim(),
        'slug': state.workspaceSlug,
        'description': state.description.trim(),
        'visibility': visibilityMapped,
      };

      if (visibilityMapped == 'PASSWORD_PROTECTED') {
        data['accessCode'] = '123456'; // Default access code if visibility is password protected
      }

      final workspace = await ref.read(apiServiceProvider).createWorkspace(data);
      final newId = workspace['id']?.toString();
      
      state = state.copyWith(
        isSubmitting: false,
        workspaceId: newId,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}

final workspaceWizardProvider = NotifierProvider<WorkspaceWizardNotifier, WorkspaceCreationState>(
  WorkspaceWizardNotifier.new,
);
