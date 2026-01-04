import 'package:aromata_frontend/routing/routes.dart';
import 'package:aromata_frontend/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../view_models/create_book_viewmodel.dart';

class CreateBookScreen extends StatefulWidget {
  final CreateBookViewModel viewModel;

  const CreateBookScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<CreateBookScreen> createState() => _CreateBookScreenState();
}

class _CreateBookScreenState extends State<CreateBookScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.viewModel.createBook.addListener(_onCreateBookResult);
  }

  @override
  void didUpdateWidget(covariant CreateBookScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.createBook.removeListener(_onCreateBookResult);
    widget.viewModel.createBook.addListener(_onCreateBookResult);
  }

  @override
  void dispose() {
    widget.viewModel.createBook.removeListener(_onCreateBookResult);
    super.dispose();
  }

  void _onCreateBookResult() {
    final result = widget.viewModel.createBook.result;
    if (result == null) return;

    switch (result) {
      case Ok():
        widget.viewModel.createBook.clearResult();
        final book = result.value;
        if (book != null) {
          context.pop();
          context.push('${Routes.home}/book/${book.id}', extra: book);
        }
        break;
      case Error():
        widget.viewModel.createBook.clearResult();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating book: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }

  void _saveBook() {
    if (_formKey.currentState!.validate()) {
      widget.viewModel.createBook.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateBookViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('New Recipe Book'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                    labelText: 'Title',
                    hintText: 'Enter book title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  onChanged: (value) => viewModel.setAuthor(value),
                  initialValue: viewModel.author,
                  decoration: const InputDecoration(
                    labelText: 'Author',
                    hintText: 'Enter author name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an author';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: viewModel.isValid && !viewModel.createBook.running
                      ? _saveBook
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: viewModel.createBook.running
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Create Book',
                          style: TextStyle(fontSize: 16),
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

