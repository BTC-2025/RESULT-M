import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/shared/field_renderer.dart';
import '../../providers/live_stream_provider.dart';

/// Finance / Market Result Screen — fully dynamic.
class FinanceResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  const FinanceResultScreen({super.key, required this.data, required this.title});

  static const _themeColor = Color(0xFF059669);

  @override
  Widget build(BuildContext context) => _DomainResultPage(
    data: data,
    title: title,
    themeColor: _themeColor,
    domainLabel: 'MARKET DATA',
    icon: Icons.trending_up_rounded,
    primaryKeys: ['symbol', 'ticker', 'stock_name', 'stockName', 'security', 'index_name'],
    idKeys: ['isin', 'ISIN', 'code', 'ID', 'id'],
    highlightKeys: ['price', 'current_price', 'currentPrice', 'change', 'change_percent', 'changePercent', 'volume', 'market_cap'],
    chart: FinanceChartWidget(data: data),
  );
}

/// Law / Court Result Screen — fully dynamic.
class LawResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  const LawResultScreen({super.key, required this.data, required this.title});

  static const _themeColor = Color(0xFF475569);

  @override
  Widget build(BuildContext context) => _DomainResultPage(
    data: data,
    title: title,
    themeColor: _themeColor,
    domainLabel: 'COURT ORDER',
    icon: Icons.gavel_rounded,
    primaryKeys: ['case_title', 'caseTitle', 'case_no', 'caseNo', 'petition', 'Title', 'case_name'],
    idKeys: ['case_no', 'caseNo', 'ID', 'id', 'docket_no', 'docketNo'],
    highlightKeys: ['verdict', 'judgment', 'order', 'bench', 'judge', 'court', 'date_of_judgment'],
  );
}

/// Healthcare / Medical Result Screen — fully dynamic.
class HealthcareResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  const HealthcareResultScreen({super.key, required this.data, required this.title});

  static const _themeColor = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) => _DomainResultPage(
    data: data,
    title: title,
    themeColor: _themeColor,
    domainLabel: 'MEDICAL REPORT',
    icon: Icons.local_hospital_rounded,
    primaryKeys: ['patient_name', 'patientName', 'name', 'Title', 'candidate_name', 'candidateName'],
    idKeys: ['patient_id', 'patientId', 'uhid', 'UHID', 'ID', 'id', 'reg_no'],
    highlightKeys: ['result', 'status', 'diagnosis', 'report_date', 'doctor', 'hospital', 'rank'],
  );
}

/// Entertainment / Awards Result Screen — fully dynamic.
class EntertainmentResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  const EntertainmentResultScreen({super.key, required this.data, required this.title});

  static const _themeColor = Color(0xFFDB2777);

  @override
  Widget build(BuildContext context) => _DomainResultPage(
    data: data,
    title: title,
    themeColor: _themeColor,
    domainLabel: 'AWARDS & MEDIA',
    icon: Icons.movie_rounded,
    primaryKeys: ['title', 'film_name', 'filmName', 'movie', 'show', 'artist', 'nominee', 'Title'],
    idKeys: ['ID', 'id'],
    highlightKeys: ['award', 'category', 'winner', 'year', 'ceremony', 'box_office', 'rating', 'result'],
  );
}

/// Technology / Benchmark Result Screen — fully dynamic.
class TechResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  const TechResultScreen({super.key, required this.data, required this.title});

  static const _themeColor = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) => _DomainResultPage(
    data: data,
    title: title,
    themeColor: _themeColor,
    domainLabel: 'TECHNOLOGY',
    icon: Icons.computer_rounded,
    primaryKeys: ['product', 'product_name', 'productName', 'device', 'model', 'Title', 'company'],
    idKeys: ['sku', 'model_no', 'modelNo', 'ID', 'id'],
    highlightKeys: ['score', 'benchmark', 'rating', 'rank', 'category', 'price', 'release_date', 'status'],
  );
}

/// Business / Job / Placement Result Screen — fully dynamic.
class BusinessResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  const BusinessResultScreen({super.key, required this.data, required this.title});

  static const _themeColor = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) => _DomainResultPage(
    data: data,
    title: title,
    themeColor: _themeColor,
    domainLabel: 'BUSINESS / CAREER',
    icon: Icons.business_center_rounded,
    primaryKeys: ['company', 'organization', 'candidate_name', 'candidateName', 'name', 'Title', 'position'],
    idKeys: ['application_id', 'applicationId', 'emp_id', 'empId', 'ID', 'id'],
    highlightKeys: ['status', 'role', 'ctc', 'package', 'location', 'joining_date', 'offer_status', 'result'],
  );
}

/// Hyperlocal / Community Result Screen — fully dynamic.
class HyperLocalResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  const HyperLocalResultScreen({super.key, required this.data, required this.title});

  static const _themeColor = Color(0xFF65A30D);

  @override
  Widget build(BuildContext context) => _DomainResultPage(
    data: data,
    title: title,
    themeColor: _themeColor,
    domainLabel: 'HYPERLOCAL',
    icon: Icons.location_city_rounded,
    primaryKeys: ['location', 'area', 'ward', 'panchayat', 'city', 'district', 'Title', 'name'],
    idKeys: ['ward_no', 'wardNo', 'ID', 'id'],
    highlightKeys: ['rank', 'score', 'status', 'category', 'result', 'year', 'event'],
  );
}

// ─── Generic Domain Result Page ──────────────────────────────────────────────
/// A reusable result page that handles any domain with JSONB data.
/// Provides a themed header, dynamic highlight chips, and a full record panel.
class _DomainResultPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final String title;
  final Color themeColor;
  final String domainLabel;
  final IconData icon;
  final List<String> primaryKeys;
  final List<String> idKeys;
  final List<String> highlightKeys;
  final Widget? chart;

  const _DomainResultPage({
    required this.data,
    required this.title,
    required this.themeColor,
    required this.domainLabel,
    required this.icon,
    required this.primaryKeys,
    required this.idKeys,
    required this.highlightKeys,
    this.chart,
  });

  String _normalizeKey(String key) {
    return key.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
  }

  String _pick(List<String> keys, {String fallback = '—'}) {
    final normalizedKeys = keys.map(_normalizeKey).toSet();
    for (final entry in data.entries) {
      if (normalizedKeys.contains(_normalizeKey(entry.key)) && entry.value != null && entry.value.toString().isNotEmpty) {
        return entry.value.toString();
      }
    }
    return fallback;
  }

  Map<String, dynamic> get _highlights {
    final result = <String, dynamic>{};
    final normalizedHighlightKeys = highlightKeys.map(_normalizeKey).toSet();
    for (final entry in data.entries) {
      if (normalizedHighlightKeys.contains(_normalizeKey(entry.key)) && entry.value != null) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  Map<String, dynamic> get _remaining {
    final skipSet = {...primaryKeys, ...idKeys, ...highlightKeys, 'Title', 'ID'}.map(_normalizeKey).toSet();
    return Map.fromEntries(data.entries.where((e) {
      final normalizedKey = _normalizeKey(e.key);
      return !skipSet.contains(normalizedKey) &&
          !e.key.startsWith('_') &&
          e.value != null &&
          e.value.toString().isNotEmpty;
    }));
  }

  @override
  Widget build(BuildContext context) {
    final primaryTitle = _pick(primaryKeys, fallback: title);
    final id = _pick(idKeys, fallback: '');

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Header ────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeColor.withValues(alpha: 0.85), themeColor],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(domainLabel, style: const TextStyle(
                          color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1,
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    primaryTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, height: 1.2),
                  ),
                  if (id.isNotEmpty && id != '—') ...[
                    const SizedBox(height: 4),
                    Text(id, style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),

            if (chart != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: chart!,
              ),

            // ─── Highlights ─────────────────────────────────────────────────
            if (_highlights.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Key Highlights', style: TextStyle(
                      color: context.colors.ink, fontSize: 17, fontWeight: FontWeight.w900,
                    )),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _highlights.entries.map((e) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: themeColor.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.key.replaceAll('_', ' ').toUpperCase(),
                                style: TextStyle(color: themeColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                              ),
                              const SizedBox(height: 4),
                              FieldRenderer.renderValue(context, e.key, e.value),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            // ─── Full Details ────────────────────────────────────────────────
            if (_remaining.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Full Details', style: TextStyle(
                      color: context.colors.ink, fontSize: 17, fontWeight: FontWeight.w900,
                    )),
                    const SizedBox(height: 12),
                    FullRecordPanel(data: _remaining, accentColor: themeColor),
                  ],
                ),
              ),

            // ─── If no highlights and no remaining — show everything ──────────
            if (_highlights.isEmpty && _remaining.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: FullRecordPanel(data: data),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class FinanceChartWidget extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  const FinanceChartWidget({super.key, required this.data});

  @override
  ConsumerState<FinanceChartWidget> createState() => _FinanceChartWidgetState();
}

class _FinanceChartWidgetState extends ConsumerState<FinanceChartWidget> {
  late double _currentVal;
  late String _changeStr;
  final List<FlSpot> _spots = [];
  double _index = 6.0;

  @override
  void initState() {
    super.initState();
    _currentVal = 0.0;
    for (final k in ['price', 'current_price', 'currentPrice', 'value', 'index_value']) {
      if (widget.data.containsKey(k) && widget.data[k] != null) {
        _currentVal = _parseValue(widget.data[k]);
        if (_currentVal > 0) break;
      }
    }

    _changeStr = (widget.data['change'] ?? widget.data['change_percent'] ?? widget.data['changePercent'] ?? '').toString();
    final isNegative = _changeStr.contains('-');
    final List<double> multipliers = isNegative
        ? [1.012, 1.008, 1.015, 1.005, 1.009, 1.002, 1.0]
        : [0.988, 0.992, 0.985, 0.995, 0.991, 0.998, 1.0];

    for (int i = 0; i < multipliers.length; i++) {
      _spots.add(FlSpot(i.toDouble(), _currentVal * multipliers[i]));
    }
  }

  double _parseValue(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    final clean = val.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  void _handleFinanceTick(Map<String, dynamic> tick) {
    final val = _parseValue(tick['value']);
    final change = tick['change']?.toString() ?? '';
    if (val > 0) {
      setState(() {
        _currentVal = val;
        _changeStr = change;
        _index += 1.0;
        _spots.add(FlSpot(_index, val));
        if (_spots.length > 20) {
          _spots.removeAt(0);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentVal == 0.0) return const SizedBox.shrink();

    String? tickerId;
    for (final key in ['symbol', 'ticker', 'stock_name', 'stockName', 'security', 'index_name']) {
      if (widget.data.containsKey(key)) {
        tickerId = widget.data[key]?.toString();
        if (tickerId != null && tickerId.isNotEmpty) break;
      }
    }

    // Listen to WebSocket ticks
    ref.listen<AsyncValue<Map<String, dynamic>>>(liveScoreStreamProvider, (prev, next) {
      final tick = next.value;
      if (tick != null && tick['type'] == 'finance') {
        final tickId = tick['id']?.toString().toUpperCase();
        final currentTicker = tickerId?.toUpperCase();
        if (tickId != null && currentTicker != null && (currentTicker.contains(tickId) || tickId.contains(currentTicker))) {
          _handleFinanceTick(tick);
        }
      }
    });

    final isNegative = _changeStr.contains('-');
    final themeColor = isNegative ? const Color(0xFFEF4444) : const Color(0xFF10B981);

    final double minX = _spots.first.x;
    final double maxX = _spots.last.x;
    
    double minY = _currentVal;
    double maxY = _currentVal;
    for (final spot in _spots) {
      if (spot.y < minY) minY = spot.y;
      if (spot.y > maxY) maxY = spot.y;
    }
    final double yPadding = (maxY - minY) * 0.1;
    minY -= yPadding > 0 ? yPadding : 1.0;
    maxY += yPadding > 0 ? yPadding : 1.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TREND (INTRADAY)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: context.colors.inkMuted,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _changeStr.isEmpty ? 'LIVE' : _changeStr,
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: minX,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => context.colors.surfaceAlt,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          spot.y.toStringAsFixed(2),
                          TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: _spots,
                    isCurved: true,
                    color: themeColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          themeColor.withValues(alpha: 0.25),
                          themeColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
