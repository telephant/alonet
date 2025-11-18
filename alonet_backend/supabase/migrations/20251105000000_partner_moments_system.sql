-- Create partner relationships table
CREATE TABLE IF NOT EXISTS partner_relationships (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  partner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  status TEXT CHECK (status IN ('pending', 'accepted', 'rejected')) DEFAULT 'pending' NOT NULL,
  invitation_code TEXT UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  accepted_at TIMESTAMP WITH TIME ZONE,

  -- Ensure a user can only have one active partner relationship
  CONSTRAINT unique_active_partnership UNIQUE (user_id),
  -- Prevent self-partnership
  CONSTRAINT no_self_partnership CHECK (user_id != partner_id)
);

-- Indexes
CREATE INDEX idx_partner_relationships_user_id ON partner_relationships(user_id);
CREATE INDEX idx_partner_relationships_partner_id ON partner_relationships(partner_id);
CREATE INDEX idx_partner_relationships_status ON partner_relationships(status);
CREATE INDEX idx_partner_relationships_invitation_code ON partner_relationships(invitation_code);

-- Create moments table
CREATE TABLE IF NOT EXISTS moments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  event TEXT NOT NULL,
  note TEXT,
  moment_time TIMESTAMP WITH TIME ZONE NOT NULL,
  timezone TEXT NOT NULL,
  reaction TEXT,
  reacted_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX idx_moments_user_id ON moments(user_id);
CREATE INDEX idx_moments_moment_time ON moments(moment_time);
CREATE INDEX idx_moments_created_at ON moments(created_at);

-- Function to check if users are partners
CREATE OR REPLACE FUNCTION are_partners(user1_id UUID, user2_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM partner_relationships
    WHERE status = 'accepted'
    AND (
      (user_id = user1_id AND partner_id = user2_id) OR
      (user_id = user2_id AND partner_id = user1_id)
    )
  );
END;
$$ LANGUAGE plpgsql;

-- Enable RLS
ALTER TABLE partner_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE moments ENABLE ROW LEVEL SECURITY;

-- Policies for partner_relationships
CREATE POLICY "Users can view own partnerships" ON partner_relationships
  FOR SELECT USING (auth.uid() = user_id OR auth.uid() = partner_id);

CREATE POLICY "Users can create partnerships" ON partner_relationships
  FOR INSERT WITH CHECK (
    auth.uid() = user_id AND
    NOT EXISTS (
      SELECT 1 FROM partner_relationships
      WHERE (user_id = auth.uid() OR partner_id = auth.uid())
      AND status = 'accepted'
    )
  );

CREATE POLICY "Users can update own partnerships" ON partner_relationships
  FOR UPDATE USING (auth.uid() = user_id OR auth.uid() = partner_id);

CREATE POLICY "Users can delete own partnerships" ON partner_relationships
  FOR DELETE USING (auth.uid() = user_id OR auth.uid() = partner_id);

-- Policies for moments
CREATE POLICY "Users can view own moments" ON moments
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Partners can view partner moments" ON moments
  FOR SELECT USING (are_partners(auth.uid(), user_id));

CREATE POLICY "Users can create own moments" ON moments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own moments" ON moments
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Partners can react to partner moments" ON moments
  FOR UPDATE USING (are_partners(auth.uid(), user_id));

CREATE POLICY "Users can delete own moments" ON moments
  FOR DELETE USING (auth.uid() = user_id);

-- Trigger to enforce that partners only update reaction/ reacted_at
CREATE OR REPLACE FUNCTION restrict_partner_updates()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT are_partners(auth.uid(), OLD.user_id) THEN
    RETURN NEW; -- Not a partner, do nothing
  END IF;

  -- Only allow reaction/ reacted_at to change
  IF (NEW.event IS DISTINCT FROM OLD.event OR
      NEW.note IS DISTINCT FROM OLD.note OR
      NEW.moment_time IS DISTINCT FROM OLD.moment_time OR
      NEW.timezone IS DISTINCT FROM OLD.timezone OR
      NEW.user_id IS DISTINCT FROM OLD.user_id) THEN
    RAISE EXCEPTION 'Partners can only update reaction or reacted_at';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_restrict_partner_updates
  BEFORE UPDATE ON moments
  FOR EACH ROW
  WHEN (are_partners(auth.uid(), OLD.user_id))
  EXECUTE FUNCTION restrict_partner_updates();

-- Function to generate invitation code
CREATE OR REPLACE FUNCTION generate_invitation_code()
RETURNS TEXT AS $$
DECLARE
  code TEXT;
  exists_check BOOLEAN;
BEGIN
  LOOP
    code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 6));
    SELECT EXISTS(SELECT 1 FROM partner_relationships WHERE invitation_code = code)
      INTO exists_check;
    IF NOT exists_check THEN
      RETURN code;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Trigger to set invitation code
CREATE OR REPLACE FUNCTION set_invitation_code()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.invitation_code IS NULL THEN
    NEW.invitation_code := generate_invitation_code();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER partner_relationships_invitation_code
  BEFORE INSERT ON partner_relationships
  FOR EACH ROW
  EXECUTE FUNCTION set_invitation_code();

-- Trigger to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER partner_relationships_updated_at
  BEFORE UPDATE ON partner_relationships
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER moments_updated_at
  BEFORE UPDATE ON moments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
