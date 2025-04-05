import 'package:flutter/material.dart';

import '../../domain/models/todo.dart';
import 'app_pages.dart';
import 'app_routes.dart';

class AppRouterDelegate extends RouterDelegate<AppRoute>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoute> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  AppRoute _currentRoute = AppRoute.home;
  Todo? _selectedTodo;

  AppRoute get currentRoute => _currentRoute;
  Todo? get selectedTodo => _selectedTodo;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _getPages(),
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        // Handle back navigation
        if (_currentRoute == AppRoute.todoEdit) {
          _currentRoute = AppRoute.home;
          _selectedTodo = null;
          notifyListeners();
        }

        return true;
      },
    );
  }

  List<Page<dynamic>> _getPages() {
    final pages = <Page<dynamic>>[];

    // Always add home page
    pages.add(AppPages.home());

    // Add todo edit page if needed
    if (_currentRoute == AppRoute.todoEdit) {
      pages.add(AppPages.todoEdit(todo: _selectedTodo));
    }

    return pages;
  }

  void navigateToHome() {
    _currentRoute = AppRoute.home;
    _selectedTodo = null;
    notifyListeners();
  }

  void navigateToTodoEdit({Todo? todo}) {
    _currentRoute = AppRoute.todoEdit;
    _selectedTodo = todo;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(AppRoute configuration) async {
    _currentRoute = configuration;
    notifyListeners();
  }

  @override
  AppRoute get currentConfiguration => _currentRoute;
}

class AppRouteInformationParser extends RouteInformationParser<AppRoute> {
  @override
  Future<AppRoute> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.uri.toString());

    if (uri.pathSegments.isEmpty) {
      return AppRoute.home;
    }

    if (uri.pathSegments.first == 'todo-edit') {
      return AppRoute.todoEdit;
    }

    return AppRoute.home;
  }

  @override
  RouteInformation restoreRouteInformation(AppRoute configuration) {
    return RouteInformation(uri: Uri.parse(configuration.path));
  }
}
