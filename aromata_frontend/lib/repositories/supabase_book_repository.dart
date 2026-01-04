import '../domain/models/book.dart';
import 'book_repository.dart';
import '../services/supabase_service.dart';

/// Supabase implementation of IBookRepository
class SupabaseBookRepository implements IBookRepository {
  final SupabaseService _supabaseService;

  SupabaseBookRepository(this._supabaseService);

  @override
  Future<List<Book>> getBooks() async {
    return await _supabaseService.getBooks();
  }

  @override
  Future<Book?> getBookById(String id) async {
    final books = await _supabaseService.getBooks();
    try {
      return books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Book> createBook(String title, String author) async {
    await _supabaseService.createBook(title, author);
    // Fetch the newly created book
    final books = await _supabaseService.getBooks();
    return books.firstWhere(
      (book) => book.title == title && book.author == author,
    );
  }

  @override
  Future<void> updateBook(String id, String title, String author) async {
    await _supabaseService.updateBook(id, title, author);
  }

  @override
  Future<void> deleteBook(String id) async {
    await _supabaseService.deleteBook(id);
  }
}

