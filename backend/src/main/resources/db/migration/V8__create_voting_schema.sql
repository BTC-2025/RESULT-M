-- vote_boxes table
CREATE TABLE vote_boxes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID REFERENCES users(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    visibility VARCHAR(20) DEFAULT 'PUBLIC'
        CHECK (visibility IN ('PUBLIC', 'PASSWORD_PROTECTED', 'PRIVATE')),
    access_code VARCHAR(20),                    -- for PASSWORD_PROTECTED boxes
    is_active BOOLEAN DEFAULT true,
    allow_anonymous BOOLEAN DEFAULT false,
    ends_at TIMESTAMP,                          -- null = no expiry
    -- optional: embed inside a result workspace
    linked_workspace_id UUID REFERENCES workspaces(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- vote_options table
CREATE TABLE vote_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vote_box_id UUID NOT NULL REFERENCES vote_boxes(id) ON DELETE CASCADE,
    option_text VARCHAR(255) NOT NULL,
    vote_count INTEGER DEFAULT 0,
    display_order INTEGER DEFAULT 0
);

-- vote_responses table (prevents double voting)
CREATE TABLE vote_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vote_box_id UUID NOT NULL REFERENCES vote_boxes(id) ON DELETE CASCADE,
    option_id UUID NOT NULL REFERENCES vote_options(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,  -- null if anonymous
    ip_address VARCHAR(45),                     -- for IP rate limiting
    device_fingerprint VARCHAR(255),            -- for anti-bot
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(vote_box_id, user_id)                -- one vote per user per box
);

-- indexes
CREATE INDEX idx_vote_boxes_visibility ON vote_boxes(visibility);
CREATE INDEX idx_vote_boxes_active ON vote_boxes(is_active);
CREATE INDEX idx_vote_responses_box ON vote_responses(vote_box_id);
CREATE INDEX idx_vote_responses_ip ON vote_responses(ip_address);
