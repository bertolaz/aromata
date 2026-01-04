import 'package:aromata_frontend/repositories/auth_repository.dart';
import 'package:provider/provider.dart';
import '../repositories/book_repository.dart';
import '../repositories/recipe_repository.dart';
import '../repositories/tag_repository.dart';
import '../repositories/supabase_book_repository.dart';
import '../repositories/supabase_recipe_repository.dart';
import '../repositories/supabase_tag_repository.dart';
import '../repositories/supabase_auth_repository.dart';
import '../services/supabase_service.dart';
import 'package:provider/single_child_widget.dart';

/// Creates and returns all dependency injection providers
/// This includes services and repositories
List<SingleChildWidget> get createDependencies {

  return [
    // Services
    Provider<SupabaseService>(create: (context) => SupabaseService()),
    // Repositories
    Provider<BookRepository>(create: (context) => SupabaseBookRepository(context.read())),
    Provider<RecipeRepository>(create: (context) => SupabaseRecipeRepository(context.read())),
    Provider<TagRepository>(create: (context) => SupabaseTagRepository(context.read())),
    ChangeNotifierProvider<AuthRepository>(create: (context) => SupabaseAuthRepository()),
  ];
}

