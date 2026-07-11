import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import '../../services/api_service.dart';

class CreateComplaintScreen extends ConsumerStatefulWidget {
  const CreateComplaintScreen({super.key});

  @override
  ConsumerState<CreateComplaintScreen> createState() =>
      _CreateComplaintScreenState();
}

class _CreateComplaintScreenState extends ConsumerState<CreateComplaintScreen> {
  static const int _maxFiles = 5;
  static const int _maxFileSizeBytes = 10 * 1024 * 1024;
  static const Set<String> _allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
    'mp4',
  };

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedCategory;
  final List<String> _categories = [
    'Infrastructure',
    'Education',
    'Sports',
    'Politics',
    'Other',
  ];

  bool _isAnonymous = false;
  double? _lat;
  double? _lng;

  final List<File> _selectedFiles = [];
  final Map<String, String> _fileValidationErrors = {};
  bool _isSubmitting = false;

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: _allowedExtensions.toList(),
    );

    if (result != null) {
      final candidateFiles = result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList();

      if (_selectedFiles.length + candidateFiles.length > _maxFiles) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 5 media files allowed')),
        );
        return;
      }

      final validFiles = <File>[];
      final errors = Map<String, String>.from(_fileValidationErrors);

      for (final file in candidateFiles) {
        final error = _validateMediaFile(file);
        if (error == null) {
          validFiles.add(file);
          errors.remove(file.path);
        } else {
          errors[file.path] = error;
        }
      }

      if (!mounted) return;
      setState(() {
        _selectedFiles.addAll(validFiles);
        _fileValidationErrors
          ..clear()
          ..addAll(errors);
      });

      if (errors.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Some files were skipped. Use JPG, PNG, WEBP, or MP4 under 10MB.',
            ),
          ),
        );
      }
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permissions are permanently denied, we cannot request permissions.',
          ),
        ),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _lat = position.latitude;
      _lng = position.longitude;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('GPS Coordinates Captured!')));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    for (final file in _selectedFiles) {
      final error = _validateMediaFile(file);
      if (error != null) {
        setState(() => _fileValidationErrors[file.path] = error);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final apiService = ref.read(apiServiceProvider);

      final complaintPayload = {
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'category': _selectedCategory,
        'locationName': _locationController.text.trim(),
        'latitude': _lat,
        'longitude': _lng,
        'isAnonymous': _isAnonymous,
      };

      final formData = FormData.fromMap({
        'data': MultipartFile.fromString(
          jsonEncode(complaintPayload),
          contentType: DioMediaType.parse('application/json'),
        ),
      });

      // Add files
      for (var file in _selectedFiles) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      await apiService.createComplaint(formData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint posted successfully!')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to post: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String? _validateMediaFile(File file) {
    final extension = _extensionFor(file.path);
    if (!_allowedExtensions.contains(extension)) {
      return '${_fileName(file.path)} is not supported.';
    }

    final size = file.lengthSync();
    if (size > _maxFileSizeBytes) {
      return '${_fileName(file.path)} exceeds 10MB.';
    }

    return null;
  }

  String _extensionFor(String path) {
    final fileName = _fileName(path);
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) return '';
    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  String _fileName(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  String _formatFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).ceil()} KB';
  }

  void _wrapDescriptionSelection(String prefix, String suffix) {
    final selection = _descController.selection;
    final text = _descController.text;
    final hasSelection = selection.isValid && !selection.isCollapsed;
    final start = hasSelection ? selection.start : text.length;
    final end = hasSelection ? selection.end : text.length;
    final selectedText = hasSelection ? text.substring(start, end) : '';
    final inserted = '$prefix$selectedText$suffix';

    _descController.value = TextEditingValue(
      text: text.replaceRange(start, end, inserted),
      selection: TextSelection.collapsed(
        offset: start + prefix.length + selectedText.length,
      ),
    );
  }

  void _insertDescriptionLine(String marker) {
    final selection = _descController.selection;
    final text = _descController.text;
    final index = selection.isValid ? selection.baseOffset : text.length;
    final needsLeadingBreak =
        index > 0 && !text.substring(0, index).endsWith('\n');
    final inserted = '${needsLeadingBreak ? '\n' : ''}$marker';

    _descController.value = TextEditingValue(
      text: text.replaceRange(index, index, inserted),
      selection: TextSelection.collapsed(offset: index + inserted.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Complaint',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      hint: const Text('Select Category'),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Title',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Brief summary of the issue',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _RichTextToolbar(
                      onBold: () => _wrapDescriptionSelection('**', '**'),
                      onItalic: () => _wrapDescriptionSelection('_', '_'),
                      onCode: () => _wrapDescriptionSelection('`', '`'),
                      onBullet: () => _insertDescriptionLine('- '),
                      onQuote: () => _insertDescriptionLine('> '),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descController,
                      minLines: 6,
                      maxLines: 10,
                      decoration: InputDecoration(
                        hintText: 'Provide details...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Location Name (Optional)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'e.g. MG Road, Near Station',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _getLocation,
                          icon: const Icon(Icons.gps_fixed),
                          label: const Text('Capture GPS'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: const Color(0xFF0F172A),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (_lat != null)
                          const Text(
                            'GPS Added!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Media Attachments',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'JPG, PNG, WEBP, or MP4. Max 5 files, 10MB each.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        InkWell(
                          onTap: _pickFiles,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Icon(
                              Icons.add_a_photo,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedFiles.length,
                              itemBuilder: (context, index) {
                                final file = _selectedFiles[index];
                                final isVideo =
                                    _extensionFor(file.path) == 'mp4';
                                final validationError =
                                    _fileValidationErrors[file.path];
                                return Stack(
                                  children: [
                                    Container(
                                      width: 112,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: validationError == null
                                              ? Colors.grey.shade300
                                              : Colors.red,
                                        ),
                                        color: Colors.grey.shade100,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                width: double.infinity,
                                                child: isVideo
                                                    ? const Icon(
                                                        Icons.video_file,
                                                        color: Colors.grey,
                                                        size: 32,
                                                      )
                                                    : Image.file(
                                                        file,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) => const Icon(
                                                              Icons
                                                                  .broken_image,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                      ),
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              color: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 4,
                                                  ),
                                              child: Text(
                                                validationError ??
                                                    _formatFileSize(file),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: validationError == null
                                                      ? Colors.grey.shade700
                                                      : Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 12,
                                      child: GestureDetector(
                                        onTap: () => setState(() {
                                          _fileValidationErrors.remove(
                                            file.path,
                                          );
                                          _selectedFiles.removeAt(index);
                                        }),
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SwitchListTile(
                      title: const Text(
                        'Post Anonymously',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Your name will be hidden from the public',
                      ),
                      value: _isAnonymous,
                      onChanged: (val) => setState(() => _isAnonymous = val),
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: const Color(0xFFFF5722),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5722),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'POST COMPLAINT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
    );
  }
}

class _RichTextToolbar extends StatelessWidget {
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onCode;
  final VoidCallback onBullet;
  final VoidCallback onQuote;

  const _RichTextToolbar({
    required this.onBold,
    required this.onItalic,
    required this.onCode,
    required this.onBullet,
    required this.onQuote,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ToolbarButton(icon: Icons.format_bold, tooltip: 'Bold', onTap: onBold),
        _ToolbarButton(
          icon: Icons.format_italic,
          tooltip: 'Italic',
          onTap: onItalic,
        ),
        _ToolbarButton(icon: Icons.code, tooltip: 'Code', onTap: onCode),
        _ToolbarButton(
          icon: Icons.format_list_bulleted,
          tooltip: 'Bullet',
          onTap: onBullet,
        ),
        _ToolbarButton(
          icon: Icons.format_quote,
          tooltip: 'Quote',
          onTap: onQuote,
        ),
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton.filledTonal(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
