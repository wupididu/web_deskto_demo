import 'package:flutter/material.dart';

import '../../domain/models/todo.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/todo_edit/todo_edit_screen.dart';
import 'app_routes.dart';

class AppPages {
  static MaterialPage<dynamic> _createPage(Widget child, AppRoute route) {
    return MaterialPage(
      child: child,
      key: ValueKey(route.path),
      name: route.path,
      arguments: route,
    );
  }

  static MaterialPage<dynamic> home() {
    return _createPage(
      const HomeScreen(),
      AppRoute.home,
    );
  }

  static MaterialPage<dynamic> todoEdit({Todo? todo}) {
    return _createPage(
      TodoEditScreen(todo: todo),
      AppRoute.todoEdit,
    );
  }
}
