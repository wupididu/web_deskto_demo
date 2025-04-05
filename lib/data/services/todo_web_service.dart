@JS('todo_service')
library;

import 'dart:js_interop';

import 'package:flutter/foundation.dart';

import 'todo_service.dart';
import 'todo_wasm_service.dart';
import '../../domain/models/todo.dart';

/// Implementation of TodoService that uses localStorage for storage on web platforms.
class TodoServiceImpl implements TodoService {
  TodoServiceImpl._() {
    print('Use WEB TodoService');
  }

  factory TodoServiceImpl() {
    if (kIsWasm) {
      return TodoWasmService();
    }
    return TodoServiceImpl._();
  }

  final _service = JSTodoService();

  @override
  Future<bool> addTodo(Todo todo) async {
    final result = await _service.addTodo(todo.toJS).toDart;
    return result.toDart;
  }

  @override
  Future<bool> deleteTodo(String id) async {
    final result = await _service.deleteTodo(id).toDart;
    return result.toDart;
  }

  @override
  Future<List<Todo>> getAllTodos() async {
    final result = await _service.getAllTodos().toDart;
    return result.toDart.map((item) => item.toDart).toList();
  }

  @override
  Future<Todo?> getTodoById(String id) async {
    final item = await _service.getTodoById(id).toDart;
    return item?.toDart;
  }

  @override
  Future<bool> updateTodo(Todo todo) async {
    final result = await _service.updateTodo(todo.toJS).toDart;
    return result.toDart;
  }
}

@JS('TodoService')
extension type JSTodoService._(JSObject o) implements JSObject {
  external factory JSTodoService();

  external JSPromise<JSBoolean> addTodo(JSTodo todo);
  external JSPromise<JSBoolean> deleteTodo(String todo);
  external JSPromise<JSArray<JSTodo>> getAllTodos();
  external JSPromise<JSTodo?> getTodoById(String id);
  external JSPromise<JSBoolean> updateTodo(JSTodo todo);
}

@JS('Todo')
extension type JSTodo._(JSObject _) implements JSObject {
  external factory JSTodo({
    required String id,
    required String title,
    required String description,
    required bool isCompleted,
    required String createdAt,
    required String? completedAt,
  });
  external String get id;
  external String get title;
  external String get description;
  external bool get isCompleted;
  external String get createdAt;
  external String? get completedAt;

  Todo get toDart => Todo(
    id: id,
    title: title,
    description: description,
    createdAt: DateTime.parse(createdAt),
    isCompleted: isCompleted,
    completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
  );
}

extension on Todo {
  JSTodo get toJS => JSTodo(
    id: id,
    title: title,
    description: description,
    isCompleted: isCompleted,
    createdAt: createdAt.toIso8601String(),
    completedAt: completedAt?.toIso8601String(),
  );
}
