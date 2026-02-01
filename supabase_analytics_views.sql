-- ==========================================
-- SINO B2B Analytics Views (Phase 3)
-- Run this in the Supabase SQL Editor
-- ==========================================

-- NOTE: These views return ANONYMIZED data only.
-- Individual student identities are never exposed to administrators.

-- 1. Daily Mood Aggregates (Anonymized)
-- Shows average sentiment per day across all users
CREATE OR REPLACE VIEW analytics_daily_mood AS
SELECT 
  DATE(created_at) as date,
  COUNT(*) as entry_count,
  ROUND(AVG(sentiment_score)::numeric, 2) as avg_sentiment,
  COUNT(CASE WHEN sentiment_score < -0.3 THEN 1 END) as concern_count,
  COUNT(CASE WHEN sentiment_score > 0.3 THEN 1 END) as positive_count
FROM mood_entries
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- 2. Risk Distribution (Anonymized)
-- Shows count of users by risk tier (based on recent mood)
CREATE OR REPLACE VIEW analytics_risk_distribution AS
WITH recent_moods AS (
  SELECT 
    user_id,
    AVG(sentiment_score) as avg_sentiment
  FROM mood_entries
  WHERE created_at > NOW() - INTERVAL '7 days'
  GROUP BY user_id
)
SELECT 
  CASE 
    WHEN avg_sentiment < -0.5 THEN 'high_risk'
    WHEN avg_sentiment < -0.2 THEN 'moderate_risk'
    WHEN avg_sentiment < 0.2 THEN 'neutral'
    ELSE 'positive'
  END as risk_tier,
  COUNT(*) as user_count
FROM recent_moods
GROUP BY risk_tier;

-- 3. Weekly Trends (Anonymized)
-- Shows week-over-week changes in student wellness
CREATE OR REPLACE VIEW analytics_weekly_trends AS
SELECT 
  DATE_TRUNC('week', created_at) as week_start,
  COUNT(DISTINCT user_id) as active_users,
  COUNT(*) as total_entries,
  ROUND(AVG(sentiment_score)::numeric, 2) as avg_sentiment,
  ROUND(STDDEV(sentiment_score)::numeric, 2) as sentiment_variance
FROM mood_entries
WHERE created_at > NOW() - INTERVAL '8 weeks'
GROUP BY DATE_TRUNC('week', created_at)
ORDER BY week_start DESC;

-- 4. Source Breakdown (Anonymized)
-- Shows which features generate mood data
CREATE OR REPLACE VIEW analytics_source_breakdown AS
SELECT 
  source,
  COUNT(*) as entry_count,
  ROUND(AVG(sentiment_score)::numeric, 2) as avg_sentiment
FROM mood_entries
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY source
ORDER BY entry_count DESC;

-- 5. Academic Stress Correlation (Anonymized)
-- Shows relationship between task completion and mood
CREATE OR REPLACE VIEW analytics_academic_stress AS
WITH user_task_stats AS (
  SELECT 
    user_id,
    COUNT(*) as total_tasks,
    COUNT(CASE WHEN is_completed THEN 1 END) as completed_tasks,
    COUNT(CASE WHEN NOT is_completed AND due_date < NOW() THEN 1 END) as overdue_tasks
  FROM academic_tasks
  GROUP BY user_id
),
user_mood_stats AS (
  SELECT 
    user_id,
    AVG(sentiment_score) as avg_sentiment
  FROM mood_entries
  WHERE created_at > NOW() - INTERVAL '7 days'
  GROUP BY user_id
)
SELECT 
  CASE 
    WHEN t.overdue_tasks >= 3 THEN 'high_workload'
    WHEN t.overdue_tasks >= 1 THEN 'moderate_workload'
    ELSE 'on_track'
  END as workload_tier,
  COUNT(*) as user_count,
  ROUND(AVG(m.avg_sentiment)::numeric, 2) as avg_sentiment
FROM user_task_stats t
JOIN user_mood_stats m ON t.user_id = m.user_id
GROUP BY workload_tier;

-- ==========================================
-- Grant SELECT access to authenticated users
-- (RLS still applies - admins need separate role in production)
-- ==========================================
-- Note: For production, create an 'admin' role and grant to specific users
