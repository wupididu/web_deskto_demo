import 'todo_method_channel_service.dart'
    if (dart.library.js_interop) 'todo_web_service.dart';

import '../../domain/models/todo.dart';

/// Интерфейс для работы с хранилищем задач
abstract class TodoService {
  /// Фабрика для создания экземпляра TodoService
  factory TodoService() => TodoServiceImpl();

  // Get all todos from the native platform
  Future<List<Todo>> getAllTodos();

  // Get a todo by id from the native platform
  Future<Todo?> getTodoById(String id);

  // Add a todo to the native platform
  Future<bool> addTodo(Todo todo);

  // Update a todo on the native platform
  Future<bool> updateTodo(Todo todo);

  // Delete a todo from the native platform
  Future<bool> deleteTodo(String id);
}