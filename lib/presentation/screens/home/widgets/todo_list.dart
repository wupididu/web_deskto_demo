import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:web_desktop_demo/app/router/app_router.dart';

import '../../../../domain/models/todo.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final Function(Todo) onTodoTap;
  final Function(Todo) onTodoToggle;
  final Function(String) onTodoDelete;

  const TodoList({
    super.key,
    required this.todos,
    required this.onTodoTap,
    required this.onTodoToggle,
    required this.onTodoDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No todos yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap the + button to add a new todo',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Dismissible(
          key: Key(todo.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onTodoDelete(todo.id),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: ListTile(
              leading: Checkbox(
                value: todo.isCompleted,
                onChanged: (_) => onTodoToggle(todo),
              ),
              focusNode: FocusNode(
                onKeyEvent: (node, event) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                    context.read<AppRouterDelegate>().navigateToTodoEdit(
                      todo: todo,
                    );
                    return KeyEventResult.handled;
                  }

                  if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    node.nextFocus();
                    return KeyEventResult.handled;
                  }

                  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    node.previousFocus();
                    return KeyEventResult.handled;
                  }

                  if (event.logicalKey == LogicalKeyboardKey.backspace) {
                    onTodoDelete(todo.id);
                    return KeyEventResult.handled;
                  }

                  return KeyEventResult.ignored;
                },
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration:
                      todo.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                  color: todo.isCompleted ? Colors.grey : null,
                ),
              ),
              subtitle: Text(
                todo.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: todo.isCompleted ? Colors.grey : null),
              ),
              trailing: Text(
                _formatDate(todo.createdAt),
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () => onTodoTap(todo),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
