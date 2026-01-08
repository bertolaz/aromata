import 'package:aromata_frontend/routing/routes.dart';
import 'package:aromata_frontend/ui/core/page_scaffold.dart';
import 'package:aromata_frontend/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../view_models/search_recipe_detail_viewmodel.dart';

class SearchRecipeDetailScreen extends StatelessWidget {
  final SearchRecipeDetailViewModel viewModel;

  const SearchRecipeDetailScreen({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final recipe = viewModel.recipe;
        final book = viewModel.book;

        // Show loading while data is being fetched
        if (viewModel.loadData.running || (recipe == null && book == null)) {
          return PageScaffold(
            title: 'Recipe Details',
            hideProfileButton: true,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // Show error state if data failed to load
        if (recipe == null || book == null) {
          String errorMessage = 'Unknown error';
          final result = viewModel.loadData.result;
          if (result != null) {
            switch (result) {
              case Error():
                errorMessage = result.error.toString();
                break;
              case Ok():
                errorMessage = 'Data not found';
                break;
            }
          }

          return PageScaffold(
            title: 'Recipe Details',
            hideProfileButton: true,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load recipe',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      errorMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return PageScaffold(
          title: recipe.title,
          hideProfileButton: true,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book information section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.book,
                            size: 20,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'From Book',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            book.author,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: () {
                          context.pushNamed(
                            RouteNames.bookDetail,
                            pathParameters: {'bookId': book.id!},
                          );
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('View Book'),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),

                // Recipe information section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recipe title
                      Text(
                        recipe.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Page number
                      Row(
                        children: [
                          Icon(
                            Icons.bookmark,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Page ${recipe.page}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tags section
                      if (recipe.tags.isNotEmpty) ...[
                        Text(
                          'Tags',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: recipe.tags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondaryContainer,
                              labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        Text(
                          'No tags',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

