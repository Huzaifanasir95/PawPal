-- Migration 007: Add categories to posts table
-- Run this in Supabase SQL Editor

-- Add category column to posts table
ALTER TABLE posts 
ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'general';

-- Create index for faster category filtering
CREATE INDEX IF NOT EXISTS idx_posts_category ON posts(category);

-- Update existing posts to have 'general' category if null
UPDATE posts SET category = 'general' WHERE category IS NULL;

-- Add comment to document valid categories
COMMENT ON COLUMN posts.category IS 'Valid categories: general, dogs, cats, health, training, nutrition, funny, questions';
