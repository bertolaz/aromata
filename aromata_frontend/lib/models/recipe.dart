class Recipe {
  final String? id;
  final String bookId;
  final String title;
  final int page;
  final List<String> tags;

  Recipe({
    this.id,
    required this.bookId,
    required this.title,
    required this.page,
    this.tags = const [],
  });

  Recipe copyWith({
    String? id,
    String? bookId,
    String? title,
    int? page,
    List<String>? tags,
  }) {
    return Recipe(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      page: page ?? this.page,
      tags: tags ?? this.tags,
    );
  }
}

