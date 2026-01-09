import 'package:aromata_frontend/ui/core/page_scaffold.dart';
import 'package:aromata_frontend/ui/bulk_import/view_models/bulk_import_viewmodel.dart';
import 'package:aromata_frontend/utils/result.dart';
import 'package:aromata_frontend/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BulkImportProcessingScreen extends StatefulWidget {
  final BulkImportViewModel viewModel;

  const BulkImportProcessingScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<BulkImportProcessingScreen> createState() =>
      _BulkImportProcessingScreenState();
}

class _BulkImportProcessingScreenState
    extends State<BulkImportProcessingScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.processImage.addListener(_onProcessImageResult);
  }

  @override
  void dispose() {
    widget.viewModel.processImage.removeListener(_onProcessImageResult);
    super.dispose();
  }

  void _onProcessImageResult() {
    final result = widget.viewModel.processImage.result;
    if (result == null) return;

    switch (result) {
      case Ok():
        widget.viewModel.processImage.clearResult();
        // Navigate to selection screen with extracted recipes
        context.pushNamed(
          RouteNames.bulkImportSelection,
          pathParameters: {'bookId': widget.viewModel.bookId},
          extra: {
            'recipes': widget.viewModel.extractedRecipes,
          },
        );
        break;
      case Error():
        widget.viewModel.processImage.clearResult();
        // Pop back to bulk import screen
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'Processing Image',
      hideProfileButton: true,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 3,
            ),
            const SizedBox(height: 32),
            Text(
              'AI is analyzing your image...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'This may take a few moments. Please wait while we extract recipe information.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
