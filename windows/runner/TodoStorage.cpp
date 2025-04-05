#include "TodoStorage.h"
#include <fstream>
#include <iostream>
#include <sstream>
#include <direct.h>

// Вспомогательная функция для создания директории
bool createDirectory(const std::string& path) {
    return _mkdir(path.c_str()) == 0;
}

// Вспомогательная функция для проверки существования директории
bool directoryExists(const std::string& path) {
    DWORD fileAttributes = GetFileAttributesA(path.c_str());
    return (fileAttributes != INVALID_FILE_ATTRIBUTES && 
            (fileAttributes & FILE_ATTRIBUTE_DIRECTORY));
}

// Вспомогательная функция для проверки существования файла
bool fileExists(const std::string& path) {
    DWORD fileAttributes = GetFileAttributesA(path.c_str());
    return (fileAttributes != INVALID_FILE_ATTRIBUTES && 
            !(fileAttributes & FILE_ATTRIBUTE_DIRECTORY));
}

// Получение пути к хранилищу
std::string TodoStorage::getStoragePath() {
    std::string appName = "web_desktop_demo";
    std::string fileName = "todos.json";
    std::string basePath;
    
    // Windows: %APPDATA%\[AppName]\todos.json
    char appDataPath[MAX_PATH];
    if (SUCCEEDED(SHGetFolderPathA(NULL, CSIDL_APPDATA, NULL, 0, appDataPath))) {
        basePath = std::string(appDataPath) + "\\" + appName;
        
        // Создаем директорию, если она не существует
        if (!directoryExists(basePath)) {
            createDirectory(basePath);
        }
        
        return basePath + "\\" + fileName;
    }
    
    // Если не удалось получить путь к %APPDATA%, используем текущую директорию
    return fileName;
}

// Конструктор
TodoStorage::TodoStorage() {
    try {
        storagePath = getStoragePath();
        
        // Создаем пустой файл, если он не существует
        if (!fileExists(storagePath)) {
            std::ofstream file(storagePath);
            file << "[]";
            file.close();
        }
    } catch (const std::exception& e) {
        std::cerr << "Error initializing TodoStorage: " << e.what() << std::endl;
        // Используем текущую директорию как запасной вариант
        storagePath = "todos.json";
        std::ofstream file(storagePath);
        file << "[]";
        file.close();
    }
}

// Деструктор
TodoStorage::~TodoStorage() {
    // Ничего не делаем
}

// Чтение данных из файла
std::string TodoStorage::readFromFile() {
    std::lock_guard<std::mutex> lock(storageMutex);
    
    std::ifstream file(storagePath);
    if (!file.is_open()) {
        return "[]";
    }
    
    std::stringstream buffer;
    buffer << file.rdbuf();
    std::string content = buffer.str();
    
    // Если файл пустой, возвращаем пустой массив JSON
    if (content.empty()) {
        return "[]";
    }
    
    return content;
}

// Запись данных в файл
bool TodoStorage::writeToFile(const std::string& data) {
    std::lock_guard<std::mutex> lock(storageMutex);
    
    std::ofstream file(storagePath);
    if (!file.is_open()) {
        return false;
    }
    
    file << data;
    return file.good();
}

// Вспомогательная функция для извлечения значения поля из JSON объекта
std::string TodoStorage::getJsonField(const std::string& json, const std::string& fieldName) {
    std::string search = "\"" + fieldName + "\":";
    size_t pos = json.find(search);
    
    if (pos == std::string::npos) {
        return "";
    }
    
    pos += search.length();
    
    // Пропускаем пробелы
    while (pos < json.length() && (json[pos] == ' ' || json[pos] == '\t' || json[pos] == '\n' || json[pos] == '\r')) {
        pos++;
    }
    
    if (pos >= json.length()) {
        return "";
    }
    
    // Если значение - строка
    if (json[pos] == '"') {
        size_t endPos = json.find('"', pos + 1);
        while (endPos != std::string::npos && json[endPos - 1] == '\\') {
            endPos = json.find('"', endPos + 1);
        }
        
        if (endPos == std::string::npos) {
            return "";
        }
        
        return json.substr(pos + 1, endPos - pos - 1);
    }
    
    // Если значение - число, булево или null
    size_t endPos = json.find_first_of(",}]", pos);
    if (endPos == std::string::npos) {
        return "";
    }
    
    return json.substr(pos, endPos - pos);
}

// Получение всех задач
std::string TodoStorage::getAllTodos() {
    return readFromFile();
}

// Получение задачи по ID
std::string TodoStorage::getTodoById(const std::string& id) {
    std::string todosJson = readFromFile();
    
    // Проверяем, что у нас есть массив JSON
    if (todosJson.empty() || todosJson[0] != '[') {
        return "";
    }
    
    // Ищем объект с указанным ID
    size_t pos = 0;
    while (true) {
        // Находим начало объекта
        pos = todosJson.find('{', pos);
        if (pos == std::string::npos) {
            break;
        }
        
        // Находим конец объекта
        size_t endPos = pos + 1;
        int braceCount = 1;
        
        while (endPos < todosJson.length() && braceCount > 0) {
            if (todosJson[endPos] == '{') {
                braceCount++;
            } else if (todosJson[endPos] == '}') {
                braceCount--;
            }
            endPos++;
        }
        
        if (braceCount != 0) {
            // Некорректный JSON
            return "";
        }
        
        // Извлекаем объект
        std::string todoJson = todosJson.substr(pos, endPos - pos);
        
        // Проверяем ID
        std::string todoId = getJsonField(todoJson, "id");
        if (todoId == id) {
            return todoJson;
        }
        
        pos = endPos;
    }
    
    return ""; // Задача не найдена
}

// Добавление новой задачи
bool TodoStorage::addTodo(const std::string& todoJson) {
    // Проверяем, что todoJson - это объект JSON
    if (todoJson.empty() || todoJson[0] != '{') {
        return false;
    }
    
    // Извлекаем ID из todoJson
    std::string todoId = getJsonField(todoJson, "id");
    if (todoId.empty()) {
        return false;
    }
    
    // Проверяем, что задача с таким ID не существует
    if (!getTodoById(todoId).empty()) {
        return false;
    }
    
    // Читаем текущие задачи
    std::string todosJson = readFromFile();
    
    // Проверяем, что у нас есть массив JSON
    if (todosJson.empty() || todosJson[0] != '[') {
        todosJson = "[]";
    }
    
    // Добавляем новую задачу в массив
    if (todosJson == "[]") {
        todosJson = "[" + todoJson + "]";
    } else {
        // Удаляем закрывающую скобку и добавляем новую задачу
        todosJson = todosJson.substr(0, todosJson.length() - 1) + "," + todoJson + "]";
    }
    
    // Записываем обновленный массив в файл
    return writeToFile(todosJson);
}

// Обновление существующей задачи
bool TodoStorage::updateTodo(const std::string& todoJson) {
    // Проверяем, что todoJson - это объект JSON
    if (todoJson.empty() || todoJson[0] != '{') {
        return false;
    }
    
    // Извлекаем ID из todoJson
    std::string todoId = getJsonField(todoJson, "id");
    if (todoId.empty()) {
        return false;
    }
    
    // Читаем текущие задачи
    std::string todosJson = readFromFile();
    
    // Проверяем, что у нас есть массив JSON
    if (todosJson.empty() || todosJson[0] != '[') {
        return false;
    }
    
    // Ищем объект с указанным ID и заменяем его
    size_t pos = 0;
    std::string result = "[";
    bool found = false;
    
    while (true) {
        // Находим начало объекта
        size_t startPos = todosJson.find('{', pos);
        if (startPos == std::string::npos) {
            break;
        }
        
        // Находим конец объекта
        size_t endPos = startPos + 1;
        int braceCount = 1;
        
        while (endPos < todosJson.length() && braceCount > 0) {
            if (todosJson[endPos] == '{') {
                braceCount++;
            } else if (todosJson[endPos] == '}') {
                braceCount--;
            }
            endPos++;
        }
        
        if (braceCount != 0) {
            // Некорректный JSON
            return false;
        }
        
        // Извлекаем объект
        std::string currentTodoJson = todosJson.substr(startPos, endPos - startPos);
        
        // Проверяем ID
        std::string currentTodoId = getJsonField(currentTodoJson, "id");
        
        // Добавляем объект в результат
        if (result.length() > 1) {
            result += ",";
        }
        
        if (currentTodoId == todoId) {
            result += todoJson;
            found = true;
        } else {
            result += currentTodoJson;
        }
        
        pos = endPos;
    }
    
    result += "]";
    
    // Если задача не найдена, возвращаем false
    if (!found) {
        return false;
    }
    
    // Записываем обновленный массив в файл
    return writeToFile(result);
}

// Удаление задачи по ID
bool TodoStorage::deleteTodo(const std::string& id) {
    // Читаем текущие задачи
    std::string todosJson = readFromFile();
    
    // Проверяем, что у нас есть массив JSON
    if (todosJson.empty() || todosJson[0] != '[') {
        return false;
    }
    
    // Ищем объект с указанным ID и удаляем его
    size_t pos = 0;
    std::string result = "[";
    bool found = false;
    
    while (true) {
        // Находим начало объекта
        size_t startPos = todosJson.find('{', pos);
        if (startPos == std::string::npos) {
            break;
        }
        
        // Находим конец объекта
        size_t endPos = startPos + 1;
        int braceCount = 1;
        
        while (endPos < todosJson.length() && braceCount > 0) {
            if (todosJson[endPos] == '{') {
                braceCount++;
            } else if (todosJson[endPos] == '}') {
                braceCount--;
            }
            endPos++;
        }
        
        if (braceCount != 0) {
            // Некорректный JSON
            return false;
        }
        
        // Извлекаем объект
        std::string currentTodoJson = todosJson.substr(startPos, endPos - startPos);
        
        // Проверяем ID
        std::string currentTodoId = getJsonField(currentTodoJson, "id");
        
        // Добавляем объект в результат, если это не удаляемый объект
        if (currentTodoId != id) {
            if (result.length() > 1) {
                result += ",";
            }
            result += currentTodoJson;
        } else {
            found = true;
        }
        
        pos = endPos;
    }
    
    result += "]";
    
    // Если задача не найдена, возвращаем false
    if (!found) {
        return false;
    }
    
    // Записываем обновленный массив в файл
    return writeToFile(result);
}