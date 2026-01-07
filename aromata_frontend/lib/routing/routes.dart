abstract final class Routes {
  static const String login = '/login';
  static const String books = '/$booksRelative';
  static const String booksRelative = 'books';
  static  String bookWithId(String bookId) => '$books/$bookId';
  static const String createBook = '$books/create';
  static const String search = '/$searchRelative';
  static const String searchRelative = 'search';
  static const String recipes = '/$recipesRelative';
  static const String recipesRelative = 'recipes';
  static  String recipeWithId(String recipeId) => '$recipes/$recipeId';
  static  String createRecipe(String bookId) => '$recipes/create?bookId=$bookId';
  static  String bulkImport(String bookId) => '$recipes/bulk-import?bookId=$bookId';
  static const String profile = '/profile';
  static const String privacy = '/privacy';
}

abstract final class RouteNames {
  static const String login = 'login';
  static const String books = 'books';
  static const String bookDetail = 'book-detail';
  static const String createBook = 'create-book';
  static const String search = 'search-recipes';
  static const String recipes = 'recipes';
  static const String createRecipe = 'create-recipe';
  static const String profile = 'profile';
  static const String privacy = 'privacy';
}