import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  private var todoStorage: TodoStorage?
  
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  override func applicationDidFinishLaunching(_ notification: Notification) {
    // Инициализируем хранилище задач
    todoStorage = TodoStorage()
    
    // Получаем контроллер Flutter
    let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
    
    // Регистрируем метод-канал
    let todoChannel = FlutterMethodChannel(
      name: "com.example.web_desktop_demo/todo_storage",
      binaryMessenger: controller.engine.binaryMessenger)
    
    // Устанавливаем обработчик вызовов методов
    todoChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self, let todoStorage = self.todoStorage else {
        result(FlutterError(code: "UNAVAILABLE", message: "TodoStorage is not available", details: nil))
        return
      }
      
      switch call.method {
      case "getAllTodos":
        result(todoStorage.getAllTodos())
        
      case "getTodoById":
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for getTodoById", details: nil))
          return
        }
        result(todoStorage.getTodoById(id: id))
        
      case "addTodo":
        guard let args = call.arguments as? [String: Any],
              let todoJson = args["todo"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for addTodo", details: nil))
          return
        }
        result(todoStorage.addTodo(todoJson: todoJson))
        
      case "updateTodo":
        guard let args = call.arguments as? [String: Any],
              let todoJson = args["todo"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for updateTodo", details: nil))
          return
        }
        result(todoStorage.updateTodo(todoJson: todoJson))
        
      case "deleteTodo":
        guard let args = call.arguments as? [String: Any],
              let id = args["id"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments for deleteTodo", details: nil))
          return
        }
        result(todoStorage.deleteTodo(id: id))
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
