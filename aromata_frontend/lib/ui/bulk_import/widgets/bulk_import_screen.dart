import 'package:aromata_frontend/ui/core/page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:aromata_frontend/utils/result.dart';
import 'package:go_router/go_router.dart';
import 'package:aromata_frontend/routing/routes.dart';
import '../view_models/bulk_import_viewmodel.dart';

class BulkImportScreen extends StatefulWidget {
  final BulkImportViewModel viewModel;

  const BulkImportScreen({super.key, required this.viewModel});

  @override
  State<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends State<BulkImportScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.pickImageFromCamera.addListener(_onCommandResult);
    widget.viewModel.pickImageFromGallery.addListener(_onCommandResult);
    widget.viewModel.processImage.addListener(_onProcessImageResult);
    widget.viewModel.importSelectedRecipes.addListener(_onImportResult);
  }

  @override
  void didUpdateWidget(covariant BulkImportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.pickImageFromCamera.removeListener(_onCommandResult);
    oldWidget.viewModel.pickImageFromGallery.removeListener(_onCommandResult);
    oldWidget.viewModel.processImage.removeListener(_onProcessImageResult);
    oldWidget.viewModel.importSelectedRecipes.removeListener(_onImportResult);
    widget.viewModel.pickImageFromCamera.addListener(_onCommandResult);
    widget.viewModel.pickImageFromGallery.addListener(_onCommandResult);
    widget.viewModel.processImage.addListener(_onProcessImageResult);
    widget.viewModel.importSelectedRecipes.addListener(_onImportResult);
  }

  @override
  void dispose() {
    widget.viewModel.pickImageFromCamera.removeListener(_onCommandResult);
    widget.viewModel.pickImageFromGallery.removeListener(_onCommandResult);
    widget.viewModel.processImage.removeListener(_onProcessImageResult);
    widget.viewModel.importSelectedRecipes.removeListener(_onImportResult);
    super.dispose();
  }

  void _onCommandResult() {
    // Handle image pick results if needed
  }

  void _onProcessImageResult() {
    // This is now handled by the processing screen
    // We keep this listener for error handling if user navigates back
    final result = widget.viewModel.processImage.result;
    if (result == null) return;

    switch (result) {
      case Ok():
        widget.viewModel.processImage.clearResult();
        break;
      case Error():
        widget.viewModel.processImage.clearResult();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }

  void _onImportResult() {
    final result = widget.viewModel.importSelectedRecipes.result;
    if (result == null) return;

    switch (result) {
      case Ok():
        widget.viewModel.importSelectedRecipes.clearResult();
        Navigator.of(context).pop();
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
          title: 'Bulk Import Recipes',
          hideProfileButton: true,
          child: SingleChildScrollView(
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
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1. Take a photo or select an image of recipe pages\n'
                          '2. AI will extract recipe information\n'
                          '3. Review and select recipes to import',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Image selection
                if (viewModel.selectedImage == null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: viewModel.pickImageFromCamera.running
                              ? null
                              : () => viewModel.pickImageFromCamera.execute(),
                          icon: viewModel.pickImageFromCamera.running
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.camera_alt),
                          label: const Text('Take Photo'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: viewModel.pickImageFromGallery.running
                              ? null
                              : () => viewModel.pickImageFromGallery.execute(),
                          icon: viewModel.pickImageFromGallery.running
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.photo_library),
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
                        Image.memory(
                          viewModel.selectedImage!,
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
                            onPressed: () => viewModel.clearImage(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Process button
                  ElevatedButton.icon(
                    onPressed: viewModel.processImage.running
                        ? null
                        : () {
                            // Navigate to processing screen with viewModel
                            context.pushNamed(
                              RouteNames.bulkImportProcessing,
                              pathParameters: {'bookId': viewModel.bookId},
                              extra: {'viewModel': viewModel},
                            );
                            // Then start processing
                            viewModel.processImage.execute();
                          },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Process with AI'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],

                
              ],
            ),
          ),
        );
      },
    );
  }
}
