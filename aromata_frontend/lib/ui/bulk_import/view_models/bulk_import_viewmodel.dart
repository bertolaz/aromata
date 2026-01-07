import 'dart:convert';
import 'dart:typed_data';
import 'package:aromata_frontend/utils/command.dart';
import 'package:aromata_frontend/utils/result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image/image.dart' as img;
import '../../../domain/models/recipe.dart';
import '../../../viewmodels/base_viewmodel.dart';
import '../../../repositories/recipe_repository.dart';

class BulkImportViewModel extends BaseViewModel {
  final String bookId;
  final RecipeRepository _recipeRepository;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImage;
  List<Recipe> _extractedRecipes = [];
  Set<int> _selectedRecipeIndices = {};

  late final Command0<void> pickImageFromCamera;
  late final Command0<void> pickImageFromGallery;
  late final Command0<void> processImage;
  late final Command0<void> importSelectedRecipes;

  BulkImportViewModel({
    required this.bookId,
    required RecipeRepository recipeRepository,
  }) : _recipeRepository = recipeRepository {
    pickImageFromCamera = Command0<void>(_pickImageFromCamera);
    pickImageFromGallery = Command0<void>(_pickImageFromGallery);
    processImage = Command0<void>(_processImage);
    importSelectedRecipes = Command0<void>(_importSelectedRecipes);
  }

  Uint8List? get selectedImage => _selectedImage;
  List<Recipe> get extractedRecipes => _extractedRecipes;
  bool get hasExtractedRecipes => _extractedRecipes.isNotEmpty;
  Set<int> get selectedRecipeIndices => _selectedRecipeIndices;
  bool get hasSelectedRecipes => _selectedRecipeIndices.isNotEmpty;

  Future<Result<void>> _pickImageFromCamera() async {
    try {
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
        return Result.ok(null);
      }
      return Result.error(Exception('No image selected'));
    } catch (e) {
      return Result.error(Exception('Failed to pick image: $e'));
    }
  }

  Future<Result<void>> _pickImageFromGallery() async {
    try {
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
        return Result.ok(null);
      }
      return Result.error(Exception('No image selected'));
    } catch (e) {
      return Result.error(Exception('Failed to pick image: $e'));
    }
  }

  Future<Uint8List> _convertToJpgIfNeeded(Uint8List bytes, String fileName) async {
    try {
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

  void clearImage() {
    _selectedImage = null;
    _extractedRecipes = [];
    _selectedRecipeIndices.clear();
    notifyListeners();
  }

  Future<Result<void>> _processImage() async {
    if (_selectedImage == null) {
      return Result.error(Exception('No image selected'));
    }

    try {
      final supabase = Supabase.instance.client;
      final imageBase64 = base64Encode(_selectedImage!);

      final response = await supabase.functions.invoke(
        'extract-recipes',
        body: {
          'image_base64': imageBase64,
          'book_id': bookId,
        },
      );

      if (response.data == null) {
        return Result.error(Exception('No data returned from API'));
      }

      final data = response.data as Map<String, dynamic>;
      final recipesData = data['recipes'] as List<dynamic>?;

      if (recipesData == null || recipesData.isEmpty) {
        return Result.error(Exception('No recipes found in the image'));
      }

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

      _selectedRecipeIndices = Set.from(Iterable.generate(_extractedRecipes.length));
      notifyListeners();
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to process image: $e'));
    }
  }

  void toggleRecipeSelection(int index) {
    if (_selectedRecipeIndices.contains(index)) {
      _selectedRecipeIndices.remove(index);
    } else {
      _selectedRecipeIndices.add(index);
    }
    notifyListeners();
  }

  void selectAllRecipes() {
    _selectedRecipeIndices = Set.from(Iterable.generate(_extractedRecipes.length));
    notifyListeners();
  }

  void deselectAllRecipes() {
    _selectedRecipeIndices.clear();
    notifyListeners();
  }

  Future<Result<void>> _importSelectedRecipes() async {
    if (_selectedRecipeIndices.isEmpty) {
      return Result.error(Exception('Please select at least one recipe to import'));
    }

    try {
      final selectedRecipes = _selectedRecipeIndices
          .map((index) => _extractedRecipes[index])
          .toList();

      for (final recipe in selectedRecipes) {
        try {
          await _recipeRepository.createRecipe(
            recipe.bookId,
            recipe.title,
            recipe.page,
            recipe.tags,
          );
        } catch (e) {
          return Result.error(Exception('Failed to import recipe: ${recipe.title}'));
        }
      }

      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Failed to import recipes: $e'));
    }
  }
}

