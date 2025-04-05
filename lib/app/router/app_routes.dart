enum AppRoute {
  home,
  todoEdit,
}

extension AppRouteExtension on AppRoute {
  String get path {
    switch (this) {
      case AppRoute.home:
        return '/';
      case AppRoute.todoEdit:
        return '/todo-edit';
    }
  }

  String get name {
    switch (this) {
      case AppRoute.home:
        return 'Home';
      case AppRoute.todoEdit:
        return 'Todo Edit';
    }
  }
}
