import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recipe.dart';

class BulkImportScreen extends StatefulWidget {
  final String bookId;
  final Function(List<Recipe>) onRecipesImported;

  const BulkImportScreen({
    super.key,
    required this.bookId,
    required this.onRecipesImported,
  });

  @override
  State<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends State<BulkImportScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isProcessing = false;
  List<Recipe> _extractedRecipes = [];

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _extractedRecipes = [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _extractedRecipes = [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // TODO: Replace this with your AI processing logic
      // This is a placeholder that simulates processing
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Call your AI service here to extract recipes from the image
      // Example structure:
      // final extractedData = await aiService.processImage(_selectedImage!);
      // final recipes = _parseExtractedData(extractedData);

      // Placeholder: Create sample recipes for demonstration
      // Remove this when implementing actual AI processing
      final List<Recipe> recipes = [
        Recipe(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          bookId: widget.bookId,
          title: 'Sample Recipe 1',
          page: 10,
          tags: ['dessert'],
        ),
        Recipe(
          id: '${DateTime.now().millisecondsSinceEpoch + 1}',
          bookId: widget.bookId,
          title: 'Sample Recipe 2',
          page: 15,
          tags: ['main course'],
        ),
      ];

      setState(() {
        _extractedRecipes = recipes;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _importRecipes() {
    if (_extractedRecipes.isEmpty) return;

    widget.onRecipesImported(_extractedRecipes);
    Navigator.pop(context, _extractedRecipes);
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _extractedRecipes = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Import Recipes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How it works',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Take a photo or select an image of recipe pages\n'
                      '2. AI will extract recipe information\n'
                      '3. Review and import the extracted recipes',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Image selection
            if (_selectedImage == null) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImageFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('From Gallery'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Selected image preview
              Card(
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Image.file(
                      File(_selectedImage!.path),
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        onPressed: _clearImage,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Process button
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processImage,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isProcessing ? 'Processing...' : 'Process with AI'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],

            // Extracted recipes
            if (_extractedRecipes.isNotEmpty) ...[
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Extracted Recipes (${_extractedRecipes.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: _importRecipes,
                    icon: const Icon(Icons.check),
                    label: const Text('Import All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._extractedRecipes.map((recipe) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        recipe.page.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    title: Text(
                      recipe.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Page ${recipe.page}'),
                        if (recipe.tags.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: recipe.tags.map(
                              (tag) => Chip(
                                label: Text(
                                  tag,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                            ).toList(),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}

