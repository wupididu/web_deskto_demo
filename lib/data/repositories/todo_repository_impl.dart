import 'dart:async';
import 'package:uuid/uuid.dart';

import '../../domain/models/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../services/todo_method_channel_service.dart';

class TodoRepositoryImpl extends TodoRepository {
  final TodoMethodChannelService _methodChannelService;
  final _uuid = const Uuid();

  // Constructor with optional parameter for dependency injection
  TodoRepositoryImpl({TodoMethodChannelService? methodChannelService})
    : _methodChannelService =
          methodChannelService ?? TodoMethodChannelService();

  @override
  Future<List<Todo>> getAllTodos() async {
    return await _methodChannelService.getAllTodos();
  }

  @override
  Future<Todo?> getTodoById(String id) async {
    return await _methodChannelService.getTodoById(id);
  }

  @override
  Future<void> addTodo(Todo todo) async {
    // Generate UUID if not provided
    final newTodo = todo.id.isEmpty ? todo.copyWith(id: _uuid.v4()) : todo;

    await _methodChannelService.addTodo(newTodo);
    notifyListeners();
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    await _methodChannelService.updateTodo(todo);
    notifyListeners();
  }

  @override
  Future<void> deleteTodo(String id) async {
    await _methodChannelService.deleteTodo(id);
    notifyListeners();
  }
}
