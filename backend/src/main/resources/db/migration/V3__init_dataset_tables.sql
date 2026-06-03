CREATE TYPE dataset_status AS ENUM ('DRAFT', 'PUBLISHED', 'ARCHIVED');
CREATE TYPE domain_type AS ENUM ('EDUCATION', 'SPORTS', 'FINANCE', 'POLITICS', 'ENTERTAINMENT', 'CUSTOM');

CREATE TABLE datasets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    description TEXT,
    domain_type domain_type NOT NULL DEFAULT 'CUSTOM',
    status dataset_status DEFAULT 'DRAFT',
    version INT DEFAULT 1,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP,
    UNIQUE(workspace_id, slug)
);
CREATE INDEX idx_datasets_workspace ON datasets(workspace_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_datasets_status ON datasets(status) WHERE deleted_at IS NULL;

CREATE TABLE dataset_schemas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dataset_id UUID REFERENCES datasets(id) ON DELETE CASCADE,
    schema_name VARCHAR(255) NOT NULL,
    schema_definition JSONB NOT NULL,
    is_required BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(dataset_id, schema_name)
);
CREATE INDEX idx_dataset_schemas_dataset ON dataset_schemas(dataset_id);

CREATE TABLE dataset_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dataset_id UUID REFERENCES datasets(id) ON DELETE CASCADE,
    record_key VARCHAR(255),
    record_title VARCHAR(255),
    tags TEXT[],
    data JSONB NOT NULL,
    search_vector tsvector,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP
);
CREATE INDEX idx_dataset_records_dataset ON dataset_records(dataset_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_dataset_records_key ON dataset_records(record_key) WHERE deleted_at IS NULL;
CREATE INDEX idx_dataset_records_data_gin ON dataset_records USING GIN (data);
CREATE INDEX idx_dataset_records_search_gin ON dataset_records USING GIN (search_vector);
CREATE INDEX idx_dataset_records_tags_gin ON dataset_records USING GIN (tags);
