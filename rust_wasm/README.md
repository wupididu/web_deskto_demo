# Todo WASM Implementation

This directory contains a Rust implementation of the TodoService that compiles to WebAssembly (WASM) for use in the Flutter web app.

## Prerequisites

- [Rust](https://www.rust-lang.org/tools/install)
- [wasm-pack](https://rustwasm.github.io/wasm-pack/installer/)

## Building

To build the WASM module, run the build script from the project root:

```bash
./build_wasm.sh
```

This will:
1. Compile the Rust code to WASM
2. Generate JavaScript bindings
3. Create a loader script
4. Place the output in the `web/wasm` directory

## Using the WASM Implementation

To use the WASM implementation instead of the JS interop implementation:

1. Uncomment the WASM loader script in `web/index.html`:
   ```html
   <!-- Conditionally load WASM module (uncomment when using WASM) -->
   <script src="wasm_loader.js"></script>
   ```

2. Update the conditional import in `lib/data/services/todo_service.dart`:
   ```dart
   import 'todo_method_channel_service.dart'
       if (dart.library.html) 'todo_wasm_service.dart';
   ```

## Development

The Rust code is in `src/lib.rs` and implements the same functionality as the JavaScript implementation in `web/app.js`. It uses the browser's localStorage API to store todos.

### Key Components

- `Todo` struct: Matches the Dart Todo model
- CRUD functions: Implement the same functionality as the JavaScript TodoService
- FFI bindings: Allow Dart to call the Rust functions

## Testing

To test the WASM implementation:

1. Build the WASM module
2. Enable the WASM loader in `web/index.html`
3. Update the conditional import in `todo_service.dart`
4. Run the Flutter web app