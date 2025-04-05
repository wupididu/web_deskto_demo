import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:web_desktop_demo/data/services/todo_service.dart';

import '../../domain/models/todo.dart';
import '../../domain/repositories/todo_repository.dart';

class TodoRepositoryImpl extends TodoRepository {
  final TodoService _service;
  final _uuid = const Uuid();

  // Constructor with optional parameter for dependency injection
  TodoRepositoryImpl({required TodoService service}) : _service = service;

  @override
  Future<List<Todo>> getAllTodos() async {
    return await _service.getAllTodos();
  }

  @override
  Future<Todo?> getTodoById(String id) async {
    return await _service.getTodoById(id);
  }

  @override
  Future<void> addTodo(Todo todo) async {
    // Generate UUID if not provided
    final newTodo = todo.id.isEmpty ? todo.copyWith(id: _uuid.v4()) : todo;

    await _service.addTodo(newTodo);
    notifyListeners();
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    await _service.updateTodo(todo);
    notifyListeners();
  }

  @override
  Future<void> deleteTodo(String id) async {
    await _service.deleteTodo(id);
    notifyListeners();
  }
}
