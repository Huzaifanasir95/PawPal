-- Migration 008: Introduce user_roles table for multi-role user identity

CREATE TABLE IF NOT EXISTS user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT user_roles_user_role_unique UNIQUE (user_id, role),
    CONSTRAINT user_roles_role_check CHECK (role IN ('pet_owner', 'vet', 'seller', 'caregiver', 'admin'))
);

CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role ON user_roles(role);

INSERT INTO user_roles (user_id, role)
SELECT
    u.id,
    CASE
        WHEN LOWER(TRIM(COALESCE(u.account_type, ''))) IN ('pet_owner', 'petowner', 'pet-owner', 'owner') THEN 'pet_owner'
        WHEN LOWER(TRIM(COALESCE(u.account_type, ''))) IN ('vet', 'veterinarian', 'veterinary') THEN 'vet'
        WHEN LOWER(TRIM(COALESCE(u.account_type, ''))) IN ('seller', 'vendor', 'merchant', 'shop_owner', 'shopowner') THEN 'seller'
        WHEN LOWER(TRIM(COALESCE(u.account_type, ''))) IN ('caregiver', 'care_giver', 'pet_caregiver') THEN 'caregiver'
        WHEN LOWER(TRIM(COALESCE(u.account_type, ''))) = 'admin' THEN 'admin'
        ELSE 'pet_owner'
    END AS role
FROM users u
ON CONFLICT (user_id, role) DO NOTHING;
