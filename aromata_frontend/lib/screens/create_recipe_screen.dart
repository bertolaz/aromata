import 'package:flutter/material.dart';
import '../models/recipe.dart';

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
  final _titleController = TextEditingController();
  final _pageController = TextEditingController();
  final _tagController = TextEditingController();
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _titleController.text = widget.recipe!.title;
      _pageController.text = widget.recipe!.page.toString();
      _tags = List<String>.from(widget.recipe!.tags);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _pageController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final page = int.tryParse(_pageController.text.trim());
      if (page == null || page < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid page number'),
          ),
        );
        return;
      }

      final recipe = Recipe(
        id: widget.recipe?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        bookId: widget.bookId,
        title: _titleController.text.trim(),
        page: page,
        tags: _tags,
      );
      Navigator.pop(context, recipe);
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
              controller: _titleController,
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
              controller: _pageController,
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
                    controller: _tagController,
                    decoration: const InputDecoration(
                      labelText: 'Add Tag',
                      hintText: 'Enter tag name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onFieldSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add_circle),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                  );
                }).toList(),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveRecipe,
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
  }
}

