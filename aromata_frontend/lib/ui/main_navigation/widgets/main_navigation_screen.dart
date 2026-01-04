import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aromata_frontend/routing/routes.dart';
import 'package:aromata_frontend/utils/result.dart';
import '../view_models/main_navigation_viewmodel.dart';

class MainNavigationScreen extends StatefulWidget {
  final MainNavigationViewModel viewModel;
  final Widget? child;
  
  const MainNavigationScreen({
    super.key,
    required this.viewModel,
    this.child,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadData.addListener(_onLoadDataResult);
    // Load data on init
    widget.viewModel.loadData.execute();
  }

  @override
  void didUpdateWidget(covariant MainNavigationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.loadData.removeListener(_onLoadDataResult);
    widget.viewModel.loadData.addListener(_onLoadDataResult);
  }

  @override
  void dispose() {
    widget.viewModel.loadData.removeListener(_onLoadDataResult);
    super.dispose();
  }

  void _onLoadDataResult() {
    final result = widget.viewModel.loadData.result;
    if (result == null) return;

    switch (result) {
      case Ok():
        // Success, no action needed
        break;
      case Error():
        widget.viewModel.loadData.clearResult();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(Routes.books)) {
      return 0;
    } else if (location.startsWith(Routes.search)) {
      return 1;
    }
    return 0; // Default to books
  }

  void _onDestinationSelected(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(Routes.books);
        break;
      case 1:
        context.go(Routes.search);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainNavigationViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.loadData.running && viewModel.books.isEmpty) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }

        final currentIndex = _getCurrentIndex(context);

        return Scaffold(
          body: widget.child ?? const SizedBox.shrink(), // Child routes content
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => _onDestinationSelected(index, context),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book),
                label: 'Books',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search),
                label: 'Search',
              ),
            ],
          ),
        );
      },
    );
  }
}

