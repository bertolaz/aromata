import '../domain/models/book.dart';

/// Repository interface for book operations
abstract class BookRepository {
  /// Get all books for the current user
  Future<List<Book>> getBooks();

  /// Get a book by ID
  Future<Book?> getBookById(String id);

  /// Create a new book
  Future<Book> createBook(String title, String author);

  /// Update an existing book
  Future<void> updateBook(String id, String title, String author);

  /// Delete a book
  Future<void> deleteBook(String id);
}

