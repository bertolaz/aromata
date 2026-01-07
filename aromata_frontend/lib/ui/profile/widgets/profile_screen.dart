import 'package:aromata_frontend/ui/core/page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aromata_frontend/utils/result.dart';
import '../view_models/profile_viewmodel.dart';

class ProfileScreen extends StatefulWidget {
  final ProfileViewModel viewModel;

  const ProfileScreen({super.key, required this.viewModel});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.signOut.addListener(_onSignOutResult);
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.signOut.removeListener(_onSignOutResult);
    widget.viewModel.signOut.addListener(_onSignOutResult);
  }

  @override
  void dispose() {
    widget.viewModel.signOut.removeListener(_onSignOutResult);
    super.dispose();
  }

  void _onSignOutResult() {
    final result = widget.viewModel.signOut.result;
    if (result == null) return;

    switch (result) {
      case Ok():
        widget.viewModel.signOut.clearResult();
        // Navigation will be handled by router redirect
        break;
      case Error():
        widget.viewModel.signOut.clearResult();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${result.error}'),
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
          title: 'Profile',
          hideProfileButton: true,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // User info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            child: Text(
                              viewModel.getUserName()[0].toUpperCase(),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  viewModel.getUserName(),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  viewModel.getUserEmail(),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Statistics
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: Icons.menu_book,
                            label: 'Books',
                            value: viewModel.bookCount.toString(),
                          ),
                          _StatItem(
                            icon: Icons.restaurant_menu,
                            label: 'Recipes',
                            value: viewModel.recipeCount.toString(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Privacy & Security'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.pushNamed('privacy');
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Sign Out'),
                      trailing: viewModel.signOut.running
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chevron_right),
                      onTap: viewModel.signOut.running
                          ? null
                          : () {
                              widget.viewModel.signOut.execute();
                              context.goNamed('login');
                            },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
