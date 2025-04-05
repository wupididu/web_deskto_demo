package com.example.web_desktop_demo

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.web_desktop_demo/todo_storage"
    private lateinit var todoStorage: TodoStorage

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize TodoStorage
        todoStorage = TodoStorage(context)
        
        // Set up method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAllTodos" -> {
                    val jsonString = todoStorage.getAllTodos()
                    result.success(jsonString)
                }
                "getTodoById" -> {
                    val id = call.argument<String>("id")
                    if (id != null) {
                        val jsonString = todoStorage.getTodoById(id)
                        result.success(jsonString)
                    } else {
                        result.error("INVALID_ARGUMENT", "ID cannot be null", null)
                    }
                }
                "addTodo" -> {
                    val todoJson = call.argument<String>("todo")
                    if (todoJson != null) {
                        val success = todoStorage.addTodo(todoJson)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "Todo JSON cannot be null", null)
                    }
                }
                "updateTodo" -> {
                    val todoJson = call.argument<String>("todo")
                    if (todoJson != null) {
                        val success = todoStorage.updateTodo(todoJson)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "Todo JSON cannot be null", null)
                    }
                }
                "deleteTodo" -> {
                    val id = call.argument<String>("id")
                    if (id != null) {
                        val success = todoStorage.deleteTodo(id)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "ID cannot be null", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
