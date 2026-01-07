import 'package:aromata_frontend/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PageScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final bool hideProfileButton;
  final Widget? floatingActionButton;
  const PageScaffold({super.key, required this.title, required this.child, this.hideProfileButton = false, this.floatingActionButton = null});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
          actions: _buildActions(context),
      ),
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (hideProfileButton) {
      return null;
    }
    return [IconButton(
      icon: const Icon(Icons.account_circle),
      tooltip: 'Profile',
      onPressed: () {
        context.pushNamed(RouteNames.profile);
      },
    )];
  }
}
