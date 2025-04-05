#pragma once

#include <string>
#include <mutex>
#include <windows.h>
#include <shlobj.h>

/**
 * @brief Класс для хранения и управления задачами (todos) на Windows
 */
class TodoStorage {
private:
    std::string storagePath;
    std::mutex storageMutex; // Для потокобезопасности
    
    // Приватные методы
    std::string readFromFile();
    bool writeToFile(const std::string& data);
    std::string getStoragePath();
    
    // Вспомогательные методы для работы с JSON
    std::string getJsonField(const std::string& json, const std::string& fieldName);
    
public:
    /**
     * @brief Конструктор
     * 
     * Инициализирует хранилище и создает файл, если он не существует
     */
    TodoStorage();
    
    /**
     * @brief Деструктор
     */
    ~TodoStorage();
    
    /**
     * @brief Получить все задачи
     * 
     * @return JSON строка со всеми задачами
     */
    std::string getAllTodos();
    
    /**
     * @brief Получить задачу по ID
     * 
     * @param id ID задачи
     * @return JSON строка с задачей или пустая строка, если задача не найдена
     */
    std::string getTodoById(const std::string& id);
    
    /**
     * @brief Добавить новую задачу
     * 
     * @param todoJson JSON строка с данными задачи
     * @return true если задача успешно добавлена, false в противном случае
     */
    bool addTodo(const std::string& todoJson);
    
    /**
     * @brief Обновить существующую задачу
     * 
     * @param todoJson JSON строка с данными задачи
     * @return true если задача успешно обновлена, false в противном случае
     */
    bool updateTodo(const std::string& todoJson);
    
    /**
     * @brief Удалить задачу по ID
     * 
     * @param id ID задачи
     * @return true если задача успешно удалена, false в противном случае
     */
    bool deleteTodo(const std::string& id);
};