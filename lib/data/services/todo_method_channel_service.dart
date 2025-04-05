import 'dart:convert';
import 'package:flutter/services.dart';

import '../../domain/models/todo.dart';

class TodoMethodChannelService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.web_desktop_demo/todo_storage',
  );

  // Get all todos from the native platform
  Future<List<Todo>> getAllTodos() async {
    try {
      final String? jsonString = await _channel.invokeMethod<String>(
        'getAllTodos',
      );

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return Todo.fromJsonList(jsonList);
    } on PlatformException catch (e) {
      print('Error getting all todos: ${e.message}');
      return [];
    }
  }

  // Get a todo by id from the native platform
  Future<Todo?> getTodoById(String id) async {
    try {
      final String? jsonString = await _channel.invokeMethod<String>(
        'getTodoById',
        {'id': id},
      );

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final Map<String, dynamic> json = jsonDecode(jsonString);
      return Todo.fromJson(json);
    } on PlatformException catch (e) {
      print('Error getting todo by id: ${e.message}');
      return null;
    }
  }

  // Add a todo to the native platform
  Future<bool> addTodo(Todo todo) async {
    try {
      final Map<String, dynamic> todoJson = todo.toJson();
      final String jsonString = jsonEncode(todoJson);

      final bool? result = await _channel.invokeMethod<bool>('addTodo', {
        'todo': jsonString,
      });

      return result ?? false;
    } on PlatformException catch (e) {
      print('Error adding todo: ${e.message}');
      return false;
    }
  }

  // Update a todo on the native platform
  Future<bool> updateTodo(Todo todo) async {
    try {
      final Map<String, dynamic> todoJson = todo.toJson();
      final String jsonString = jsonEncode(todoJson);

      final bool? result = await _channel.invokeMethod<bool>('updateTodo', {
        'todo': jsonString,
      });

      return result ?? false;
    } on PlatformException catch (e) {
      print('Error updating todo: ${e.message}');
      return false;
    }
  }

  // Delete a todo from the native platform
  Future<bool> deleteTodo(String id) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('deleteTodo', {
        'id': id,
      });

      return result ?? false;
    } on PlatformException catch (e) {
      print('Error deleting todo: ${e.message}');
      return false;
    }
  }
}
