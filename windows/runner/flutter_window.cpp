#include "flutter_window.h"

#include <optional>
#include <map>
#include <string>

#include "flutter/generated_plugin_registrant.h"
#include "TodoStorage.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  
  // Создаем экземпляр TodoStorage
  static auto todoStorage = std::make_unique<TodoStorage>();
  
  // Регистрируем метод-канал
  flutter::MethodChannel<flutter::EncodableValue> todoChannel(
    flutter_controller_->engine()->messenger(),
    "com.example.web_desktop_demo/todo_storage",
    &flutter::StandardMethodCodec::GetInstance());
  
  // Устанавливаем обработчик вызовов методов
  todoChannel.SetMethodCallHandler(
    [todoStorage = todoStorage.get()](const flutter::MethodCall<flutter::EncodableValue>& call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
      
      const std::string& method_name = call.method_name();
      
      if (method_name == "getAllTodos") {
        result->Success(flutter::EncodableValue(todoStorage->getAllTodos()));
      } else if (method_name == "getTodoById") {
        const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
        if (arguments) {
          auto id_it = arguments->find(flutter::EncodableValue("id"));
          if (id_it != arguments->end() && std::holds_alternative<std::string>(id_it->second)) {
            const std::string& id = std::get<std::string>(id_it->second);
            result->Success(flutter::EncodableValue(todoStorage->getTodoById(id)));
          } else {
            result->Error("INVALID_ARGS", "Invalid arguments for getTodoById");
          }
        } else {
          result->Error("INVALID_ARGS", "Invalid arguments for getTodoById");
        }
      } else if (method_name == "addTodo") {
        const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
        if (arguments) {
          auto todo_it = arguments->find(flutter::EncodableValue("todo"));
          if (todo_it != arguments->end() && std::holds_alternative<std::string>(todo_it->second)) {
            const std::string& todoJson = std::get<std::string>(todo_it->second);
            result->Success(flutter::EncodableValue(todoStorage->addTodo(todoJson)));
          } else {
            result->Error("INVALID_ARGS", "Invalid arguments for addTodo");
          }
        } else {
          result->Error("INVALID_ARGS", "Invalid arguments for addTodo");
        }
      } else if (method_name == "updateTodo") {
        const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
        if (arguments) {
          auto todo_it = arguments->find(flutter::EncodableValue("todo"));
          if (todo_it != arguments->end() && std::holds_alternative<std::string>(todo_it->second)) {
            const std::string& todoJson = std::get<std::string>(todo_it->second);
            result->Success(flutter::EncodableValue(todoStorage->updateTodo(todoJson)));
          } else {
            result->Error("INVALID_ARGS", "Invalid arguments for updateTodo");
          }
        } else {
          result->Error("INVALID_ARGS", "Invalid arguments for updateTodo");
        }
      } else if (method_name == "deleteTodo") {
        const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
        if (arguments) {
          auto id_it = arguments->find(flutter::EncodableValue("id"));
          if (id_it != arguments->end() && std::holds_alternative<std::string>(id_it->second)) {
            const std::string& id = std::get<std::string>(id_it->second);
            result->Success(flutter::EncodableValue(todoStorage->deleteTodo(id)));
          } else {
            result->Error("INVALID_ARGS", "Invalid arguments for deleteTodo");
          }
        } else {
          result->Error("INVALID_ARGS", "Invalid arguments for deleteTodo");
        }
      } else {
        result->NotImplemented();
      }
    });
  
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
