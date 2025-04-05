import 'package:flutter/material.dart';
import 'package:flutter_adaptive_ui/flutter_adaptive_ui.dart';
import 'package:provider/provider.dart';
import 'package:web_desktop_demo/presentation/keyboard_shortcuts.dart';
import 'package:web_desktop_demo/presentation/screens/todo_edit/layouts/mobile.dart';

import '../../../app/router/app_router.dart';
import '../../../domain/models/todo.dart';
import '../../../domain/repositories/todo_repository.dart';
import 'layouts/desktop.dart';

class TodoEditScreen extends StatefulWidget {
  final Todo? todo;

  const TodoEditScreen({super.key, this.todo});

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
    _descriptionController = TextEditingController(
      text: widget.todo?.description ?? '',
    );
    _isCompleted = widget.todo?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeyboardShortcutsHandler(
    onSave: _saveTodo,
    onToggleTodo: () => _toggle(null),
    child: FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: AdaptiveBuilder(
        defaultBuilder:
            (context, screen) => switch (screen.screenType) {
              ScreenType.smallHandset ||
              ScreenType.mediumHandset ||
              ScreenType.largeHandset => MobileTodoEditScreen(
                isNew: !_isEditing,
                isCompleted: _isCompleted,
                toggle: _toggle,
                onSave: _saveTodo,
                formKey: _formKey,
                titleController: _titleController,
                descriptionController: _descriptionController,
              ),
              ScreenType.smallTablet ||
              ScreenType.largeTablet ||
              ScreenType.smallDesktop ||
              ScreenType.mediumDesktop ||
              ScreenType.largeDesktop => DesktopTodoEditScreen(
                isNew: !_isEditing,
                isCompleted: _isCompleted,
                toggle: _toggle,
                onSave: _saveTodo,
                formKey: _formKey,
                titleController: _titleController,
                descriptionController: _descriptionController,
              ),
            },
      ),
    ),
  );

  void _toggle(bool? value) {
    setState(() {
      _isCompleted = value ?? !_isCompleted;
    });
  }

  Future<void> _saveTodo() async {
    if (_formKey.currentState?.validate() ?? false) {
      final todoRepository = Provider.of<TodoRepository>(
        context,
        listen: false,
      );
      final routerDelegate = Provider.of<AppRouterDelegate>(
        context,
        listen: false,
      );

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
