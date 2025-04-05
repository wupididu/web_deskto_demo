import 'package:flutter/material.dart';

import '../models/todo.dart';

abstract class TodoRepository with ChangeNotifier {
  /// Get all todos
  Future<List<Todo>> getAllTodos();

  /// Get a todo by id
  Future<Todo?> getTodoById(String id);

  /// Add a new todo
  Future<void> addTodo(Todo todo);

  /// Update an existing todo
  Future<void> updateTodo(Todo todo);

  /// Delete a todo by id
  Future<void> deleteTodo(String id);
}
