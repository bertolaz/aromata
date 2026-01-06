import 'package:aromata_frontend/routing/routes.dart';
import 'package:flutter/material.dart';

class MainNavigationViewModel extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }

  void syncWithLocation(String location) {
    if (location.startsWith(Routes.books) || location.startsWith(Routes.recipes)) {
      _currentIndex = 0;
    } else if (location.startsWith(Routes.search)) {
      _currentIndex = 1;
    }
    else if (location.startsWith(Routes.profile)) {
      _currentIndex = 2;
    }
  }
}