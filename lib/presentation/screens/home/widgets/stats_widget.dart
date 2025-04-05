import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_desktop_demo/domain/repositories/todo_repository.dart';

import '../../../../domain/models/todo.dart';

class StatsWidget extends StatefulWidget {
  const StatsWidget({super.key});

  @override
  State<StatsWidget> createState() => _StatsWidgetState();
}

class _StatsWidgetState extends State<StatsWidget> {
  late final TodoRepository repository;
  List<Todo> _todos = [];

  @override
  void initState() {
    repository = context.read<TodoRepository>();
    _loadTodos();
    repository.addListener(_loadTodos);
    super.initState();
  }

  @override
  void dispose() {
    repository.removeListener(_loadTodos);
    super.dispose();
  }

  Future<void> _loadTodos() async {
    final todos = await repository.getAllTodos();

    if (!mounted) {
      return;
    }

    setState(() {
      _todos = todos;
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _todos.where((todo) => todo.isCompleted).length;
    final pendingCount = _todos.length - completedCount;
    final completionPercentage =
        _todos.isEmpty ? 0.0 : (completedCount / _todos.length) * 100;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Todo Statistics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              _buildStatItem(
                context,
                'Total',
                _todos.length.toString(),
                Icons.list,
                Colors.blue,
              ),
              _buildStatItem(
                context,
                'Pending',
                pendingCount.toString(),
                Icons.pending_actions,
                Colors.orange,
              ),
              _buildStatItem(
                context,
                'Completed',
                completedCount.toString(),
                Icons.task_alt,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          LinearProgressIndicator(
            value: completionPercentage / 100,
            backgroundColor: Colors.grey[300],
            color: Colors.green,
          ),
          const SizedBox(height: 4.0),
          Text(
            'Completion: ${completionPercentage.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: MouseRegion(
        onEnter: (event) {
          print('StatsWidget mouse enter to $label');
        },
        onExit: (event) {
          print('StatsWidget mouse exit from $label');
        },
        onHover: (event) {
          print('StatsWidget mouse hover on $label');
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4.0),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
