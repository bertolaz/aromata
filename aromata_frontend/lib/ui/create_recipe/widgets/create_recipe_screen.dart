import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aromata_frontend/utils/result.dart';
import '../view_models/create_recipe_viewmodel.dart';

class CreateRecipeScreen extends StatefulWidget {
  final CreateRecipeViewModel viewModel;

  const CreateRecipeScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.viewModel.saveRecipe.addListener(_onSaveRecipeResult);
    widget.viewModel.deleteRecipe.addListener(_onDeleteRecipeResult);
  }

  @override
  void didUpdateWidget(covariant CreateRecipeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.saveRecipe.removeListener(_onSaveRecipeResult);
    oldWidget.viewModel.deleteRecipe.removeListener(_onDeleteRecipeResult);
    widget.viewModel.saveRecipe.addListener(_onSaveRecipeResult);
    widget.viewModel.deleteRecipe.addListener(_onDeleteRecipeResult);
  }

  @override
  void dispose() {
    widget.viewModel.saveRecipe.removeListener(_onSaveRecipeResult);
    widget.viewModel.deleteRecipe.removeListener(_onDeleteRecipeResult);
    super.dispose();
  }

  void _onSaveRecipeResult() {
    final result = widget.viewModel.saveRecipe.result;
    if (result == null) return;

    switch (result) {
      case Ok():
        widget.viewModel.saveRecipe.clearResult();
        context.pop();
        break;
      case Error():
        widget.viewModel.saveRecipe.clearResult();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving recipe: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }

  void _onDeleteRecipeResult() {
    final result = widget.viewModel.deleteRecipe.result;
    if (result == null) return;

    switch (result) {
      case Ok():
        widget.viewModel.deleteRecipe.clearResult();
        context.pop();
        break;
      case Error():
        widget.viewModel.deleteRecipe.clearResult();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting recipe: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      widget.viewModel.saveRecipe.execute();
    }
  }

  void _deleteRecipe() {
    if (widget.viewModel.initialRecipeId == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Recipe'),
          content: Text(
            'Are you sure you want to delete "${widget.viewModel.title}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.viewModel.deleteRecipe.execute();
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
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final viewModel = widget.viewModel;
        return Scaffold(
          appBar: AppBar(
            title: Text(viewModel.initialRecipeId == null ? 'New Recipe' : 'Edit Recipe'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              if (viewModel.initialRecipeId != null)
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
                  onPressed: viewModel.isValid && !viewModel.saveRecipe.running
                      ? _saveRecipe
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: viewModel.saveRecipe.running
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          viewModel.initialRecipeId == null ? 'Create Recipe' : 'Update Recipe',
                          style: const TextStyle(fontSize: 16),
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

