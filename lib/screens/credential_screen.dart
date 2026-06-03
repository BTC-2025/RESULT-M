import 'package:flutter/material.dart';
import '../models/domain_model.dart';
import 'result_detail_screen.dart';

class CredentialScreen extends StatefulWidget {
  final ResultDomain domain;
  final Subcategory subcategory;

  const CredentialScreen({super.key, required this.domain, required this.subcategory});

  @override
  State<CredentialScreen> createState() => _CredentialScreenState();
}

class _CredentialScreenState extends State<CredentialScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();
  String? _selectedExam;

  @override
  void initState() {
    super.initState();
    for (var field in widget.domain.requiredCredentials) {
      _controllers[field] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.subcategory.availableExams.isNotEmpty && _selectedExam == null) {
        return; // Handled by validator
      }

      Map<String, String> creds = {};
      for (var field in widget.domain.requiredCredentials) {
        creds[field] = _controllers[field]!.text.trim();
      }
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultDetailScreen(
            domain: widget.domain,
            credentials: creds,
            examName: _selectedExam,
          ),
        ),
      );
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
                  'Enter Credentials',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please select your exam and enter your details to view your official scorecard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 32),
                
                if (widget.subcategory.availableExams.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Exam / Course',
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                    initialValue: _selectedExam,
                    items: widget.subcategory.availableExams.map((exam) {
                      return DropdownMenuItem(value: exam, child: Text(exam, style: const TextStyle(fontWeight: FontWeight.bold)));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedExam = value),
                    validator: (value) => value == null ? 'Please select an exam' : null,
                  ),
                  const SizedBox(height: 16),
                ],

                ...widget.domain.requiredCredentials.map((field) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: _controllers[field],
                    decoration: InputDecoration(
                      labelText: field,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your $field';
                      }
                      return null;
                    },
                  ),
                )),
                
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('VIEW RESULT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
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
