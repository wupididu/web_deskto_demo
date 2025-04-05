import 'package:flutter/material.dart';

import '../../../../domain/models/todo.dart';

class StatsWidget extends StatelessWidget {
  final List<Todo> todos;

  const StatsWidget({
    super.key,
    required this.todos,
  });

  @override
  Widget build(BuildContext context) {
    final completedCount = todos.where((todo) => todo.isCompleted).length;
    final pendingCount = todos.length - completedCount;
    final completionPercentage = todos.isEmpty
        ? 0.0
        : (completedCount / todos.length) * 100;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.surfaceVariant,
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
                todos.length.toString(),
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
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 4.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
