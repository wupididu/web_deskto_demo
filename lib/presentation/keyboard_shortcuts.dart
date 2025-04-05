import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app/router/app_router.dart';

/// A class that handles keyboard shortcuts for the web version of the app
class KeyboardShortcutsHandler extends StatelessWidget {
  final Widget child;

  final Function()? onRefresh;
  final Function()? onCreateTodo;
  final Function()? onToggleTodo;
  final Function()? onSave;

  const KeyboardShortcutsHandler({
    super.key,
    required this.child,
    this.onRefresh,
    this.onCreateTodo,
    this.onToggleTodo,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final routerDelegate = Provider.of<AppRouterDelegate>(
      context,
      listen: false,
    );
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          _handleKeyDown(event, context);
        }
      },
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          // Navigation shortcuts
          LogicalKeySet(LogicalKeyboardKey.escape): const CancelIntent(),

          // Create new todo shortcut
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
              const CreateIntent(),

          // Refresh shortcut
          LogicalKeySet(LogicalKeyboardKey.f5): const RefreshIntent(),
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR):
              const RefreshIntent(),

          // Save shortcut (for edit screen)
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
              const SaveIntent(),

          // Toggle completion shortcut
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.space):
              const ToggleIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            CancelIntent: CallbackAction<CancelIntent>(
              onInvoke: (CancelIntent intent) {
                routerDelegate.navigateToHome();
                return null;
              },
            ),
            CreateIntent: CallbackAction<CreateIntent>(
              onInvoke: (CreateIntent intent) {
                if (onCreateTodo != null) {
                  onCreateTodo!();
                } else {
                  routerDelegate.navigateToTodoEdit();
                }
                return null;
              },
            ),
            RefreshIntent: CallbackAction<RefreshIntent>(
              onInvoke: (RefreshIntent intent) {
                if (onRefresh != null) {
                  onRefresh!();
                }
                return null;
              },
            ),
            SaveIntent: CallbackAction<SaveIntent>(
              onInvoke: (SaveIntent intent) {
                if (onSave != null) {
                  onSave!();
                }
                return null;
              },
            ),
            ToggleIntent: CallbackAction<ToggleIntent>(
              onInvoke: (ToggleIntent intent) {
                if (onToggleTodo != null) {
                  onToggleTodo!();
                }
                return null;
              },
            ),
          },
          child: Focus(autofocus: true, child: child),
        ),
      ),
    );
  }

  void _handleKeyDown(KeyDownEvent event, BuildContext context) {
    // Additional key handling if needed
    debugPrint('Key pressed: ${event.logicalKey.keyLabel}');
  }
}

// Custom intents for keyboard shortcuts
class CancelIntent extends Intent {
  const CancelIntent();
}

class CreateIntent extends Intent {
  const CreateIntent();
}

class RefreshIntent extends Intent {
  const RefreshIntent();
}

class SaveIntent extends Intent {
  const SaveIntent();
}

class ToggleIntent extends Intent {
  const ToggleIntent();
}
