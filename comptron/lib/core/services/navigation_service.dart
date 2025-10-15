import 'package:flutter/material.dart';

enum NavigationItem {
  events,
  announcements,
  projects,
  resources,
  admin,
  profile,
}

class NavigationService extends ChangeNotifier {
  NavigationItem _currentItem = NavigationItem.events;

  NavigationItem get currentItem => _currentItem;

  void navigateTo(NavigationItem item) {
    _currentItem = item;
    notifyListeners();
  }
}
