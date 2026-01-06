import 'package:aromata_frontend/routing/routes.dart';
import 'package:aromata_frontend/ui/main_navigation/view_models/main_navigation_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigationScreen extends StatelessWidget {
  final Widget child;
  final MainNavigationViewModel viewModel;

  const MainNavigationScreen({
    super.key,
    required this.child,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    viewModel.syncWithLocation(
      GoRouterState.of(context).uri.toString(),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: viewModel.currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(Routes.books);
              break;
            case 1:
              context.go(Routes.search);
              break;
            case 2:
              context.go(Routes.profile);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        
      ),
    );
  }
}
