import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var todoStorage: TodoStorage?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize TodoStorage
    todoStorage = TodoStorage()
    
    // Set up method channel
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.example.web_desktop_demo/todo_storage",
      binaryMessenger: controller.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      
      switch call.method {
      case "getAllTodos":
        let jsonString = self.todoStorage?.getAllTodos() ?? "[]"
        result(jsonString)
        
      case "getTodoById":
        guard let id = call.arguments as? [String: Any],
              let todoId = id["id"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "ID cannot be null", details: nil))
          return
        }
        
        let jsonString = self.todoStorage?.getTodoById(id: todoId)
        result(jsonString)
        
      case "addTodo":
        guard let args = call.arguments as? [String: Any],
              let todoJson = args["todo"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Todo JSON cannot be null", details: nil))
          return
        }
        
        let success = self.todoStorage?.addTodo(todoJson: todoJson) ?? false
        result(success)
        
      case "updateTodo":
        guard let args = call.arguments as? [String: Any],
              let todoJson = args["todo"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "Todo JSON cannot be null", details: nil))
          return
        }
        
        let success = self.todoStorage?.updateTodo(todoJson: todoJson) ?? false
        result(success)
        
      case "deleteTodo":
        guard let args = call.arguments as? [String: Any],
              let todoId = args["id"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENT", message: "ID cannot be null", details: nil))
          return
        }
        
        let success = self.todoStorage?.deleteTodo(id: todoId) ?? false
        result(success)
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
