class DatasetMeta {
  final String datasetId;
  final WorkspaceInfo workspace;
  final String datasetName;
  final DatasetType datasetType;
  final String status;
  final bool isLive;
  final List<SearchField> searchFields;
  final List<String> displayFields;

  DatasetMeta({
    required this.datasetId,
    required this.workspace,
    required this.datasetName,
    required this.datasetType,
    required this.status,
    required this.isLive,
    required this.searchFields,
    required this.displayFields,
  });

  factory DatasetMeta.fromJson(Map<String, dynamic> json) {
    // Support both snake_case (offline) and camelCase (backend) keys
    final datasetId = json['dataset_id'] ?? json['datasetId'] ?? json['id'] ?? '';
    final datasetName = json['dataset_name'] ?? json['datasetName'] ?? json['name'] ?? '';
    final rawType = json['dataset_type'] ?? json['datasetType'] ?? json['type'] ?? 'SEARCHABLE';
    final rawStatus = json['status'] ?? 'PUBLISHED';
    final rawIsLive = json['is_live'] ?? json['isLive'] ?? json['live'] ?? false;

    // Parse dataset type (handles PROTECTED_LOOKUP, protectedLookup, etc.)
    DatasetType resolvedType = DatasetType.searchable;
    final typeStr = rawType.toString().toUpperCase().replaceAll('-', '_').replaceAll(' ', '_');
    for (final t in DatasetType.values) {
      final tName = t.name.toUpperCase().replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), '_');
      if (typeStr == tName || typeStr == t.name.toUpperCase()) {
        resolvedType = t;
        break;
      }
    }
    // Handle common aliases
    if (typeStr == 'PROTECTED_LOOKUP' || typeStr == 'PROTECTED') resolvedType = DatasetType.protectedLookup;
    if (typeStr == 'PRIVATE_INTERNAL' || typeStr == 'PRIVATE') resolvedType = DatasetType.privateInternal;
    if (typeStr == 'PUBLIC_LISTING' || typeStr == 'PUBLIC' || typeStr == 'LISTING') resolvedType = DatasetType.publicListing;
    if (typeStr == 'SEARCHABLE' || typeStr == 'SEARCH') resolvedType = DatasetType.searchable;

    // Parse workspace info from nested object or flat
    WorkspaceInfo workspace;
    final wsRaw = json['workspace'];
    if (wsRaw is Map<String, dynamic>) {
      workspace = WorkspaceInfo.fromJson(wsRaw);
    } else {
      workspace = WorkspaceInfo(
        name: json['workspace_name'] ?? json['workspaceName'] ?? '',
        slug: json['workspace_slug'] ?? json['workspaceSlug'] ?? '',
        category: json['category'] ?? json['domainType'] ?? 'ACADEMIC',
      );
    }

    // Parse search fields
    final rawFields = json['search_fields'] ?? json['searchFields'] ?? [];
    final searchFields = (rawFields as List)
        .map((e) => SearchField.fromJson(e as Map<String, dynamic>))
        .toList();

    // Parse display fields
    final rawDisplay = json['display_fields'] ?? json['displayFields'] ?? [];
    final displayFields = List<String>.from(rawDisplay as List);

    return DatasetMeta(
      datasetId: datasetId,
      workspace: workspace,
      datasetName: datasetName,
      datasetType: resolvedType,
      status: rawStatus,
      isLive: rawIsLive is bool ? rawIsLive : rawIsLive.toString().toLowerCase() == 'true',
      searchFields: searchFields,
      displayFields: displayFields,
    );
  }
}

class WorkspaceInfo {
  final String name;
  final String slug;
  final String category;

  WorkspaceInfo({required this.name, required this.slug, required this.category});

  factory WorkspaceInfo.fromJson(Map<String, dynamic> json) {
    return WorkspaceInfo(
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      category: json['category'] ?? json['domainType'] ?? 'ACADEMIC',
    );
  }
}

enum DatasetType { searchable, publicListing, protectedLookup, privateInternal }

class SearchField {
  final String key;
  final String label;
  final FieldType type;
  final bool required;

  SearchField({required this.key, required this.label, required this.type, required this.required});

  factory SearchField.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] ?? json['fieldType'] ?? 'TEXT';
    FieldType fType = FieldType.text;
    switch (rawType.toString().toUpperCase()) {
      case 'DATE':
        fType = FieldType.date;
        break;
      case 'NUMBER':
      case 'INTEGER':
      case 'LONG':
        fType = FieldType.number;
        break;
      case 'DROPDOWN':
      case 'SELECT':
        fType = FieldType.dropdown;
        break;
      default:
        fType = FieldType.text;
    }
    return SearchField(
      key: json['key'] ?? json['fieldKey'] ?? '',
      label: json['label'] ?? json['fieldLabel'] ?? json['key'] ?? '',
      type: fType,
      required: json['required'] ?? json['isRequired'] ?? true,
    );
  }
}

enum FieldType { text, number, date, dropdown }
