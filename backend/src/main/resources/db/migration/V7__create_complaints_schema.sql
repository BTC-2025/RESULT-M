-- complaints table
CREATE TABLE complaints (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID REFERENCES users(id) ON DELETE SET NULL,
    category VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    media_urls TEXT[],                          -- array of local file paths
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    location_name VARCHAR(255),
    status VARCHAR(20) DEFAULT 'OPEN'           -- OPEN, UNDER_REVIEW, RESOLVED
        CHECK (status IN ('OPEN', 'UNDER_REVIEW', 'RESOLVED')),
    is_anonymous BOOLEAN DEFAULT false,
    flag_count INTEGER DEFAULT 0,
    upvotes INTEGER DEFAULT 0,
    downvotes INTEGER DEFAULT 0,
    net_score INTEGER GENERATED ALWAYS AS (upvotes - downvotes) STORED,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- complaint_votes table (prevents double voting)
CREATE TABLE complaint_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    complaint_id UUID NOT NULL REFERENCES complaints(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    vote_type VARCHAR(4) CHECK (vote_type IN ('UP', 'DOWN')),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(complaint_id, user_id)               -- one vote per user per complaint
);

-- complaint_comments table
CREATE TABLE complaint_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    complaint_id UUID NOT NULL REFERENCES complaints(id) ON DELETE CASCADE,
    creator_id UUID REFERENCES users(id) ON DELETE SET NULL,
    content TEXT NOT NULL,
    is_anonymous BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);

-- indexes for performance
CREATE INDEX idx_complaints_net_score ON complaints(net_score DESC);
CREATE INDEX idx_complaints_status ON complaints(status);
CREATE INDEX idx_complaints_category ON complaints(category);
CREATE INDEX idx_complaints_created_at ON complaints(created_at DESC);
CREATE INDEX idx_complaint_votes_complaint ON complaint_votes(complaint_id);
