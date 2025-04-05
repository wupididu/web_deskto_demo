/**
 * Todo class representing a todo item.
 * This class matches the JSTodo extension type in the Dart code.
 */
class Todo {
    constructor(id, title, description, isCompleted, createdAt, completedAt) {
        this._id = id;
        this._title = title;
        this._description = description;
        this._isCompleted = isCompleted;
        this._createdAt = createdAt;
        this._completedAt = completedAt;
    }

    // Getters to match the Dart JSTodo extension type
    get id() { return this._id; }
    get title() { return this._title; }
    get description() { return this._description; }
    get isCompleted() { return this._isCompleted; }
    get createdAt() { return this._createdAt; }
    get completedAt() { return this._completedAt; }
}

/**
 * TodoService class for managing todos in localStorage.
 * This class implements the methods required by the Dart TodoService interface.
 */
class TodoService {
    constructor() {
        this.storageKey = "web_desktop_demo_todos";
    }

    /**
     * Private method to get todos from localStorage
     * @returns {Array} Array of todo objects
     */
    _getTodos() {
        try {
            const todosJson = localStorage.getItem(this.storageKey);
            return todosJson ? JSON.parse(todosJson) : [];
        } catch (error) {
            console.error("Error retrieving todos from localStorage:", error);
            return [];
        }
    }

    /**
     * Private method to save todos to localStorage
     * @param {Array} todos - Array of todo objects to save
     * @returns {boolean} Success status
     */
    _saveTodos(todos) {
        try {
            localStorage.setItem(this.storageKey, JSON.stringify(todos));
            return true;
        } catch (error) {
            console.error("Error saving todos to localStorage:", error);
            return false;
        }
    }

    /**
     * Add a new todo
     * @param {Todo} todo - Todo object to add
     * @returns {Promise<boolean>} Promise resolving to success status
     */
    async addTodo(todo) {
        try {
            const todos = this._getTodos();
            todos.push(todo);
            return this._saveTodos(todos);
        } catch (error) {
            console.error("Error adding todo:", error);
            return false;
        }
    }

    /**
     * Delete a todo by ID
     * @param {string} id - ID of the todo to delete
     * @returns {Promise<boolean>} Promise resolving to success status
     */
    async deleteTodo(id) {
        try {
            const todos = this._getTodos();
            const newTodos = todos.filter(todo => todo.id !== id);

            // If the length is the same, no todo was deleted
            if (todos.length === newTodos.length) {
                return false;
            }

            return this._saveTodos(newTodos);
        } catch (error) {
            console.error("Error deleting todo:", error);
            return false;
        }
    }

    /**
     * Get all todos
     * @returns {Promise<Array<Todo>>} Promise resolving to array of Todo objects
     */
    async getAllTodos() {
        try {
            const todos = this._getTodos();
            return todos;
        } catch (error) {
            console.error("Error getting all todos:", error);
            return [];
        }
    }

    /**
     * Get a todo by ID
     * @param {string} id - ID of the todo to get
     * @returns {Promise<Todo|null>} Promise resolving to Todo object or null if not found
     */
    async getTodoById(id) {
        try {
            const todos = this._getTodos();
            const todo = todos.find(todo => todo.id === id);
            return todo ? new Todo(todo) : null;
        } catch (error) {
            console.error("Error getting todo by ID:", error);
            return null;
        }
    }

    /**
     * Update a todo
     * @param {Todo} todo - Todo object with updated values
     * @returns {Promise<boolean>} Promise resolving to success status
     */
    async updateTodo(todo) {
        try {
            const todos = this._getTodos();
            const index = todos.findIndex(t => t.id === todo.id);

            if (index === -1) {
                return false;
            }

            todos[index] = todo;

            return this._saveTodos(todos);
        } catch (error) {
            console.error("Error updating todo:", error);
            return false;
        }
    }
}

// Explicitly register TodoService and Todo in the global scope for Dart JS interop
globalThis.todo_service = this;
globalThis.todo_service.TodoService = TodoService;
globalThis.todo_service.Todo = Todo;

// Add diagnostic logging to verify registration
console.log("TodoService registered:", typeof globalThis.TodoService);
console.log("Todo registered:", typeof globalThis.Todo);
