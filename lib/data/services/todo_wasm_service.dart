@JS('wasm_todo_service')
library;

import 'dart:convert';
import 'dart:js_interop';

import 'todo_web_service.dart';
import '../../domain/models/todo.dart';

/// Implementation of TodoService that uses WASM for storage on web platforms.
class TodoWasmService implements TodoServiceImpl {
  TodoWasmService() {
    print('Use WASM TodoService');
  }

  @override
  Future<bool> addTodo(Todo todo) async {
    final todoJson = jsonEncode(todo.toJson());
    final result = addTodoWasm(todoJson).toDart;
    return result;
  }

  @override
  Future<bool> deleteTodo(String id) async {
    final result = deleteTodoWasm(id).toDart;
    return result;
  }

  @override
  Future<List<Todo>> getAllTodos() async {
    // Try/catch specifically around the WASM call to pinpoint the exact failure point
    String jsonString;
    jsonString = getAllTodosWasm().toDart;

    if (jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);

    return Todo.fromJsonList(jsonList);
  }

  @override
  Future<Todo?> getTodoById(String id) async {
    final result = getTodoByIdWasm(id);

    if (result == null) {
      return null;
    }

    final jsonString = result.toDart;

    if (jsonString.isEmpty) {
      return null;
    }

    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Todo.fromJson(json);
  }

  @override
  Future<bool> updateTodo(Todo todo) async {
    final todoJson = jsonEncode(todo.toJson());
    final result = updateTodoWasm(todoJson).toDart;
    return result;
  }
}

// WASM FFI bindings

@JS('add_todo')
external JSBoolean addTodoWasm(String todoJson);

@JS('delete_todo')
external JSBoolean deleteTodoWasm(String id);

@JS('get_all_todos')
external JSString getAllTodosWasm();

@JS('get_todo_by_id')
external JSString? getTodoByIdWasm(String id);

@JS('update_todo')
external JSBoolean updateTodoWasm(String todoJson);
