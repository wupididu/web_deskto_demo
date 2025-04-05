package com.example.web_desktop_demo

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

class TodoStorage(context: Context) {
    private val sharedPreferences: SharedPreferences = context.getSharedPreferences(
        "todo_preferences", Context.MODE_PRIVATE
    )
    private val todosKey = "todos"

    // Get all todos as a JSON string
    fun getAllTodos(): String {
        val todosJson = sharedPreferences.getString(todosKey, "[]") ?: "[]"
        return todosJson
    }

    // Get a specific todo by ID
    fun getTodoById(id: String): String? {
        try {
            val todosJson = sharedPreferences.getString(todosKey, "[]") ?: "[]"
            val todosArray = JSONArray(todosJson)

            for (i in 0 until todosArray.length()) {
                val todoObject = todosArray.getJSONObject(i)
                if (todoObject.getString("id") == id) {
                    return todoObject.toString()
                }
            }
            return null
        } catch (e: JSONException) {
            e.printStackTrace()
            return null
        }
    }

    // Add a new todo
    fun addTodo(todoJson: String): Boolean {
        try {
            val todoObject = JSONObject(todoJson)
            val todosJson = sharedPreferences.getString(todosKey, "[]") ?: "[]"
            val todosArray = JSONArray(todosJson)

            // Check if todo with same ID already exists
            for (i in 0 until todosArray.length()) {
                val existingTodo = todosArray.getJSONObject(i)
                if (existingTodo.getString("id") == todoObject.getString("id")) {
                    return false // Todo with this ID already exists
                }
            }

            // Add the new todo
            todosArray.put(todoObject)
            
            // Save the updated todos array
            sharedPreferences.edit().putString(todosKey, todosArray.toString()).apply()
            return true
        } catch (e: JSONException) {
            e.printStackTrace()
            return false
        }
    }

    // Update an existing todo
    fun updateTodo(todoJson: String): Boolean {
        try {
            val todoObject = JSONObject(todoJson)
            val todoId = todoObject.getString("id")
            val todosJson = sharedPreferences.getString(todosKey, "[]") ?: "[]"
            val todosArray = JSONArray(todosJson)
            val updatedTodosArray = JSONArray()
            var todoFound = false

            // Create a new array with the updated todo
            for (i in 0 until todosArray.length()) {
                val existingTodo = todosArray.getJSONObject(i)
                if (existingTodo.getString("id") == todoId) {
                    updatedTodosArray.put(todoObject)
                    todoFound = true
                } else {
                    updatedTodosArray.put(existingTodo)
                }
            }

            if (!todoFound) {
                return false // Todo not found
            }

            // Save the updated todos array
            sharedPreferences.edit().putString(todosKey, updatedTodosArray.toString()).apply()
            return true
        } catch (e: JSONException) {
            e.printStackTrace()
            return false
        }
    }

    // Delete a todo by ID
    fun deleteTodo(id: String): Boolean {
        try {
            val todosJson = sharedPreferences.getString(todosKey, "[]") ?: "[]"
            val todosArray = JSONArray(todosJson)
            val updatedTodosArray = JSONArray()
            var todoFound = false

            // Create a new array without the deleted todo
            for (i in 0 until todosArray.length()) {
                val existingTodo = todosArray.getJSONObject(i)
                if (existingTodo.getString("id") != id) {
                    updatedTodosArray.put(existingTodo)
                } else {
                    todoFound = true
                }
            }

            if (!todoFound) {
                return false // Todo not found
            }

            // Save the updated todos array
            sharedPreferences.edit().putString(todosKey, updatedTodosArray.toString()).apply()
            return true
        } catch (e: JSONException) {
            e.printStackTrace()
            return false
        }
    }
}