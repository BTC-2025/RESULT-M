CREATE TYPE event_type AS ENUM (
    'WORKSPACE_VIEW',
    'DATASET_VIEW',
    'RECORD_VIEW',
    'SEARCH',
    'CSV_UPLOAD',
    'DATASET_CREATED',
    'DATASET_PUBLISHED',
    'INVITATION_ACCEPTED',
    'LOGIN'
);

-- Note: We use declarative partitioning by month.
CREATE TABLE analytics_events (
    id UUID DEFAULT gen_random_uuid(),
    event_type event_type NOT NULL,
    workspace_id UUID,
    dataset_id UUID,
    record_id UUID,
    user_id UUID,
    anonymous_session_id VARCHAR(255),
    metadata JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

-- Create initial partitions for a few months (In production, a cron job or pg_partman manages this)
CREATE TABLE analytics_events_y2026m05 PARTITION OF analytics_events FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');
CREATE TABLE analytics_events_y2026m06 PARTITION OF analytics_events FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');
CREATE TABLE analytics_events_y2026m07 PARTITION OF analytics_events FOR VALUES FROM ('2026-07-01') TO ('2026-08-01');

-- Default partition for dates outside the explicitly created ranges to avoid insertion errors
CREATE TABLE analytics_events_default PARTITION OF analytics_events DEFAULT;

CREATE INDEX idx_analytics_workspace ON analytics_events(workspace_id);
CREATE INDEX idx_analytics_dataset ON analytics_events(dataset_id);
CREATE INDEX idx_analytics_created_at ON analytics_events(created_at);
CREATE INDEX idx_analytics_type ON analytics_events(event_type);
