-- Migration 011: Community advanced features (groups + hashtag/trending support)

CREATE TABLE IF NOT EXISTS community_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(80) NOT NULL,
    slug VARCHAR(96) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(60),
    is_private BOOLEAN NOT NULL DEFAULT FALSE,
    members_count INTEGER NOT NULL DEFAULT 1,
    posts_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_community_groups_name UNIQUE (name)
);

CREATE INDEX IF NOT EXISTS idx_community_groups_owner ON community_groups(owner_id);
CREATE INDEX IF NOT EXISTS idx_community_groups_created ON community_groups(created_at DESC);

CREATE TABLE IF NOT EXISTS community_group_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES community_groups(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL DEFAULT 'member' CHECK (role IN ('owner', 'moderator', 'member')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(group_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_community_group_members_group ON community_group_members(group_id);
CREATE INDEX IF NOT EXISTS idx_community_group_members_user ON community_group_members(user_id);

CREATE TABLE IF NOT EXISTS community_group_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES community_groups(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    added_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(group_id, post_id)
);

CREATE INDEX IF NOT EXISTS idx_community_group_posts_group ON community_group_posts(group_id);
CREATE INDEX IF NOT EXISTS idx_community_group_posts_post ON community_group_posts(post_id);
