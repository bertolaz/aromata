import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/models/book.dart';
import '../domain/models/recipe.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Books operations
  Future<List<Book>> getBooks() async {
    try {
      final response = await _supabase
          .from('books')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map(
            (json) => Book(
              id: json['id'],
              title: json['title'],
              author: json['author'],
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch books: $e');
    }
  }

  Future<Book> createBook(String title, String author) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabase
          .from('books')
          .insert({'user_id': user.id, 'title': title, 'author': author})
          .select()
          .single();

      return Book(
        id: response['id'],
        title: response['title'],
        author: response['author'],
      );
    } catch (e) {
      throw Exception('Failed to create book: $e');
    }
  }

  Future<Book> updateBook(String id, String title, String author) async {
    try {
      final response = await _supabase
          .from('books')
          .update({'title': title, 'author': author})
          .eq('id', id)
          .select()
          .single();

      return Book(
        id: response['id'],
        title: response['title'],
        author: response['author'],
      );
    } catch (e) {
      throw Exception('Failed to update book: $e');
    }
  }

  Future<void> deleteBook(String id) async {
    try {
      await _supabase.from('books').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete book: $e');
    }
  }

  // Recipes operations
  Future<List<Recipe>> getRecipesByBookId(String bookId) async {
    try {
      final response = await _supabase
          .from('recipes')
          .select()
          .eq('book_id', bookId)
          .order('page', ascending: true);

      final recipes = (response as List)
          .map(
            (json) => Recipe(
              id: json['id'],
              bookId: json['book_id'],
              title: json['title'],
              page: json['page'],
              tags: [], // Will be loaded separately
            ),
          )
          .toList();

      // Load tags for each recipe
      final recipesWithTags = <Recipe>[];
      for (var recipe in recipes) {
        final tags = await getRecipeTags(recipe.id!);
        recipesWithTags.add(recipe.copyWith(tags: tags));
      }

      return recipesWithTags;
    } catch (e) {
      throw Exception('Failed to fetch recipes: $e');
    }
  }

  Future<List<Recipe>> getAllRecipes() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get all recipes from user's books
      final response = await _supabase
          .from('recipes')
          .select('''
            *,
            books!inner(user_id)
          ''')
          .eq('books.user_id', user.id)
          .order('page', ascending: true);

      final recipes = (response as List)
          .map(
            (json) => Recipe(
              id: json['id'],
              bookId: json['book_id'],
              title: json['title'],
              page: json['page'],
              tags: [], // Will be loaded separately
            ),
          )
          .toList();

      // Load tags for each recipe
      final recipesWithTags = <Recipe>[];
      for (var recipe in recipes) {
        final tags = await getRecipeTags(recipe.id!);
        recipesWithTags.add(recipe.copyWith(tags: tags));
      }

      return recipesWithTags;
    } catch (e) {
      throw Exception('Failed to fetch all recipes: $e');
    }
  }

  Future<Recipe> createRecipe(
    String bookId,
    String title,
    int page,
    List<String> tags,
  ) async {
    try {
      final response = await _supabase
          .from('recipes')
          .insert({'book_id': bookId, 'title': title, 'page': page})
          .select()
          .single();

      // Add tags
      if (tags.isNotEmpty) {
        await addRecipeTags(response['id'], tags);
      }

      return Recipe(
        id: response['id'],
        bookId: response['book_id'],
        title: response['title'],
        page: response['page'],
        tags: tags,
      );
    } catch (e) {
      throw Exception('Failed to create recipe: $e');
    }
  }

  Future<List<Recipe>> createRecipeBulk(
    List<Map<String, dynamic>> recipes,
  ) async {
    try {
      if (recipes.isEmpty) {
        return [];
      }

      // Prepare recipe data for bulk insert
      final recipesData = recipes.map((recipe) => {
        'book_id': recipe['book_id'],
        'title': recipe['title'],
        'page': recipe['page'],
      }).toList();

      // Bulk insert recipes
      final response = await _supabase
          .from('recipes')
          .insert(recipesData)
          .select();

      final createdRecipes = (response as List)
          .map((json) => Recipe(
                id: json['id'],
                bookId: json['book_id'],
                title: json['title'],
                page: json['page'],
                tags: [],
              ))
          .toList();

      // Add tags for each recipe in bulk
      final tagsData = <Map<String, dynamic>>[];
      for (var i = 0; i < createdRecipes.length; i++) {
        final recipe = recipes[i];
        final tags = recipe['tags'] as List<String>? ?? [];
        final recipeId = createdRecipes[i].id!;
        
        for (final tag in tags) {
          tagsData.add({
            'recipe_id': recipeId,
            'tag': tag,
          });
        }
      }

      // Bulk insert tags if any
      if (tagsData.isNotEmpty) {
        await _supabase.from('recipe_tags').insert(tagsData);
      }

      // Load tags for each recipe to return complete recipes
      final recipesWithTags = <Recipe>[];
      for (var recipe in createdRecipes) {
        final tags = await getRecipeTags(recipe.id!);
        recipesWithTags.add(recipe.copyWith(tags: tags));
      }

      return recipesWithTags;
    } catch (e) {
      throw Exception('Failed to create recipes in bulk: $e');
    }
  }

  Future<Recipe> updateRecipe(
    String id,
    String title,
    int page,
    List<String> tags,
  ) async {
    try {
      final response = await _supabase
          .from('recipes')
          .update({'title': title, 'page': page})
          .eq('id', id)
          .select()
          .single();

      // Update tags
      await deleteRecipeTags(id);
      if (tags.isNotEmpty) {
        await addRecipeTags(id, tags);
      }

      return Recipe(
        id: response['id'],
        bookId: response['book_id'],
        title: response['title'],
        page: response['page'],
        tags: tags,
      );
    } catch (e) {
      throw Exception('Failed to update recipe: $e');
    }
  }

  Future<void> deleteRecipe(String id) async {
    try {
      await _supabase.from('recipes').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete recipe: $e');
    }
  }

  // Tags operations
  Future<List<String>> getRecipeTags(String recipeId) async {
    try {
      final response = await _supabase
          .from('recipe_tags')
          .select('tag')
          .eq('recipe_id', recipeId)
          .order('tag', ascending: true);

      return (response as List).map((json) => json['tag'] as String).toList();
    } catch (e) {
      throw Exception('Failed to fetch tags: $e');
    }
  }

  Future<void> addRecipeTags(String recipeId, List<String> tags) async {
    try {
      if (tags.isEmpty) return;

      final tagsData = tags
          .map((tag) => {'recipe_id': recipeId, 'tag': tag})
          .toList();

      await _supabase.from('recipe_tags').insert(tagsData);
    } catch (e) {
      throw Exception('Failed to add tags: $e');
    }
  }

  Future<void> deleteRecipeTags(String recipeId) async {
    try {
      await _supabase.from('recipe_tags').delete().eq('recipe_id', recipeId);
    } catch (e) {
      throw Exception('Failed to delete tags: $e');
    }
  }

  Future<List<Recipe>> extractRecipesFromImage(
    String imageBase64,
    String bookId,
  ) async {
    var userSession = _supabase.auth.currentSession;
    if (userSession == null) {
      throw Exception('User not authenticated');
    }
    final response = await _supabase.functions.invoke(
      'extract-recipes',
      body: {'image_base64': imageBase64, 'book_id': bookId},
    );

    if (response.data == null) {
      throw Exception('No data returned from API');
    }

    try {
      final data = response.data as Map<String, dynamic>;

      // Check for error response
      if (data.containsKey('error')) {
        throw Exception(data['error'] as String);
      }

      // Extract recipes array
      final recipesData = data['recipes'] as List<dynamic>?;
      if (recipesData == null) {
        throw Exception('No recipes found in response');
      }

      // Map recipes - Edge Function returns only title and page
      return recipesData
          .map(
            (recipe) => Recipe(
              id: null, // Recipes don't have IDs until they're saved
              bookId: bookId, // Use the bookId parameter
              title: recipe['title'] as String,
              page: recipe['page'] as int,
              tags: [],
            ),
          )
          .toList();
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to extract recipes from image: $e');
    }
  }
}
