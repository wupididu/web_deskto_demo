import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:web_desktop_demo/presentation/keyboard_shortcuts.dart';
import 'package:web_desktop_demo/presentation/screens/home/layouts/desktop.dart';
import '../../../domain/models/todo.dart';
import '../../../domain/repositories/todo_repository.dart';
import 'layouts/mobile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final TodoRepository todoRepository;

  List<Todo> _todos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    todoRepository = Provider.of<TodoRepository>(context, listen: false);
    _loadTodos();
    todoRepository.addListener(_loadTodos);
  }

  @override
  void dispose() {
    todoRepository.removeListener(_loadTodos);
    super.dispose();
  }

  Future<void> _loadTodos() async {
    setState(() {
      _isLoading = true;
    });

    final todos = await todoRepository.getAllTodos();

    setState(() {
      _todos = todos;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) => KeyboardShortcutsHandler(
    child: AdaptiveBuilder(
      defaultBuilder:
          (context, screen) => switch (screen.screenType) {
            ScreenType.smallHandset ||
            ScreenType.mediumHandset ||
            ScreenType.largeHandset => MobileHomeScreen(
              isLoading: _isLoading,
              todos: _todos,
              toggleTodo: _handleTodoToggle,
              deleteTodo: _handleTodoDelete,
            ),
            ScreenType.smallTablet ||
            ScreenType.largeTablet ||
            ScreenType.smallDesktop ||
            ScreenType.mediumDesktop ||
            ScreenType.largeDesktop => DesktopHomeScreen(
              isLoading: _isLoading,
              todos: _todos,
              toggleTodo: _handleTodoToggle,
              deleteTodo: _handleTodoDelete,
            ),
          },
    ),
  );

  Future<void> _handleTodoToggle(Todo todo) async {
    final updatedTodo =
        todo.isCompleted ? todo.markAsIncomplete() : todo.markAsCompleted();

    await todoRepository.updateTodo(updatedTodo);
  }

  Future<void> _handleTodoDelete(String id) async {
    await todoRepository.deleteTodo(id);
  }
}
