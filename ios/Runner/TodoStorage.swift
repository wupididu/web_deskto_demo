import Foundation

class TodoStorage {
    private let userDefaults = UserDefaults.standard
    private let todosKey = "todos"
    
    // Get all todos as a JSON string
    func getAllTodos() -> String {
        return userDefaults.string(forKey: todosKey) ?? "[]"
    }
    
    // Get a specific todo by ID
    func getTodoById(id: String) -> String? {
        guard let todosJson = userDefaults.string(forKey: todosKey) else {
            return nil
        }
        
        do {
            guard let todosData = todosJson.data(using: .utf8),
                  let todosArray = try JSONSerialization.jsonObject(with: todosData) as? [[String: Any]] else {
                return nil
            }
            
            for todo in todosArray {
                if let todoId = todo["id"] as? String, todoId == id {
                    let todoData = try JSONSerialization.data(withJSONObject: todo)
                    return String(data: todoData, encoding: .utf8)
                }
            }
            
            return nil
        } catch {
            print("Error getting todo by id: \(error)")
            return nil
        }
    }
    
    // Add a new todo
    func addTodo(todoJson: String) -> Bool {
        do {
            guard let todoData = todoJson.data(using: .utf8),
                  let todoDict = try JSONSerialization.jsonObject(with: todoData) as? [String: Any],
                  let todoId = todoDict["id"] as? String else {
                return false
            }
            
            var todosArray: [[String: Any]] = []
            
            // Get existing todos
            if let todosJson = userDefaults.string(forKey: todosKey),
               let todosData = todosJson.data(using: .utf8),
               let existingTodos = try JSONSerialization.jsonObject(with: todosData) as? [[String: Any]] {
                todosArray = existingTodos
                
                // Check if todo with same ID already exists
                for todo in todosArray {
                    if let id = todo["id"] as? String, id == todoId {
                        return false // Todo with this ID already exists
                    }
                }
            }
            
            // Add the new todo
            todosArray.append(todoDict)
            
            // Save the updated todos array
            let updatedTodosData = try JSONSerialization.data(withJSONObject: todosArray)
            if let updatedTodosJson = String(data: updatedTodosData, encoding: .utf8) {
                userDefaults.set(updatedTodosJson, forKey: todosKey)
                return true
            }
            
            return false
        } catch {
            print("Error adding todo: \(error)")
            return false
        }
    }
    
    // Update an existing todo
    func updateTodo(todoJson: String) -> Bool {
        do {
            guard let todoData = todoJson.data(using: .utf8),
                  let todoDict = try JSONSerialization.jsonObject(with: todoData) as? [String: Any],
                  let todoId = todoDict["id"] as? String else {
                return false
            }
            
            guard let todosJson = userDefaults.string(forKey: todosKey),
                  let todosData = todosJson.data(using: .utf8),
                  var todosArray = try JSONSerialization.jsonObject(with: todosData) as? [[String: Any]] else {
                return false
            }
            
            var todoFound = false
            var updatedTodosArray: [[String: Any]] = []
            
            // Create a new array with the updated todo
            for todo in todosArray {
                if let id = todo["id"] as? String, id == todoId {
                    updatedTodosArray.append(todoDict)
                    todoFound = true
                } else {
                    updatedTodosArray.append(todo)
                }
            }
            
            if !todoFound {
                return false // Todo not found
            }
            
            // Save the updated todos array
            let updatedTodosData = try JSONSerialization.data(withJSONObject: updatedTodosArray)
            if let updatedTodosJson = String(data: updatedTodosData, encoding: .utf8) {
                userDefaults.set(updatedTodosJson, forKey: todosKey)
                return true
            }
            
            return false
        } catch {
            print("Error updating todo: \(error)")
            return false
        }
    }
    
    // Delete a todo by ID
    func deleteTodo(id: String) -> Bool {
        do {
            guard let todosJson = userDefaults.string(forKey: todosKey),
                  let todosData = todosJson.data(using: .utf8),
                  let todosArray = try JSONSerialization.jsonObject(with: todosData) as? [[String: Any]] else {
                return false
            }
            
            var todoFound = false
            var updatedTodosArray: [[String: Any]] = []
            
            // Create a new array without the deleted todo
            for todo in todosArray {
                if let todoId = todo["id"] as? String, todoId != id {
                    updatedTodosArray.append(todo)
                } else {
                    todoFound = true
                }
            }
            
            if !todoFound {
                return false // Todo not found
            }
            
            // Save the updated todos array
            let updatedTodosData = try JSONSerialization.data(withJSONObject: updatedTodosArray)
            if let updatedTodosJson = String(data: updatedTodosData, encoding: .utf8) {
                userDefaults.set(updatedTodosJson, forKey: todosKey)
                return true
            }
            
            return false
        } catch {
            print("Error deleting todo: \(error)")
            return false
        }
    }
}