import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_service.dart';

class AdminSearchScreen extends ConsumerStatefulWidget {
  const AdminSearchScreen({super.key});

  @override
  ConsumerState<AdminSearchScreen> createState() => _AdminSearchScreenState();
}

class _AdminSearchScreenState extends ConsumerState<AdminSearchScreen> {
  bool _isLoadingDatasets = true;
  String? _error;
  List<dynamic> _datasets = [];
  String? _selectedDatasetId;
  
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _loadDatasets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDatasets() async {
    setState(() {
      _isLoadingDatasets = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final workspaces = await apiService.fetchMyWorkspaces(size: 1);
      
      if (workspaces.isEmpty) {
        throw Exception('No workspace found.');
      }
      
      final workspaceId = workspaces.first['id'].toString();
      final datasets = await apiService.fetchDatasets(workspaceId);

      if (!mounted) return;
      setState(() {
        _datasets = datasets;
        if (datasets.isNotEmpty) {
          _selectedDatasetId = datasets.first['id'].toString();
        }
        _isLoadingDatasets = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoadingDatasets = false;
      });
    }
  }

  Future<void> _performSearch() async {
    if (_selectedDatasetId == null || _searchController.text.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
      _searchResults = [];
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final query = _searchController.text.trim();
      
      // We assume the user might be typing a generic value and the backend will search across searchable columns.
      // If the backend requires specific keys, we might need to know what they are. 
      // For now, we'll assume the backend searchRecords endpoint can take a general 'q' parameter if we pass it as a key,
      // or we'll pass it as 'query' which some backends support for fuzzy search.
      final results = await apiService.searchRecords(_selectedDatasetId!, {'query': query});

      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search failed: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('GLOBAL SEARCH', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoadingDatasets) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadDatasets, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_datasets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No datasets available to search', style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedDatasetId,
                decoration: InputDecoration(
                  labelText: 'Target Dataset',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                ),
                items: _datasets.map((dataset) {
                  return DropdownMenuItem(
                    value: dataset['id'].toString(),
                    child: Text(dataset['name'] ?? 'Unnamed Dataset'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedDatasetId = val;
                    _searchResults = [];
                    _hasSearched = false;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Enter search query (e.g. register number)',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                      ),
                      onSubmitted: (_) => _performSearch(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSearching ? null : _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSearching 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Search', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.manage_search, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            const Text('Select a dataset and enter a query to search records.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No records found', style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final record = _searchResults[index];
        final recordData = record['data'] as Map<String, dynamic>? ?? {};
        
        // Find a title (fallback to ID)
        String title = recordData.values.firstOrNull?.toString() ?? 'Record #${record['id']}';
        if (recordData.containsKey('name')) {
          title = recordData['name'].toString();
        } else if (recordData.containsKey('title')) {
          title = recordData['title'].toString();
        }

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ExpansionTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('ID: ${record['id']}'),
            children: recordData.entries.map((entry) {
              return ListTile(
                title: Text(entry.key, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                subtitle: Text(entry.value.toString(), style: const TextStyle(color: Colors.black87)),
                dense: true,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
