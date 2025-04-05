use wasm_bindgen::prelude::*;
use serde::{Serialize, Deserialize};
use js_sys::{Array, JSON, Object};
use web_sys::{window, Storage};
use std::collections::HashMap;

// Storage key for todos in localStorage
const STORAGE_KEY: &str = "web_desktop_demo_todos";

// Todo struct matching the Dart model
#[derive(Serialize, Deserialize, Clone)]
pub struct Todo {
    pub id: String,
    pub title: String,
    pub description: String,
    #[serde(rename = "isCompleted")]
    pub is_completed: bool,
    #[serde(rename = "createdAt")]
    pub created_at: String,
    #[serde(rename = "completedAt")]
    pub completed_at: Option<String>,
}

// Helper function to get localStorage
fn get_local_storage() -> Result<Storage, JsValue> {
    let window = window().ok_or_else(|| JsValue::from_str("No window found"))?;
    window.local_storage()?.ok_or_else(|| JsValue::from_str("No localStorage found"))
}

// Helper function to get todos from localStorage
fn get_todos() -> Result<Vec<Todo>, JsValue> {
    let storage = get_local_storage()?;
    let todos_json = storage.get_item(STORAGE_KEY)?.unwrap_or_else(|| "[]".to_string());
    
    let todos: Vec<Todo> = serde_json::from_str(&todos_json)
        .map_err(|e| JsValue::from_str(&format!("Failed to parse todos: {}", e)))?;
    
    Ok(todos)
}

// Helper function to save todos to localStorage
fn save_todos(todos: &[Todo]) -> Result<(), JsValue> {
    let storage = get_local_storage()?;
    let todos_json = serde_json::to_string(todos)
        .map_err(|e| JsValue::from_str(&format!("Failed to serialize todos: {}", e)))?;
    
    storage.set_item(STORAGE_KEY, &todos_json)?;
    Ok(())
}

// Log to console for debugging
#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = console)]
    fn log(s: &str);
}

// WASM-bindgen exported functions

#[wasm_bindgen]
pub fn add_todo(todo_json: &str) -> bool {
    match add_todo_internal(todo_json) {
        Ok(result) => result,
        Err(e) => {
            log(&format!("Error adding todo: {:?}", e));
            false
        }
    }
}

fn add_todo_internal(todo_json: &str) -> Result<bool, JsValue> {
    let todo: Todo = serde_json::from_str(todo_json)
        .map_err(|e| JsValue::from_str(&format!("Failed to parse todo: {}", e)))?;
    
    let mut todos = get_todos()?;
    todos.push(todo);
    save_todos(&todos)?;
    
    Ok(true)
}

#[wasm_bindgen]
pub fn get_todo_by_id(id: &str) -> Option<String> {
    match get_todo_by_id_internal(id) {
        Ok(result) => result,
        Err(e) => {
            log(&format!("Error getting todo by id: {:?}", e));
            None
        }
    }
}

fn get_todo_by_id_internal(id: &str) -> Result<Option<String>, JsValue> {
    let todos = get_todos()?;
    
    for todo in todos {
        if todo.id == id {
            let json = serde_json::to_string(&todo)
                .map_err(|e| JsValue::from_str(&format!("Failed to serialize todo: {}", e)))?;
            return Ok(Some(json));
        }
    }
    
    Ok(None)
}

#[wasm_bindgen]
pub fn get_all_todos() -> String {
    match get_all_todos_internal() {
        Ok(result) => result,
        Err(e) => {
            log(&format!("Error getting all todos: {:?}", e));
            "[]".to_string()
        }
    }
}

fn get_all_todos_internal() -> Result<String, JsValue> {
    let todos = get_todos()?;
    let json = serde_json::to_string(&todos)
        .map_err(|e| JsValue::from_str(&format!("Failed to serialize todos: {}", e)))?;
    
    Ok(json)
}

#[wasm_bindgen]
pub fn update_todo(todo_json: &str) -> bool {
    match update_todo_internal(todo_json) {
        Ok(result) => result,
        Err(e) => {
            log(&format!("Error updating todo: {:?}", e));
            false
        }
    }
}

fn update_todo_internal(todo_json: &str) -> Result<bool, JsValue> {
    let updated_todo: Todo = serde_json::from_str(todo_json)
        .map_err(|e| JsValue::from_str(&format!("Failed to parse todo: {}", e)))?;
    
    let mut todos = get_todos()?;
    let mut found = false;
    
    for todo in &mut todos {
        if todo.id == updated_todo.id {
            *todo = updated_todo.clone();
            found = true;
            break;
        }
    }
    
    if !found {
        return Ok(false);
    }
    
    save_todos(&todos)?;
    Ok(true)
}

#[wasm_bindgen]
pub fn delete_todo(id: &str) -> bool {
    match delete_todo_internal(id) {
        Ok(result) => result,
        Err(e) => {
            log(&format!("Error deleting todo: {:?}", e));
            false
        }
    }
}

fn delete_todo_internal(id: &str) -> Result<bool, JsValue> {
    let todos = get_todos()?;
    let initial_len = todos.len();
    
    let filtered_todos: Vec<Todo> = todos.into_iter()
        .filter(|todo| todo.id != id)
        .collect();
    
    if filtered_todos.len() == initial_len {
        return Ok(false);
    }
    
    save_todos(&filtered_todos)?;
    Ok(true)
}

// Initialize function that gets called when the WASM module is loaded
#[wasm_bindgen(start)]
pub fn start() {
    // Set panic hook for better error messages
    #[cfg(feature = "console_error_panic_hook")]
    console_error_panic_hook::set_once();
    
    log("Todo WASM module initialized");
}