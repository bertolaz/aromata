import 'tag_repository.dart';
import '../services/supabase_service.dart';

/// Supabase implementation of ITagRepository
class SupabaseTagRepository implements TagRepository {
  final SupabaseService _supabaseService;

  SupabaseTagRepository(this._supabaseService);

  @override
  Future<List<String>> getRecipeTags(String recipeId) async {
    return await _supabaseService.getRecipeTags(recipeId);
  }

  @override
  Future<void> addRecipeTags(String recipeId, List<String> tags) async {
    await _supabaseService.addRecipeTags(recipeId, tags);
  }

  @override
  Future<void> deleteRecipeTags(String recipeId) async {
    await _supabaseService.deleteRecipeTags(recipeId);
  }

  @override
  Future<void> updateRecipeTags(String recipeId, List<String> tags) async {
    await deleteRecipeTags(recipeId);
    if (tags.isNotEmpty) {
      await addRecipeTags(recipeId, tags);
    }
  }
}

