#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"
#include "todo_storage.h"

// Глобальный экземпляр TodoStorage
static TodoStorage* g_todo_storage = nullptr;

// Обработчик метода getAllTodos
static void handle_get_all_todos(FlMethodCall* method_call, FlMethodResponse** response) {
  std::string todos = g_todo_storage->getAllTodos();
  *response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string(todos.c_str())));
}

// Обработчик метода getTodoById
static void handle_get_todo_by_id(FlMethodCall* method_call, FlMethodResponse** response) {
  FlValue* args = fl_method_call_get_args(method_call);
  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    *response = FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGS",
                                                              "Invalid arguments for getTodoById",
                                                              nullptr));
    return;
  }
  
  FlValue* id_value = fl_value_lookup_string(args, "id");
  if (id_value == nullptr || fl_value_get_type(id_value) != FL_VALUE_TYPE_STRING) {
    *response = FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGS",
                                                              "Missing or invalid 'id' parameter",
                                                              nullptr));
    return;
  }
  
  const char* id = fl_value_get_string(id_value);
  std::string todo = g_todo_storage->getTodoById(id);
  
  if (todo.empty()) {
    *response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_null()));
  } else {
    *response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string(todo.c_str())));
  }
}

// Обработчик метода addTodo
static void handle_add_todo(FlMethodCall* method_call, FlMethodResponse** response) {
  FlValue* args = fl_method_call_get_args(method_call);
  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    *response = FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGS",
                                                              "Invalid arguments for addTodo",
                                                              nullptr));
    return;
  }
  
  FlValue* todo_value = fl_value_lookup_string(args, "todo");
  if (todo_value == nullptr || fl_value_get_type(todo_value) != FL_VALUE_TYPE_STRING) {
    *response = FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGS",
                                                              "Missing or invalid 'todo' parameter",
                                                              nullptr));
    return;
  }
  
  const char* todo_json = fl_value_get_string(todo_value);
  bool result = g_todo_storage->addTodo(todo_json);
  
  *response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(result)));
}

// Обработчик метода updateTodo
static void handle_update_todo(FlMethodCall* method_call, FlMethodResponse** response) {
  FlValue* args = fl_method_call_get_args(method_call);
  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    *response = FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGS",
                                                              "Invalid arguments for updateTodo",
                                                              nullptr));
    return;
  }
  
  FlValue* todo_value = fl_value_lookup_string(args, "todo");
  if (todo_value == nullptr || fl_value_get_type(todo_value) != FL_VALUE_TYPE_STRING) {
    *response = FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGS",
                                                              "Missing or invalid 'todo' parameter",
                                                              nullptr));
    return;
  }
  
  const char* todo_json = fl_value_get_string(todo_value);
  bool result = g_todo_storage->updateTodo(todo_json);
  
  *response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(result)));
}

// Обработчик метода deleteTodo
static void handle_delete_todo(FlMethodCall* method_call, FlMethodResponse** response) {
  FlValue* args = fl_method_call_get_args(method_call);
  if (fl_value_get_type(args) != FL_VALUE_TYPE_MAP) {
    *response = FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGS",
                                                              "Invalid arguments for deleteTodo",
                                                              nullptr));
    return;
  }
  
  FlValue* id_value = fl_value_lookup_string(args, "id");
  if (id_value == nullptr || fl_value_get_type(id_value) != FL_VALUE_TYPE_STRING) {
    *response = FL_METHOD_RESPONSE(fl_method_error_response_new("INVALID_ARGS",
                                                              "Missing or invalid 'id' parameter",
                                                              nullptr));
    return;
  }
  
  const char* id = fl_value_get_string(id_value);
  bool result = g_todo_storage->deleteTodo(id);
  
  *response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_bool(result)));
}

// Обработчик вызова методов
static void method_call_handler(FlMethodChannel* channel,
                               FlMethodCall* method_call,
                               gpointer user_data) {
  const gchar* method = fl_method_call_get_name(method_call);
  FlMethodResponse* response = nullptr;
  
  if (strcmp(method, "getAllTodos") == 0) {
    handle_get_all_todos(method_call, &response);
  } else if (strcmp(method, "getTodoById") == 0) {
    handle_get_todo_by_id(method_call, &response);
  } else if (strcmp(method, "addTodo") == 0) {
    handle_add_todo(method_call, &response);
  } else if (strcmp(method, "updateTodo") == 0) {
    handle_update_todo(method_call, &response);
  } else if (strcmp(method, "deleteTodo") == 0) {
    handle_delete_todo(method_call, &response);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }
  
  fl_method_call_respond(method_call, response, nullptr);
  g_object_unref(response);
}

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "web_desktop_demo");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "web_desktop_demo");
  }

  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));
  
  // Создаем экземпляр TodoStorage
  if (g_todo_storage == nullptr) {
    g_todo_storage = new TodoStorage();
  }
  
  // Регистрируем метод-канал
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(
    fl_engine_get_binary_messenger(fl_view_get_engine(view)),
    "com.example.web_desktop_demo/todo_storage",
    FL_METHOD_CODEC(codec));
  
  // Устанавливаем обработчик вызовов методов
  fl_method_channel_set_method_call_handler(channel,
                                          method_call_handler,
                                          nullptr,
                                          nullptr);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  //MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  //MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  
  // Освобождаем ресурсы TodoStorage
  if (g_todo_storage != nullptr) {
    delete g_todo_storage;
    g_todo_storage = nullptr;
  }
  
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}
