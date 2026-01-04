import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';
import '../repositories/auth_repository.dart';
import 'privacy_security_screen.dart';

class ProfileScreen extends StatelessWidget {
  final int bookCount;
  final int recipeCount;

  const ProfileScreen({
    super.key,
    this.bookCount = 0,
    this.recipeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileViewModel(
        bookCount: bookCount,
        recipeCount: recipeCount,
        authRepository: Provider.of<IAuthRepository>(context, listen: false),
      ),
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop(); // Close dialog
                          final success = await viewModel.signOut();
                          if (!success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(viewModel.errorMessage ?? 'Error signing out'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else if (context.mounted) {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.getUserName(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      viewModel.getUserEmail(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistics
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.menu_book,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Recipe Books'),
                    trailing: Text(
                      bookCount.toString(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.restaurant_menu,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Total Recipes'),
                    trailing: Text(
                      recipeCount.toString(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings section
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to edit profile screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit profile coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to notifications settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications settings coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.palette_outlined),
                    title: const Text('Appearance'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to appearance settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Appearance settings coming soon')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Privacy & Security'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacySecurityScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // About section
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'About',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About Aromata'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Aromata',
                        applicationVersion: '1.0.0',
                        applicationIcon: const Icon(
                          Icons.restaurant_menu,
                          size: 48,
                        ),
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text(
                              'Your personal recipe book organizer. '
                              'Keep track of your favorite recipes from all your cookbooks.',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to help screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help & Support coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign out button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Sign Out'),
                        content: const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop(); // Close dialog
                              final success = await viewModel.signOut();
                              if (!success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(viewModel.errorMessage ?? 'Error signing out'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else if (context.mounted) {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                            ),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
        },
      ),
    );
  }
}

