import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/create_book_viewmodel.dart';

class CreateBookScreen extends StatefulWidget {
  const CreateBookScreen({super.key});

  @override
  State<CreateBookScreen> createState() => _CreateBookScreenState();
}

class _CreateBookScreenState extends State<CreateBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late CreateBookViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CreateBookViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _saveBook() {
    if (_formKey.currentState!.validate()) {
      final book = _viewModel.createBook();
      if (book != null) {
        Navigator.pop(context, book);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<CreateBookViewModel>(
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
                    onPressed: viewModel.isValid ? _saveBook : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Create Book',
                      style: TextStyle(fontSize: 16),
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

