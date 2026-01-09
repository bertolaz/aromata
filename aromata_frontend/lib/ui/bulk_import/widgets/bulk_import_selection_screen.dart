import 'package:aromata_frontend/ui/core/page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:aromata_frontend/utils/result.dart';
import '../view_models/bulk_import_viewmodel.dart';

class BulkImportSelectionScreen extends StatefulWidget {
  final BulkImportViewModel viewModel;

  const BulkImportSelectionScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<BulkImportSelectionScreen> createState() =>
      _BulkImportSelectionScreenState();
}

class _BulkImportSelectionScreenState
    extends State<BulkImportSelectionScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.importSelectedRecipes.addListener(_onImportResult);
  }

  @override
  void didUpdateWidget(covariant BulkImportSelectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.importSelectedRecipes.removeListener(_onImportResult);
    widget.viewModel.importSelectedRecipes.addListener(_onImportResult);
  }

  @override
  void dispose() {
    widget.viewModel.importSelectedRecipes.removeListener(_onImportResult);
    super.dispose();
  }

  void _onImportResult() {
    final result = widget.viewModel.importSelectedRecipes.result;
    if (result == null) return;

    switch (result) {
      case Ok():
        widget.viewModel.importSelectedRecipes.clearResult();
        // Pop back to book detail screen (pop processing + selection screens)
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Pop selection screen
        }
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Pop processing screen
        }
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(); // Pop bulk import screen
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipes imported successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case Error():
        widget.viewModel.importSelectedRecipes.clearResult();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing recipes: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final viewModel = widget.viewModel;
        return PageScaffold(
          title: 'Select Recipes to Import',
          hideProfileButton: true,
          child: SafeArea(
            child: Column(
              children: [
                // Header with selection info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Extracted Recipes (${viewModel.extractedRecipes.length})',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (viewModel.hasSelectedRecipes)
                                  Text(
                                    '${viewModel.selectedRecipeIndices.length} selected',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          if (viewModel.selectedRecipeIndices.length <
                              viewModel.extractedRecipes.length)
                            TextButton.icon(
                              onPressed: () => viewModel.selectAllRecipes(),
                              icon: const Icon(Icons.select_all, size: 18),
                              label: const Text('Select All'),
                            ),
                          if (viewModel.hasSelectedRecipes)
                            TextButton.icon(
                              onPressed: () => viewModel.deselectAllRecipes(),
                              icon: const Icon(Icons.deselect, size: 18),
                              label: const Text('Deselect All'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Recipe list
                Expanded(
                  child: viewModel.extractedRecipes.isEmpty
                      ? Center(
                          child: Text(
                            'No recipes found',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: viewModel.extractedRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = viewModel.extractedRecipes[index];
                            final isSelected =
                                viewModel.selectedRecipeIndices.contains(index);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              color: isSelected
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withValues(alpha: 0.3)
                                  : null,
                              child: CheckboxListTile(
                                value: isSelected,
                                onChanged: (value) =>
                                    viewModel.toggleRecipeSelection(index),
                                secondary: CircleAvatar(
                                  child: Text(
                                    recipe.page.toString(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                title: Text(
                                  recipe.title,
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Page ${recipe.page}'),
                                    if (recipe.tags.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Wrap(
                                          spacing: 4,
                                          runSpacing: 4,
                                          children: recipe.tags
                                              .map(
                                                (tag) => Chip(
                                                  label: Text(
                                                    tag,
                                                    style:
                                                        const TextStyle(fontSize: 11),
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Import button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: viewModel.hasSelectedRecipes &&
                            !viewModel.importSelectedRecipes.running
                        ? () => viewModel.importSelectedRecipes.execute()
                        : null,
                    icon: viewModel.importSelectedRecipes.running
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      viewModel.hasSelectedRecipes
                          ? 'Import (${viewModel.selectedRecipeIndices.length})'
                          : 'Import',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 0),
                    ),
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
