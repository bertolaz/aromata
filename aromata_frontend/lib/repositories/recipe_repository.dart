import '../domain/models/recipe.dart';

/// Repository interface for recipe operations
abstract class RecipeRepository {
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

  /// Extract recipes from an image
  /// The image is a base64 encoded string
  /// The bookId is the id of the book to extract recipes from
  /// The recipes are returned as a list of Recipe objects
  Future<List<Recipe>> extractRecipesFromImage(String imageBase64, String bookId);

  Future<void> createRecipeBulk(List<Recipe> selectedRecipes) async {}
}

