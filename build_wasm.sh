#!/bin/bash
set -e

# Check if wasm-pack is installed
if ! command -v wasm-pack &> /dev/null; then
    echo "wasm-pack is not installed. Please install it using:"
    echo "cargo install wasm-pack"
    exit 1
fi

# Build the Rust WASM module
echo "Building Rust WASM module..."
cd rust_wasm
wasm-pack build --target web --out-dir ../web/wasm

# Create a JavaScript loader for the WASM module
# echo "Creating WASM loader script..."
# cat > ../web/wasm_loader.js << 'EOL'
# // WASM module loader
# (async function() {
#   try {
#     // Import the WASM module
#     const wasm = await import('./wasm/todo_wasm.js');
    
#     // Initialize the WASM module
#     await wasm.default();
    
#     console.log("WASM module loaded successfully");
    
#     // Set a global flag to indicate WASM is available
#     window.wasmLoaded = true;
#   } catch (error) {
#     console.error("Failed to load WASM module:", error);
#     window.wasmLoaded = false;
#   }
# })();
# EOL

echo "WASM build completed successfully!"
echo "To use the WASM implementation, add the wasm_loader.js script to your index.html"
echo "and update the conditional import in todo_service.dart"