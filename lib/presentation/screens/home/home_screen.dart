import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_router.dart';
import '../../../domain/models/todo.dart';
import '../../../domain/repositories/todo_repository.dart';
import 'widgets/stats_widget.dart';
import 'widgets/todo_list.dart';

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
  Widget build(BuildContext context) {
    final routerDelegate = Provider.of<AppRouterDelegate>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  StatsWidget(todos: _todos),
                  Expanded(
                    child: TodoList(
                      todos: _todos,
                      onTodoTap: (todo) {
                        routerDelegate.navigateToTodoEdit(todo: todo);
                      },
                      onTodoToggle: _handleTodoToggle,
                      onTodoDelete: _handleTodoDelete,
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          routerDelegate.navigateToTodoEdit();
        },
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleTodoToggle(Todo todo) async {
    final updatedTodo =
        todo.isCompleted ? todo.markAsIncomplete() : todo.markAsCompleted();

    await todoRepository.updateTodo(updatedTodo);
    _loadTodos();
  }

  Future<void> _handleTodoDelete(String id) async {
    await todoRepository.deleteTodo(id);
    _loadTodos();
  }
}
