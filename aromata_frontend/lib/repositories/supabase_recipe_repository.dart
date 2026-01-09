import '../domain/models/recipe.dart';
import 'recipe_repository.dart';
import '../services/supabase_service.dart';

/// Supabase implementation of IRecipeRepository
class SupabaseRecipeRepository implements RecipeRepository {
  final SupabaseService _supabaseService;

  SupabaseRecipeRepository(this._supabaseService);

  @override
  Future<List<Recipe>> getAllRecipes() async {
    return await _supabaseService.getAllRecipes();
  }

  @override
  Future<List<Recipe>> getRecipesByBookId(String bookId) async {
    final allRecipes = await _supabaseService.getAllRecipes();
    return allRecipes.where((recipe) => recipe.bookId == bookId).toList();
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    final recipes = await _supabaseService.getAllRecipes();
    try {
      return recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Recipe> createRecipe(
    String bookId,
    String title,
    int page,
    List<String> tags,
  ) async {
    await _supabaseService.createRecipe(bookId, title, page, tags);
    // Fetch the newly created recipe
    final recipes = await _supabaseService.getAllRecipes();
    return recipes.firstWhere(
      (recipe) =>
          recipe.bookId == bookId &&
          recipe.title == title &&
          recipe.page == page,
    );
  }

  @override
  Future<void> updateRecipe(
    String id,
    String title,
    int page,
    List<String> tags,
  ) async {
    await _supabaseService.updateRecipe(id, title, page, tags);
  }

  @override
  Future<void> deleteRecipe(String id) async {
    await _supabaseService.deleteRecipe(id);
  }

  @override
  Future<List<Recipe>> extractRecipesFromImage(
    String imageBase64,
    String bookId,
  ) async {
    final response = await _supabaseService.extractRecipesFromImage(
      imageBase64,
      bookId,
    );
    return response;
  }
}
