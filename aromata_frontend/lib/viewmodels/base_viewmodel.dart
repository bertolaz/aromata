import 'package:flutter/foundation.dart';

/// Base ViewModel class that provides common functionality
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Set loading state
  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  /// Set error message
  void setError(String? error) {
    if (_errorMessage != error) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  /// Clear error
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Execute an async operation with loading and error handling
  Future<T?> execute<T>(Future<T> Function() operation) async {
    try {
      setLoading(true);
      clearError();
      final result = await operation();
      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

