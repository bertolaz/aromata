import 'package:aromata_frontend/ui/core/page_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:aromata_frontend/utils/result.dart';
import '../view_models/privacy_security_viewmodel.dart';

class PrivacySecurityScreen extends StatefulWidget {
  final PrivacySecurityViewModel viewModel;

  const PrivacySecurityScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.viewModel.changePassword.addListener(_onChangePasswordResult);
  }

  @override
  void didUpdateWidget(covariant PrivacySecurityScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.viewModel.changePassword.removeListener(_onChangePasswordResult);
    widget.viewModel.changePassword.addListener(_onChangePasswordResult);
  }

  @override
  void dispose() {
    widget.viewModel.changePassword.removeListener(_onChangePasswordResult);
    super.dispose();
  }

  void _onChangePasswordResult() {
    final result = widget.viewModel.changePassword.result;
    if (result == null) return;

    switch (result) {
      case Ok():
        widget.viewModel.changePassword.clearResult();
        widget.viewModel.reset();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case Error():
        widget.viewModel.changePassword.clearResult();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error changing password: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
        break;
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.viewModel.changePassword.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        final viewModel = widget.viewModel;
        return PageScaffold(
          title: 'Privacy & Security',
          hideProfileButton: true,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Change Password',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          onChanged: (value) => viewModel.setNewPassword(value),
                          initialValue: viewModel.newPassword,
                          obscureText: viewModel.obscureNewPassword,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            hintText: 'Enter new password',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                viewModel.obscureNewPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => viewModel.toggleNewPasswordVisibility(),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a new password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          onChanged: (value) => viewModel.setConfirmPassword(value),
                          initialValue: viewModel.confirmPassword,
                          obscureText: viewModel.obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            hintText: 'Confirm new password',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                viewModel.obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () => viewModel.toggleConfirmPasswordVisibility(),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your new password';
                            }
                            if (value != viewModel.newPassword) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: viewModel.isValid && !viewModel.changePassword.running
                              ? _submitForm
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: viewModel.changePassword.running
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  'Change Password',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ],
                    ),
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

