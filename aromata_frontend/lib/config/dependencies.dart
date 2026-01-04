import 'package:provider/provider.dart';
import '../repositories/book_repository.dart';
import '../repositories/recipe_repository.dart';
import '../repositories/tag_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/supabase_book_repository.dart';
import '../repositories/supabase_recipe_repository.dart';
import '../repositories/supabase_tag_repository.dart';
import '../repositories/supabase_auth_repository.dart';
import '../services/supabase_service.dart';

/// Creates and returns all dependency injection providers
/// This includes services and repositories
List<Provider> createDependencies() {
  // Create service instance (singleton)
  final supabaseService = SupabaseService();

  // Create repository instances (singletons)
  final bookRepository = SupabaseBookRepository(supabaseService);
  final recipeRepository = SupabaseRecipeRepository(supabaseService);
  final tagRepository = SupabaseTagRepository(supabaseService);
  final authRepository = SupabaseAuthRepository();

  return [
    // Services
    Provider<SupabaseService>.value(value: supabaseService),

    // Repositories
    Provider<IBookRepository>.value(value: bookRepository),
    Provider<IRecipeRepository>.value(value: recipeRepository),
    Provider<ITagRepository>.value(value: tagRepository),
    Provider<IAuthRepository>.value(value: authRepository),
  ];
}

