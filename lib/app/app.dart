import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repositories/todo_repository_impl.dart';
import '../data/services/todo_service.dart';
import '../domain/repositories/todo_repository.dart';
import 'router/app_router.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  late final AppRouterDelegate _routerDelegate;
  late final AppRouteInformationParser _routeInformationParser;
  late final TodoRepository _todoRepository;

  @override
  void initState() {
    super.initState();
    _routerDelegate = AppRouterDelegate();
    _routeInformationParser = AppRouteInformationParser();
    _todoRepository = TodoRepositoryImpl(service: TodoService());
  }

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: [
        PlatformMenu(
          label: 'Something',
          menus:
              PlatformProvidedMenuItemType.values
                  .map((a) => PlatformProvidedMenuItem(type: a))
                  .toList(),
        ),
        PlatformMenu(
          label: 'another',
          menus: [
            PlatformMenuItem(
              label: 'something',
              onSelected: () {
                print('tap on selected menu something');
              },
            ),
            PlatformMenuItemGroup(
              members: [
                PlatformMenuItem(
                  label: 'grouped something 1',
                  onSelected: () {
                    print('tap on selected menu grouped something 1');
                  },
                ),
                PlatformMenuItem(
                  label: 'grouped something 2',
                  onSelected: () {
                    print('tap on selected menu grouped something 2');
                  },
                ),
              ],
            ),
          ],
        ),
      ],
      child: Breakpoint(
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider<TodoRepository>.value(
              value: _todoRepository,
            ),
            ChangeNotifierProvider<AppRouterDelegate>.value(
              value: _routerDelegate,
            ),
          ],
          child: MaterialApp.router(
            title: 'Todo App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            routerDelegate: _routerDelegate,
            routeInformationParser: _routeInformationParser,
          ),
        ),
      ),
    );
  }
}
