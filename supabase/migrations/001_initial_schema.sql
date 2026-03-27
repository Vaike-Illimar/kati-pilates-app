-- ============================================================
-- Kati Pilates App — Initial Database Schema
-- ============================================================

-- ============================================================
-- ENUMS
-- ============================================================
CREATE TYPE user_role AS ENUM ('client', 'instructor', 'admin');
CREATE TYPE booking_status AS ENUM ('confirmed', 'waitlisted', 'cancelled', 'attended', 'no_show');
CREATE TYPE class_level AS ENUM ('algaja', 'kesktase', 'koik');
CREATE TYPE card_type AS ENUM ('4_sessions', '5_sessions', '10_sessions');
CREATE TYPE card_status AS ENUM ('active', 'paused', 'expired', 'depleted');
CREATE TYPE pause_reason AS ENUM ('haigus', 'vigastus', 'puhkus', 'muu');
CREATE TYPE notification_type AS ENUM ('uudine', 'meeldetuletus', 'oluline');
CREATE TYPE notification_status AS ENUM ('sent', 'scheduled', 'draft');
CREATE TYPE fixed_group_member_status AS ENUM ('active', 'paused', 'invited', 'declined');
CREATE TYPE cancel_type AS ENUM ('normal', 'late');

-- ============================================================
-- PROFILES (extends Supabase auth.users)
-- ============================================================
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  avatar_url TEXT,
  role user_role NOT NULL DEFAULT 'client',
  has_pilates_experience BOOLEAN DEFAULT false,
  training_location TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Auto-create profile on user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    COALESCE(NEW.email, '')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- STUDIOS
-- ============================================================
CREATE TABLE studios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT,
  capacity INT NOT NULL DEFAULT 10,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- CLASS DEFINITIONS (recurring templates)
-- ============================================================
CREATE TABLE class_definitions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  level class_level NOT NULL DEFAULT 'koik',
  duration_minutes INT NOT NULL DEFAULT 55,
  max_participants INT NOT NULL DEFAULT 10,
  studio_id UUID REFERENCES studios(id),
  instructor_id UUID REFERENCES profiles(id),
  day_of_week INT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time TIME NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER class_definitions_updated_at
  BEFORE UPDATE ON class_definitions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- CLASS INSTANCES (actual scheduled occurrences)
-- ============================================================
CREATE TABLE class_instances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_definition_id UUID NOT NULL REFERENCES class_definitions(id),
  date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  instructor_id UUID REFERENCES profiles(id),
  studio_id UUID REFERENCES studios(id),
  max_participants INT NOT NULL,
  is_cancelled BOOLEAN NOT NULL DEFAULT false,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(class_definition_id, date)
);

-- ============================================================
-- SESSION CARDS (Kaart)
-- ============================================================
CREATE TABLE session_cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  card_type card_type NOT NULL,
  total_sessions INT NOT NULL,
  remaining_sessions INT NOT NULL,
  price_cents INT NOT NULL,
  valid_from DATE NOT NULL DEFAULT CURRENT_DATE,
  valid_until DATE NOT NULL,
  original_valid_until DATE NOT NULL,
  status card_status NOT NULL DEFAULT 'active',
  purchased_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER session_cards_updated_at
  BEFORE UPDATE ON session_cards
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- BOOKINGS
-- ============================================================
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  class_instance_id UUID NOT NULL REFERENCES class_instances(id),
  status booking_status NOT NULL DEFAULT 'confirmed',
  waitlist_position INT,
  cancel_type cancel_type,
  session_deducted BOOLEAN NOT NULL DEFAULT false,
  card_id UUID REFERENCES session_cards(id),
  booked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, class_instance_id)
);

-- ============================================================
-- CARD PAUSES
-- ============================================================
CREATE TABLE card_pauses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  card_id UUID NOT NULL REFERENCES session_cards(id),
  reason pause_reason NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  notes TEXT,
  extension_days INT NOT NULL,
  created_by UUID NOT NULL REFERENCES profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- FIXED GROUPS (Pusiruhm)
-- ============================================================
CREATE TABLE fixed_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_definition_id UUID NOT NULL REFERENCES class_definitions(id),
  name TEXT NOT NULL,
  max_members INT NOT NULL DEFAULT 10,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER fixed_groups_updated_at
  BEFORE UPDATE ON fixed_groups
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TABLE fixed_group_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fixed_group_id UUID NOT NULL REFERENCES fixed_groups(id),
  user_id UUID NOT NULL REFERENCES profiles(id),
  status fixed_group_member_status NOT NULL DEFAULT 'invited',
  joined_at TIMESTAMPTZ,
  paused_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(fixed_group_id, user_id)
);

-- ============================================================
-- ADMIN NOTIFICATIONS
-- ============================================================
CREATE TABLE admin_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sender_id UUID NOT NULL REFERENCES profiles(id),
  subject TEXT NOT NULL,
  body TEXT NOT NULL,
  notification_type notification_type NOT NULL DEFAULT 'uudine',
  status notification_status NOT NULL DEFAULT 'draft',
  scheduled_at TIMESTAMPTZ,
  sent_at TIMESTAMPTZ,
  total_recipients INT NOT NULL DEFAULT 0,
  opened_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE admin_notification_recipients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  notification_id UUID NOT NULL REFERENCES admin_notifications(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id),
  is_read BOOLEAN NOT NULL DEFAULT false,
  read_at TIMESTAMPTZ,
  UNIQUE(notification_id, user_id)
);

-- ============================================================
-- USER NOTIFICATIONS (client-facing feed)
-- ============================================================
CREATE TABLE user_notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  action_url TEXT,
  action_label TEXT,
  is_read BOOLEAN NOT NULL DEFAULT false,
  source_type TEXT,
  source_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- DEVICE TOKENS (for push notifications)
-- ============================================================
CREATE TABLE device_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id),
  token TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('ios', 'android')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(user_id, token)
);

CREATE TRIGGER device_tokens_updated_at
  BEFORE UPDATE ON device_tokens
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_class_instances_date ON class_instances(date);
CREATE INDEX idx_class_instances_definition ON class_instances(class_definition_id);
CREATE INDEX idx_bookings_user ON bookings(user_id);
CREATE INDEX idx_bookings_class_instance ON bookings(class_instance_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_session_cards_user ON session_cards(user_id);
CREATE INDEX idx_session_cards_status ON session_cards(status);
CREATE INDEX idx_fixed_group_members_user ON fixed_group_members(user_id);
CREATE INDEX idx_fixed_group_members_group ON fixed_group_members(fixed_group_id);
CREATE INDEX idx_user_notifications_user ON user_notifications(user_id, is_read);
CREATE INDEX idx_device_tokens_user ON device_tokens(user_id);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

-- Helper function to check if current user is admin/instructor
CREATE OR REPLACE FUNCTION is_admin_or_instructor()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role IN ('admin', 'instructor')
  );
$$ LANGUAGE sql SECURITY DEFINER;

-- PROFILES
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Admins can view all profiles"
  ON profiles FOR SELECT USING (is_admin_or_instructor());
CREATE POLICY "Admins can update all profiles"
  ON profiles FOR UPDATE USING (is_admin_or_instructor());

-- STUDIOS
ALTER TABLE studios ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view studios"
  ON studios FOR SELECT USING (true);
CREATE POLICY "Admins can manage studios"
  ON studios FOR ALL USING (is_admin_or_instructor());

-- CLASS DEFINITIONS
ALTER TABLE class_definitions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view class definitions"
  ON class_definitions FOR SELECT USING (true);
CREATE POLICY "Admins can manage class definitions"
  ON class_definitions FOR ALL USING (is_admin_or_instructor());

-- CLASS INSTANCES
ALTER TABLE class_instances ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view class instances"
  ON class_instances FOR SELECT USING (true);
CREATE POLICY "Admins can manage class instances"
  ON class_instances FOR ALL USING (is_admin_or_instructor());

-- BOOKINGS
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own bookings"
  ON bookings FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own bookings"
  ON bookings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own bookings"
  ON bookings FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Admins can manage all bookings"
  ON bookings FOR ALL USING (is_admin_or_instructor());

-- SESSION CARDS
ALTER TABLE session_cards ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own cards"
  ON session_cards FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Admins can manage all cards"
  ON session_cards FOR ALL USING (is_admin_or_instructor());

-- CARD PAUSES
ALTER TABLE card_pauses ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own card pauses"
  ON card_pauses FOR SELECT USING (
    EXISTS (SELECT 1 FROM session_cards WHERE session_cards.id = card_pauses.card_id AND session_cards.user_id = auth.uid())
  );
CREATE POLICY "Admins can manage card pauses"
  ON card_pauses FOR ALL USING (is_admin_or_instructor());

-- FIXED GROUPS
ALTER TABLE fixed_groups ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view fixed groups"
  ON fixed_groups FOR SELECT USING (true);
CREATE POLICY "Admins can manage fixed groups"
  ON fixed_groups FOR ALL USING (is_admin_or_instructor());

-- FIXED GROUP MEMBERS
ALTER TABLE fixed_group_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own memberships"
  ON fixed_group_members FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own memberships"
  ON fixed_group_members FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Admins can manage all memberships"
  ON fixed_group_members FOR ALL USING (is_admin_or_instructor());

-- USER NOTIFICATIONS
ALTER TABLE user_notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own notifications"
  ON user_notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notifications"
  ON user_notifications FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "System can insert notifications"
  ON user_notifications FOR INSERT WITH CHECK (true);

-- ADMIN NOTIFICATIONS
ALTER TABLE admin_notifications ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can manage admin notifications"
  ON admin_notifications FOR ALL USING (is_admin_or_instructor());

-- ADMIN NOTIFICATION RECIPIENTS
ALTER TABLE admin_notification_recipients ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own notification recipients"
  ON admin_notification_recipients FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can update own notification recipients"
  ON admin_notification_recipients FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Admins can manage notification recipients"
  ON admin_notification_recipients FOR ALL USING (is_admin_or_instructor());

-- DEVICE TOKENS
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage own device tokens"
  ON device_tokens FOR ALL USING (auth.uid() = user_id);

-- ============================================================
-- VIEWS (for convenient queries)
-- ============================================================

-- Class instances with booking counts
CREATE OR REPLACE VIEW class_instances_with_counts AS
SELECT
  ci.*,
  cd.name AS class_name,
  cd.description AS class_description,
  cd.level,
  cd.duration_minutes,
  p.full_name AS instructor_name,
  s.name AS studio_name,
  COALESCE(bc.confirmed_count, 0) AS confirmed_count,
  COALESCE(bc.waitlist_count, 0) AS waitlist_count,
  ci.max_participants - COALESCE(bc.confirmed_count, 0) AS available_spots
FROM class_instances ci
JOIN class_definitions cd ON ci.class_definition_id = cd.id
LEFT JOIN profiles p ON ci.instructor_id = p.id
LEFT JOIN studios s ON ci.studio_id = s.id
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) FILTER (WHERE status = 'confirmed') AS confirmed_count,
    COUNT(*) FILTER (WHERE status = 'waitlisted') AS waitlist_count
  FROM bookings
  WHERE class_instance_id = ci.id
) bc ON true;

-- User bookings with class details
CREATE OR REPLACE VIEW user_bookings_detailed AS
SELECT
  b.*,
  ci.date AS class_date,
  ci.start_time AS class_start_time,
  ci.end_time AS class_end_time,
  cd.name AS class_name,
  cd.level,
  cd.duration_minutes,
  p.full_name AS instructor_name,
  s.name AS studio_name
FROM bookings b
JOIN class_instances ci ON b.class_instance_id = ci.id
JOIN class_definitions cd ON ci.class_definition_id = cd.id
LEFT JOIN profiles p ON ci.instructor_id = p.id
LEFT JOIN studios s ON ci.studio_id = s.id;
