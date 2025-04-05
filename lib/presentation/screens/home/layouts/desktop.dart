import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/router/app_router.dart';
import '../../../../domain/models/todo.dart';
import '../widgets/stats_widget.dart';
import '../widgets/todo_list.dart';

class DesktopHomeScreen extends StatelessWidget {
  final bool isLoading;
  final List<Todo> todos;
  final void Function(Todo) toggleTodo;
  final void Function(String) deleteTodo;

  const DesktopHomeScreen({
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
              : Flex(
                direction: Axis.horizontal,
                children: [
                  Flexible(flex: 1, child: StatsWidget()),
                  Flexible(
                    flex: 2,
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
