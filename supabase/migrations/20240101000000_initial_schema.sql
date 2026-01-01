-- Enable UUID generation (Supabase-compatible)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

--------------------------------------------------
-- Tables
--------------------------------------------------

-- Books table
CREATE TABLE IF NOT EXISTS books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- Recipes table
CREATE TABLE IF NOT EXISTS recipes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  book_id UUID REFERENCES books(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  page INTEGER NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- Recipe tags table
CREATE TABLE IF NOT EXISTS recipe_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE NOT NULL,
  tag TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
  UNIQUE (recipe_id, tag)
);

--------------------------------------------------
-- Indexes
--------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_books_user_id ON books(user_id);
CREATE INDEX IF NOT EXISTS idx_recipes_book_id ON recipes(book_id);
CREATE INDEX IF NOT EXISTS idx_recipe_tags_recipe_id ON recipe_tags(recipe_id);
CREATE INDEX IF NOT EXISTS idx_recipe_tags_tag ON recipe_tags(tag);

--------------------------------------------------
-- Row Level Security
--------------------------------------------------

ALTER TABLE books ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_tags ENABLE ROW LEVEL SECURITY;

ALTER TABLE books FORCE ROW LEVEL SECURITY;
ALTER TABLE recipes FORCE ROW LEVEL SECURITY;
ALTER TABLE recipe_tags FORCE ROW LEVEL SECURITY;

--------------------------------------------------
-- RLS Policies
--------------------------------------------------



CREATE POLICY "Users manage their own books"
ON books
FOR ALL
TO authenticated
USING (
  (select auth.uid()) = user_id
)
WITH CHECK (
  (select auth.uid()) = user_id
);

--------------------------------------------------



CREATE POLICY "Users manage recipes from their books"
ON recipes
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM books
    WHERE books.id = recipes.book_id
      AND books.user_id = (select auth.uid())
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM books
    WHERE books.id = recipes.book_id
      AND books.user_id = (select auth.uid())
  )
);

--------------------------------------------------

CREATE POLICY "Users manage tags from their recipes"
ON recipe_tags
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1
    FROM recipes
    JOIN books ON books.id = recipes.book_id
    WHERE recipes.id = recipe_tags.recipe_id
      AND books.user_id = (select auth.uid())
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM recipes
    JOIN books ON books.id = recipes.book_id
    WHERE recipes.id = recipe_tags.recipe_id
      AND books.user_id = (select auth.uid())
  )
);

--------------------------------------------------
-- updated_at trigger
--------------------------------------------------

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  NEW.updated_at = timezone('utc', now());
  RETURN NEW;
END;
$$;

CREATE TRIGGER update_books_updated_at
BEFORE UPDATE ON books
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_recipes_updated_at
BEFORE UPDATE ON recipes
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
