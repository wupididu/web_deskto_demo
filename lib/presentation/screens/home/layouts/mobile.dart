import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/app_router.dart';
import '../../../../domain/models/todo.dart';
import '../widgets/stats_widget.dart';
import '../widgets/todo_list.dart';

class MobileHomeScreen extends StatelessWidget {
  final bool isLoading;
  final List<Todo> todos;
  final void Function(Todo) toggleTodo;
  final void Function(String) deleteTodo;

  const MobileHomeScreen({
    super.key,
    required this.isLoading,
    required this.todos,
    required this.toggleTodo,
    required this.deleteTodo,
  });

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
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  StatsWidget(),
                  Expanded(
                    child: TodoList(
                      todos: todos,
                      onTodoTap: (todo) {
                        routerDelegate.navigateToTodoEdit(todo: todo);
                      },
                      onTodoToggle: toggleTodo,
                      onTodoDelete: deleteTodo,
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
}
