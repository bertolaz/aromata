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
          .map((json) => Book(
                id: json['id'],
                title: json['title'],
                author: json['author'],
              ))
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
          .insert({
            'user_id': user.id,
            'title': title,
            'author': author,
          })
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
          .update({
            'title': title,
            'author': author,
          })
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
          .map((json) => Recipe(
                id: json['id'],
                bookId: json['book_id'],
                title: json['title'],
                page: json['page'],
                tags: [], // Will be loaded separately
              ))
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
          .map((json) => Recipe(
                id: json['id'],
                bookId: json['book_id'],
                title: json['title'],
                page: json['page'],
                tags: [], // Will be loaded separately
              ))
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
          .insert({
            'book_id': bookId,
            'title': title,
            'page': page,
          })
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

  Future<Recipe> updateRecipe(
    String id,
    String title,
    int page,
    List<String> tags,
  ) async {
    try {
      final response = await _supabase
          .from('recipes')
          .update({
            'title': title,
            'page': page,
          })
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

      final tagsData = tags.map((tag) => {
            'recipe_id': recipeId,
            'tag': tag,
          }).toList();

      await _supabase.from('recipe_tags').insert(tagsData);
    } catch (e) {
      throw Exception('Failed to add tags: $e');
    }
  }

  Future<void> deleteRecipeTags(String recipeId) async {
    try {
      await _supabase
          .from('recipe_tags')
          .delete()
          .eq('recipe_id', recipeId);
    } catch (e) {
      throw Exception('Failed to delete tags: $e');
    }
  }
}

