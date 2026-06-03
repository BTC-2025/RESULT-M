import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/domain_model.dart';
import 'result_detail_screen.dart';
import '../services/api_service.dart';
import '../core/storage/secure_storage.dart';

class CredentialScreen extends ConsumerStatefulWidget {
  final ResultDomain domain;
  final Subcategory subcategory;

  const CredentialScreen({super.key, required this.domain, required this.subcategory});

  @override
  ConsumerState<CredentialScreen> createState() => _CredentialScreenState();
}

class _CredentialScreenState extends ConsumerState<CredentialScreen> {
  final TextEditingController _rollNumberController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  List<dynamic> _datasets = [];
  String? _selectedDatasetId;
  bool _isLoadingDatasets = true;
  bool _isLookingUp = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDatasets();
  }

  Future<void> _fetchDatasets() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final secureStorage = SecureStorage();
      final token = await secureStorage.getWorkspaceToken(widget.domain.id);
      
      final datasets = await apiService.fetchDatasets(widget.domain.id, workspaceToken: token);
      if (mounted) {
        setState(() {
          _datasets = datasets;
          if (_datasets.isNotEmpty) {
            _selectedDatasetId = _datasets.first['id'].toString();
          }
          _isLoadingDatasets = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoadingDatasets = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _rollNumberController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedDatasetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a dataset')));
      return;
    }

    if (_rollNumberController.text.trim().isEmpty && _dobController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter either Roll Number or Date of Birth';
      });
      return;
    }

    setState(() {
      _isLookingUp = true;
      _errorMessage = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final secureStorage = SecureStorage();
      final token = await secureStorage.getWorkspaceToken(widget.domain.id);
      
      final resultData = await apiService.lookupRecord(
        _selectedDatasetId!,
        _rollNumberController.text.trim(),
        _dobController.text.trim(),
        workspaceToken: token,
      );

      if (!mounted) return;
      
      // Navigate to Result Detail
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultDetailScreen(
            domainName: widget.domain.name,
            icon: widget.domain.icon,
            recordData: resultData,
            datasetName: _datasets.firstWhere((d) => d['id'].toString() == _selectedDatasetId)['name'],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLookingUp = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.subcategory.name, style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Icon(widget.domain.icon, size: 64, color: const Color(0xFFFF5722)),
                const SizedBox(height: 24),
                const Text(
                  'Lookup Result',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select a dataset and provide your credentials to securely look up your result.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 32),

                if (_isLoadingDatasets)
                  const Center(child: CircularProgressIndicator())
                else if (_datasets.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                    child: const Text('No datasets available for this workspace.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Dataset',
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    value: _selectedDatasetId,
                    items: _datasets.map((dataset) {
                      return DropdownMenuItem<String>(
                        value: dataset['id'].toString(), 
                        child: Text(dataset['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedDatasetId = value),
                  ),
                  const SizedBox(height: 16),
                ],

                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: _rollNumberController,
                    decoration: InputDecoration(
                      labelText: 'Roll Number / Registration No',
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                    ),
                  ),
                ),
                
                const Text(
                  'OR',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: _dobController,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth (YYYY-MM-DD)',
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                    ),
                  ),
                ),

                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13))),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLookingUp || _datasets.isEmpty ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isLookingUp 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('FIND MY RESULT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}
