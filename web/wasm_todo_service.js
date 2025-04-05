// WASM module loader
(async function () {
  try {
    // Import the WASM module
    const wasm = await import('./wasm/todo_wasm.js');

    // Initialize the WASM module
    await wasm.default();

    console.log("WASM module loaded successfully");

    // Set a global flag to indicate WASM is available
    globalThis.wasm_todo_service = wasm
    globalThis.wasm_todo_service.wasmLoaded = true;
  } catch (error) {
    console.error("Failed to load WASM module:", error);
    globalThis.wasm_todo_service.wasmLoaded = false;
  }
})();
