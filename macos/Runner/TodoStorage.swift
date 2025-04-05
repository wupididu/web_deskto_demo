import Foundation

/// Класс для хранения и управления задачами (todos) на macOS
class TodoStorage {
    private let userDefaults = UserDefaults.standard
    private let todosKey = "todos"
    
    /// Получить все задачи в виде JSON строки
    func getAllTodos() -> String {
        return userDefaults.string(forKey: todosKey) ?? "[]"
    }
    
    /// Получить задачу по ID
    /// - Parameter id: ID задачи
    /// - Returns: JSON строка с задачей или nil, если задача не найдена
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
    
    /// Добавить новую задачу
    /// - Parameter todoJson: JSON строка с данными задачи
    /// - Returns: true если задача успешно добавлена, false в противном случае
    func addTodo(todoJson: String) -> Bool {
        do {
            guard let todoData = todoJson.data(using: .utf8),
                  let todoDict = try JSONSerialization.jsonObject(with: todoData) as? [String: Any],
                  let todoId = todoDict["id"] as? String else {
                return false
            }
            
            var todosArray: [[String: Any]] = []
            
            // Получаем существующие задачи
            if let todosJson = userDefaults.string(forKey: todosKey),
               let todosData = todosJson.data(using: .utf8),
               let existingTodos = try JSONSerialization.jsonObject(with: todosData) as? [[String: Any]] {
                todosArray = existingTodos
                
                // Проверяем, что задача с таким ID не существует
                for todo in todosArray {
                    if let id = todo["id"] as? String, id == todoId {
                        return false // Задача с таким ID уже существует
                    }
                }
            }
            
            // Добавляем новую задачу
            todosArray.append(todoDict)
            
            // Сохраняем обновленный массив задач
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
    
    /// Обновить существующую задачу
    /// - Parameter todoJson: JSON строка с данными задачи
    /// - Returns: true если задача успешно обновлена, false в противном случае
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
            
            // Создаем новый массив с обновленной задачей
            for todo in todosArray {
                if let id = todo["id"] as? String, id == todoId {
                    updatedTodosArray.append(todoDict)
                    todoFound = true
                } else {
                    updatedTodosArray.append(todo)
                }
            }
            
            if !todoFound {
                return false // Задача не найдена
            }
            
            // Сохраняем обновленный массив задач
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
    
    /// Удалить задачу по ID
    /// - Parameter id: ID задачи
    /// - Returns: true если задача успешно удалена, false в противном случае
    func deleteTodo(id: String) -> Bool {
        do {
            guard let todosJson = userDefaults.string(forKey: todosKey),
                  let todosData = todosJson.data(using: .utf8),
                  let todosArray = try JSONSerialization.jsonObject(with: todosData) as? [[String: Any]] else {
                return false
            }
            
            var todoFound = false
            var updatedTodosArray: [[String: Any]] = []
            
            // Создаем новый массив без удаленной задачи
            for todo in todosArray {
                if let todoId = todo["id"] as? String, todoId != id {
                    updatedTodosArray.append(todo)
                } else {
                    todoFound = true
                }
            }
            
            if !todoFound {
                return false // Задача не найдена
            }
            
            // Сохраняем обновленный массив задач
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