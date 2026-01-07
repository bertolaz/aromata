/// Repository interface for tag operations
abstract class TagRepository {
  /// Get all tags for a recipe
  Future<List<String>> getRecipeTags(String recipeId);

  /// Add tags to a recipe
  Future<void> addRecipeTags(String recipeId, List<String> tags);

  /// Delete all tags for a recipe
  Future<void> deleteRecipeTags(String recipeId);

  /// Update tags for a recipe (replaces all existing tags)
  Future<void> updateRecipeTags(String recipeId, List<String> tags);
}

