import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/models/recipe.dart';
import '../viewmodels/create_recipe_viewmodel.dart';

class CreateRecipeScreen extends StatefulWidget {
  final String bookId;
  final Recipe? recipe;
  final Future<void> Function(Recipe)? onRecipeDeleted;

  const CreateRecipeScreen({
    super.key,
    required this.bookId,
    this.recipe,
    this.onRecipeDeleted,
  });

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  late CreateRecipeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CreateRecipeViewModel(
      bookId: widget.bookId,
      initialRecipe: widget.recipe,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final recipe = _viewModel.createRecipe();
      if (recipe != null) {
        Navigator.pop(context, recipe);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid page number'),
          ),
        );
      }
    }
  }

  void _deleteRecipe() {
    if (widget.recipe == null || widget.onRecipeDeleted == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Recipe'),
          content: Text(
            'Are you sure you want to delete "${widget.recipe!.title}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                try {
                  await widget.onRecipeDeleted!(widget.recipe!);
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Navigate back
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting recipe: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<CreateRecipeViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.recipe == null ? 'New Recipe' : 'Edit Recipe'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: [
                if (widget.recipe != null && widget.onRecipeDeleted != null)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete Recipe',
                    onPressed: _deleteRecipe,
                    color: Theme.of(context).colorScheme.error,
                  ),
              ],
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    onChanged: (value) => viewModel.setTitle(value),
                    initialValue: viewModel.title,
                    decoration: const InputDecoration(
                      labelText: 'Recipe Title',
                      hintText: 'Enter recipe title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.restaurant_menu),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a recipe title';
                      }
                      return null;
                    },
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    onChanged: (value) => viewModel.setPage(value),
                    initialValue: viewModel.page,
                    decoration: const InputDecoration(
                      labelText: 'Page Number',
                      hintText: 'Enter page number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.book),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a page number';
                      }
                      final page = int.tryParse(value.trim());
                      if (page == null || page < 1) {
                        return 'Please enter a valid page number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          onChanged: (value) => viewModel.setTagInput(value),
                          onFieldSubmitted: (_) => viewModel.addTag(),
                          initialValue: viewModel.tagInput,
                          decoration: const InputDecoration(
                            labelText: 'Add Tag',
                            hintText: 'Enter tag name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.tag),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => viewModel.addTag(),
                        icon: const Icon(Icons.add_circle),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (viewModel.tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: viewModel.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          onDeleted: () => viewModel.removeTag(tag),
                          deleteIcon: const Icon(Icons.close, size: 18),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: viewModel.isValid ? _saveRecipe : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.recipe == null ? 'Create Recipe' : 'Update Recipe',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
