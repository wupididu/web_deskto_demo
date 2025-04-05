# Интеграция TodoStorage FFI в проект

Этот документ описывает процесс интеграции C++ библиотеки TodoStorage в проект Flutter для macOS, Windows и Linux.

## Общие шаги

1. Скомпилировать C++ библиотеку для каждой платформы
2. Добавить скомпилированную библиотеку в проект Flutter
3. Обновить конфигурацию сборки для каждой платформы
4. Использовать TodoService с параметром `useFFI = true`

## Компиляция C++ библиотеки

### Предварительные требования

- CMake 3.10 или выше
- Компилятор C++ с поддержкой C++17
- Для macOS: Xcode и Command Line Tools
- Для Windows: Visual Studio или MinGW
- Для Linux: GCC или Clang

### Компиляция

1. Создайте директорию для сборки:

```bash
mkdir -p build
cd build
```

2. Сконфигурируйте проект с помощью CMake:

```bash
cmake ../common
```

3. Скомпилируйте библиотеку:

```bash
cmake --build . --config Release
```

4. Скомпилированная библиотека будет находиться в директории `build/lib` (macOS, Linux) или `build/bin` (Windows).

## Интеграция в проект Flutter

### macOS

1. Скопируйте `libtodo_storage.dylib` в директорию `macos/Frameworks`:

```bash
mkdir -p macos/Frameworks
cp build/lib/libtodo_storage.dylib macos/Frameworks/
```

2. Обновите `macos/Runner.xcodeproj`:
   - Откройте проект в Xcode
   - Добавьте `libtodo_storage.dylib` в "Frameworks, Libraries, and Embedded Content"
   - Установите "Embed & Sign" для библиотеки


### Windows

1. Скопируйте `todo_storage.dll` в директорию `windows/flutter/ephemeral`:

```bash
mkdir -p windows/flutter/ephemeral
cp build/bin/todo_storage.dll windows/flutter/ephemeral/
```

2. Обновите `windows/CMakeLists.txt`, добавив:

```cmake
# Добавляем библиотеку TodoStorage
add_library(todo_storage SHARED IMPORTED)
set_target_properties(todo_storage PROPERTIES
    IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/flutter/ephemeral/todo_storage.dll"
    IMPORTED_IMPLIB "${CMAKE_CURRENT_SOURCE_DIR}/flutter/ephemeral/todo_storage.lib"
)
```

### Linux

1. Скопируйте `libtodo_storage.so` в директорию `linux/flutter/ephemeral`:

```bash
mkdir -p linux/flutter/ephemeral
cp build/lib/libtodo_storage.so linux/flutter/ephemeral/
```

2. Обновите `linux/CMakeLists.txt`, добавив:

```cmake
# Добавляем библиотеку TodoStorage
add_library(todo_storage SHARED IMPORTED)
set_target_properties(todo_storage PROPERTIES
    IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/flutter/ephemeral/libtodo_storage.so"
)
```

## Использование в Dart коде

Для использования FFI реализации в Dart коде:

```dart
import 'package:web_desktop_demo/data/services/todo_service.dart';

void main() {
  // Использование FFI реализации
  final todoService = TodoService(useFFI: true);
  
  // Использование MethodChannel реализации
  // final todoService = TodoService(useFFI: false);
  
  // Использование todoService...
}
```