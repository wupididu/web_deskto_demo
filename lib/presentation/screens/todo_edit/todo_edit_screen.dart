import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/router/app_router.dart';
import '../../../domain/models/todo.dart';
import '../../../domain/repositories/todo_repository.dart';

class TodoEditScreen extends StatefulWidget {
  final Todo? todo;

  const TodoEditScreen({
    super.key,
    this.todo,
  });

  @override
  State<TodoEditScreen> createState() => _TodoEditScreenState();
}

class _TodoEditScreenState extends State<TodoEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  bool _isCompleted = false;

  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(text: widget.todo?.description ?? '');
    _isCompleted = widget.todo?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Todo' : 'Create Todo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            routerDelegate.navigateToHome();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              if (_isEditing)
                Row(
                  children: [
                    Checkbox(
                      value: _isCompleted,
                      onChanged: (value) {
                        setState(() {
                          _isCompleted = value ?? false;
                        });
                      },
                    ),
                    const Text('Completed'),
                  ],
                ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTodo,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: Text(_isEditing ? 'Update' : 'Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveTodo() async {
    if (_formKey.currentState?.validate() ?? false) {
      final todoRepository = Provider.of<TodoRepository>(context, listen: false);
      final routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);

      if (_isEditing) {
        // Update existing todo
        final updatedTodo = widget.todo!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          isCompleted: _isCompleted,
          completedAt: _isCompleted ? DateTime.now() : null,
        );
        await todoRepository.updateTodo(updatedTodo);
      } else {
        // Create new todo
        final newTodo = Todo(
          id: '',
          title: _titleController.text,
          description: _descriptionController.text,
          createdAt: DateTime.now(),
        );
        await todoRepository.addTodo(newTodo);
      }

      routerDelegate.navigateToHome();
    }
  }
}
