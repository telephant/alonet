-- -- Create partner relationships table
-- CREATE TABLE partner_relationships ( 
--   id SERIAL PRIMARY KEY,
--   partner_a_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
--   partner_b_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
--   created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
--   updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
-- );

-- CREATE INDEX idx_partner_relationships_partner_a_id ON partner_relationships(partner_a_id);

-- CREATE INDEX idx_partner_relationships_partner_b_id ON partner_relationships(partner_b_id);
