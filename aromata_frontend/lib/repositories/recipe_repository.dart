import '../domain/models/recipe.dart';

/// Repository interface for recipe operations
abstract class IRecipeRepository {
  /// Get all recipes for the current user
  Future<List<Recipe>> getAllRecipes();

  /// Get recipes for a specific book
  Future<List<Recipe>> getRecipesByBookId(String bookId);

  /// Get a recipe by ID
  Future<Recipe?> getRecipeById(String id);

  /// Create a new recipe
  Future<Recipe> createRecipe(String bookId, String title, int page, List<String> tags);

  /// Update an existing recipe
  Future<void> updateRecipe(String id, String title, int page, List<String> tags);

  /// Delete a recipe
  Future<void> deleteRecipe(String id);
}

