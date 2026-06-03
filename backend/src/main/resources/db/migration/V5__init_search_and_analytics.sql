-- Add search_vector to workspaces and datasets
ALTER TABLE workspaces ADD COLUMN IF NOT EXISTS search_vector tsvector;
ALTER TABLE datasets ADD COLUMN IF NOT EXISTS search_vector tsvector;

-- Create GIN Indexes for fast FTS
CREATE INDEX IF NOT EXISTS idx_workspaces_search_gin ON workspaces USING GIN (search_vector);
CREATE INDEX IF NOT EXISTS idx_datasets_search_gin ON datasets USING GIN (search_vector);

-- Create Triggers to automatically update search_vector
CREATE OR REPLACE FUNCTION workspaces_search_trigger() RETURNS trigger AS $$
BEGIN
  new.search_vector :=
    setweight(to_tsvector('english', coalesce(new.name, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(new.description, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(new.slug, '')), 'C');
  return new;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER tsvectorupdate_workspaces
BEFORE INSERT OR UPDATE ON workspaces
FOR EACH ROW EXECUTE FUNCTION workspaces_search_trigger();


CREATE OR REPLACE FUNCTION datasets_search_trigger() RETURNS trigger AS $$
BEGIN
  new.search_vector :=
    setweight(to_tsvector('english', coalesce(new.name, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(new.description, '')), 'B') ||
    setweight(to_tsvector('english', cast(new.domain_type as text)), 'C');
  return new;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER tsvectorupdate_datasets
BEFORE INSERT OR UPDATE ON datasets
FOR EACH ROW EXECUTE FUNCTION datasets_search_trigger();


CREATE OR REPLACE FUNCTION dataset_records_search_trigger() RETURNS trigger AS $$
BEGIN
  new.search_vector :=
    setweight(to_tsvector('english', coalesce(new.record_title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(new.record_key, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(array_to_string(new.tags, ' '), '')), 'B') ||
    setweight(to_tsvector('english', coalesce(new.data::text, '')), 'C');
  return new;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER tsvectorupdate_dataset_records
BEFORE INSERT OR UPDATE ON dataset_records
FOR EACH ROW EXECUTE FUNCTION dataset_records_search_trigger();


-- Create Analytics Table
CREATE TABLE search_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    search_query VARCHAR(255) NOT NULL,
    result_count INT DEFAULT 0,
    anonymous_session_id VARCHAR(255),
    user_id UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW()
);
CREATE INDEX idx_search_analytics_created_at ON search_analytics(created_at);
