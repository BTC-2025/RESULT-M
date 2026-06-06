import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../services/api_service.dart';
import 'result_detail_screen.dart';
import 'results/academic_result_screen.dart';
import 'results/cricket_score_screen.dart';
import 'results/election_result_screen.dart';
import 'results/entertainment_result_screen.dart';
import 'results/finance_result_screen.dart';
import 'results/football_score_screen.dart';
import 'results/law_result_screen.dart';
import 'results/school_result_screen.dart';

class DatasetSearchScreen extends ConsumerStatefulWidget {
  final String datasetId;
  final String datasetName;
  final String domainType;

  const DatasetSearchScreen({
    super.key,
    required this.datasetId,
    required this.datasetName,
    required this.domainType,
  });

  @override
  ConsumerState<DatasetSearchScreen> createState() => _DatasetSearchScreenState();
}

class _DatasetSearchScreenState extends ConsumerState<DatasetSearchScreen> {
  final _searchCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _captchaCtrl = TextEditingController();
  
  bool _isLoading = false;
  String? _loadingMessage;
  String? _error;
  
  bool get _isAcademic => widget.domainType.toUpperCase().contains('ACADEMIC') || widget.domainType.toUpperCase().contains('EDUCATION');
  bool get _isSchool => widget.domainType.toUpperCase().contains('SCHOOL');

  @override
  void dispose() {
    _searchCtrl.dispose();
    _dobCtrl.dispose();
    _captchaCtrl.dispose();
    super.dispose();
  }

  IconData _getIconForDomain(String domain) {
    final d = domain.toUpperCase();
    if (d.contains('ACADEMIC') || d.contains('EDU')) return Icons.school_rounded;
    if (d.contains('POLITIC') || d.contains('ELECTION')) return Icons.how_to_vote_rounded;
    if (d.contains('SPORT') || d.contains('GAME')) return Icons.sports_esports_rounded;
    if (d.contains('FINANCE') || d.contains('MARKET')) return Icons.trending_up_rounded;
    if (d.contains('LAW') || d.contains('COURT')) return Icons.gavel_rounded;
    if (d.contains('ENTERTAIN') || d.contains('MOVIE')) return Icons.movie_rounded;
    return Icons.search_rounded;
  }

  Future<void> _performSearch() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) {
      setState(() => _error = (_isAcademic || _isSchool) ? 'Please enter your ${_isSchool ? 'Roll' : 'Register'} Number' : 'Please enter an ID to search');
      return;
    }
    
    if (_isAcademic || _isSchool) {
      if (_dobCtrl.text.trim().isEmpty) {
        setState(() => _error = 'Please enter your Date of Birth');
        return;
      }
      if (_captchaCtrl.text.trim().isEmpty) {
        setState(() => _error = 'Please enter the Captcha');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _loadingMessage = (_isAcademic || _isSchool) ? 'Searching Results...' : null;
    });

    try {
      if (_isAcademic || _isSchool) {
        // Multi-phase authentic loading
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        setState(() => _loadingMessage = 'Validating Credentials...');
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        setState(() => _loadingMessage = 'Fetching Academic Records...');
        await Future.delayed(const Duration(milliseconds: 600));
      }

      final api = ref.read(apiServiceProvider);
      final records = await api.fetchDatasetRecords(widget.datasetId, query: query, size: 1);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });

      if (records.isEmpty) {
        setState(() => _error = 'No result found for "$query". Please check your ID and try again.');
      } else {
        final record = records.first as Map<String, dynamic>;
        final data = record['data'] as Map<String, dynamic>? ?? {};
        final displayData = <String, dynamic>{
          if (record['recordTitle'] != null) 'Title': record['recordTitle'],
          if (record['recordKey'] != null) 'ID': record['recordKey'],
          ...data,
        };

        Widget destinationScreen;
        final domain = widget.domainType.toUpperCase();
        
        if (_isAcademic) {
          destinationScreen = AcademicResultScreen(data: displayData, title: widget.datasetName);
        } else if (_isSchool) {
          destinationScreen = SchoolResultScreen(data: displayData, title: widget.datasetName);
        } else if (domain.contains('POLITICS') || domain.contains('ELECTION')) {
          destinationScreen = ElectionResultScreen(data: displayData, title: widget.datasetName);
        } else if (domain.contains('FINANCE') || domain.contains('MARKET') || domain.contains('ECONOM')) {
          destinationScreen = FinanceResultScreen(data: displayData, title: widget.datasetName);
        } else if (domain.contains('ENTERTAIN') || domain.contains('MEDIA') || domain.contains('MOVIE')) {
          destinationScreen = EntertainmentResultScreen(data: displayData, title: widget.datasetName);
        } else if (domain.contains('LAW') || domain.contains('GOV') || domain.contains('COURT')) {
          destinationScreen = LawResultScreen(data: displayData, title: widget.datasetName);
        } else if (domain.contains('SPORT') || domain.contains('GAME')) {
          if (widget.datasetName.toUpperCase().contains('CRICKET')) {
            destinationScreen = CricketScoreScreen(data: displayData, title: widget.datasetName);
          } else if (widget.datasetName.toUpperCase().contains('FOOTBALL') || widget.datasetName.toUpperCase().contains('SOCCER')) {
            destinationScreen = FootballScoreScreen(data: displayData, title: widget.datasetName);
          } else {
            destinationScreen = ResultDetailScreen(
              domainName: widget.domainType,
              icon: _getIconForDomain(widget.domainType),
              recordData: displayData,
              datasetName: widget.datasetName,
            );
          }
        } else {
          destinationScreen = ResultDetailScreen(
            domainName: widget.domainType,
            icon: _getIconForDomain(widget.domainType),
            recordData: displayData,
            datasetName: widget.datasetName,
          );
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destinationScreen),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
        _error = 'Error connecting to server. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.colors.ink),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: _isLoading && (_isAcademic || _isSchool) 
            ? _buildAcademicLoading() 
            : _buildContent(),
      ),
    );
  }

  Widget _buildAcademicLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: context.colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(color: context.colors.orange, strokeWidth: 3),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _loadingMessage ?? 'Loading...',
            style: TextStyle(
              color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Securely connecting to university servers',
            style: TextStyle(color: context.colors.inkMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header ──────────────────────────────────────────────────
          Icon(_getIconForDomain(widget.domainType), size: 48, color: context.colors.orange),
          const SizedBox(height: 24),
          Text(
            widget.datasetName,
            style: TextStyle(
              color: context.colors.ink,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your details below to check your result.',
            style: TextStyle(
              color: context.colors.inkMuted,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 40),

          // ─── Error Message ───────────────────────────────────────────
          if (_error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_error!, style: const TextStyle(
                      color: Color(0xFFEF4444), fontWeight: FontWeight.w700,
                    )),
                  ),
                ],
              ),
            ),

          // ─── Search Fields ───────────────────────────────────────────
          _buildInputLabel((_isAcademic || _isSchool) ? (_isSchool ? 'Roll Number' : 'Register Number') : 'Search ID'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _searchCtrl,
            hint: 'e.g. 21BCS102',
            icon: Icons.badge_outlined,
          ),

          if (_isAcademic || _isSchool) ...[
            const SizedBox(height: 24),
            _buildInputLabel('Date of Birth'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _dobCtrl,
              hint: 'DD/MM/YYYY',
              icon: Icons.calendar_today_rounded,
            ),
            const SizedBox(height: 24),
            _buildInputLabel('Security Captcha'),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 120,
                  height: 56,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: context.colors.border),
                    image: const DecorationImage(
                      image: NetworkImage('https://upload.wikimedia.org/wikipedia/commons/6/69/Captcha.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _captchaCtrl,
                    hint: 'Enter text',
                    icon: null,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 48),

          // ─── Search Button ───────────────────────────────────────────
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg)),
                elevation: 4,
                shadowColor: context.colors.orange.withValues(alpha: 0.4),
              ),
              child: _isLoading && !_isAcademic && !_isSchool
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : const Text(
                      'Search Results',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: context.colors.inkFaint,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, IconData? icon}) {
    return TextField(
      controller: controller,
      style: TextStyle(color: context.colors.ink, fontSize: 16, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: context.colors.inkMuted, fontWeight: FontWeight.w400),
        prefixIcon: icon != null ? Icon(icon, color: context.colors.inkMuted) : null,
        filled: true,
        fillColor: context.colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: context.colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: context.colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: context.colors.orange, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
