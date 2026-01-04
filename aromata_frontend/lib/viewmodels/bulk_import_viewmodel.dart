import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image/image.dart' as img;
import '../domain/models/recipe.dart';
import 'base_viewmodel.dart';

class BulkImportViewModel extends BaseViewModel {
  final String bookId;
  final Function(List<Recipe>) onRecipesImported;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImage;
  List<Recipe> _extractedRecipes = [];
  Set<int> _selectedRecipeIndices = {};

  BulkImportViewModel({
    required this.bookId,
    required this.onRecipesImported,
  });

  Uint8List? get selectedImage => _selectedImage;
  List<Recipe> get extractedRecipes => _extractedRecipes;
  bool get hasExtractedRecipes => _extractedRecipes.isNotEmpty;
  Set<int> get selectedRecipeIndices => _selectedRecipeIndices;
  bool get hasSelectedRecipes => _selectedRecipeIndices.isNotEmpty;

  /// Pick image from camera
  Future<void> pickImageFromCamera() async {
    await execute(() async {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final convertedBytes = await _convertToJpgIfNeeded(bytes, image.name);
        _selectedImage = convertedBytes;
        _extractedRecipes = [];
        _selectedRecipeIndices.clear();
        notifyListeners();
      }
    });
  }

  /// Pick image from gallery
  Future<void> pickImageFromGallery() async {
    await execute(() async {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final convertedBytes = await _convertToJpgIfNeeded(bytes, image.name);
        _selectedImage = convertedBytes;
        _extractedRecipes = [];
        _selectedRecipeIndices.clear();
        notifyListeners();
      }
    });
  }

  /// Convert HEIC/HEIF images to JPG format
  Future<Uint8List> _convertToJpgIfNeeded(Uint8List bytes, String fileName) async {
    try {
      final isHeic = fileName.toLowerCase().endsWith('.heic') ||
          fileName.toLowerCase().endsWith('.heif') ||
          _isHeicFormat(bytes);

      if (!isHeic) {
        final decodedImage = img.decodeImage(bytes);
        if (decodedImage != null) {
          final jpgBytes = img.encodeJpg(decodedImage, quality: 85);
          return Uint8List.fromList(jpgBytes);
        }
        return bytes;
      }

      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        return bytes;
      }

      final jpgBytes = img.encodeJpg(decodedImage, quality: 85);
      return Uint8List.fromList(jpgBytes);
    } catch (e) {
      return bytes;
    }
  }

  /// Check if bytes represent a HEIC/HEIF image
  bool _isHeicFormat(Uint8List bytes) {
    if (bytes.length < 12) return false;
    try {
      final signature = String.fromCharCodes(bytes.sublist(4, 8));
      if (signature == 'ftyp') {
        final brand = String.fromCharCodes(bytes.sublist(8, 12));
        return brand == 'heic' || brand == 'mif1' || brand == 'msf1';
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  /// Clear selected image
  void clearImage() {
    _selectedImage = null;
    _extractedRecipes = [];
    _selectedRecipeIndices.clear();
    notifyListeners();
  }

  /// Process image with AI
  Future<void> processImage() async {
    if (_selectedImage == null) return;

    await execute(() async {
      final supabase = Supabase.instance.client;

      // Convert Uint8List to base64
      final imageBase64 = base64Encode(_selectedImage!);

      // Call the edge function
      final response = await supabase.functions.invoke(
        'extract-recipes',
        body: {
          'image_base64': imageBase64,
          'book_id': bookId,
        },
      );

      if (response.data == null) {
        throw Exception('No data returned from API');
      }

      final data = response.data as Map<String, dynamic>;
      final recipesData = data['recipes'] as List<dynamic>?;

      if (recipesData == null || recipesData.isEmpty) {
        throw Exception('No recipes found in the image');
      }

      // Convert to Recipe objects
      _extractedRecipes = recipesData.asMap().entries.map((entry) {
        final item = entry.value as Map<String, dynamic>;
        return Recipe(
          id: '${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
          bookId: bookId,
          title: item['title'] as String,
          page: item['page'] as int,
          tags: [],
        );
      }).toList();

      // Select all recipes by default
      _selectedRecipeIndices = Set.from(Iterable.generate(_extractedRecipes.length));
      notifyListeners();
    });
  }

  /// Toggle recipe selection
  void toggleRecipeSelection(int index) {
    if (_selectedRecipeIndices.contains(index)) {
      _selectedRecipeIndices.remove(index);
    } else {
      _selectedRecipeIndices.add(index);
    }
    notifyListeners();
  }

  /// Select all recipes
  void selectAllRecipes() {
    _selectedRecipeIndices = Set.from(Iterable.generate(_extractedRecipes.length));
    notifyListeners();
  }

  /// Deselect all recipes
  void deselectAllRecipes() {
    _selectedRecipeIndices.clear();
    notifyListeners();
  }

  /// Import selected recipes
  void importSelectedRecipes() {
    if (_selectedRecipeIndices.isEmpty) {
      throw Exception('Please select at least one recipe to import');
    }

    final selectedRecipes = _selectedRecipeIndices
        .map((index) => _extractedRecipes[index])
        .toList();

    onRecipesImported(selectedRecipes);
  }
}

