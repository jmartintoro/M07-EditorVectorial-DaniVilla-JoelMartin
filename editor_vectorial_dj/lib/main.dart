import 'dart:io' show Platform;
import 'package:editor_vectorial_dj/util_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'app_data.dart';
import 'layout.dart';

void main() async {
  // For Linux, macOS and Windows, initialize WindowManager
  try {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      WidgetsFlutterBinding.ensureInitialized();
      await WindowManager.instance.ensureInitialized();
      windowManager.waitUntilReadyToShow().then(showWindow);
    }
  } catch (e) {
    // ignore: avoid_print
    print(e);
  }

  AppData appData = AppData();

  runApp(Focus(
    onKey: (FocusNode node, RawKeyEvent event) {
      bool isControlPressed = (Platform.isMacOS && event.isMetaPressed) ||
          (Platform.isLinux && event.isControlPressed) ||
          (Platform.isWindows && event.isControlPressed);
      bool isShiftPressed = event.isShiftPressed;
      bool isZPressed = event.logicalKey == LogicalKeyboardKey.keyZ;
      bool isDeletePressed = event.logicalKey == LogicalKeyboardKey.delete;
      bool isBackspacePressed =
          event.logicalKey == LogicalKeyboardKey.backspace;
      bool isPpressed = event.logicalKey == LogicalKeyboardKey.keyP;
      bool isDpressed = event.logicalKey == LogicalKeyboardKey.keyD;
      bool isGpressed = event.logicalKey == LogicalKeyboardKey.keyG;
      bool isCpressed = event.logicalKey == LogicalKeyboardKey.keyC;
      bool isXpressed = event.logicalKey == LogicalKeyboardKey.keyX;
      bool isVpressed = event.logicalKey == LogicalKeyboardKey.keyV;
      bool isYpressed = event.logicalKey == LogicalKeyboardKey.keyY;

      if (event is RawKeyDownEvent) {
        if (isControlPressed && isZPressed && !isShiftPressed) {
          appData.setShapeSelected(
              -1); 
          appData.actionManager.undo();
          return KeyEventResult.handled;
        } else if ((isControlPressed && isShiftPressed && isZPressed) ||
            (isControlPressed && isYpressed)) {
          appData.setShapeSelected(
              -1); 
          appData.actionManager.redo();
          return KeyEventResult.handled;
        }
        //Per eliminar un Shape (Ctrl+Supr), Copiar (Ctrl+C), Retallar (Ctrl+X), Pegar (Ctrl+V)
        if (isControlPressed &&
            (isDeletePressed || isBackspacePressed) &&
            appData.shapeSelected != -1) {
          appData.deleteShapeFromList(appData.shapeSelected);
          return KeyEventResult.handled;
        } else if (isControlPressed && isCpressed) {
          //Ctrl+C
          if (appData.shapeSelected > -1) {
            appData.copyToClipboard();
            return KeyEventResult.handled;
          }
        } else if (isControlPressed && isVpressed) {
          appData.addNewShapeFromClipboard();
          appData.notifyListeners();
        } else if (isControlPressed && isXpressed) {
          if (appData.shapeSelected > -1) {
            appData.copyToClipboard();
            appData.deleteShapeFromList(appData.shapeSelected);
            appData.notifyListeners();
            return KeyEventResult.handled;
          }
        }

/*         //Shortcuts per cambiar entre eines (P,D,G)
        if (isPpressed) {
          appData.setToolSelected("pointer_shapes");
          return KeyEventResult.handled;
        } else if (isDpressed) {
          appData.setToolSelected("shape_drawing");
          return KeyEventResult.handled;
        } else if (isGpressed) {
          appData.setToolSelected("view_grab");
          return KeyEventResult.handled;
        } */

        if (event.logicalKey == LogicalKeyboardKey.altLeft) {
          appData.isAltOptionKeyPressed = true;
        }
      } else if (event is RawKeyUpEvent) {
        if (event.logicalKey == LogicalKeyboardKey.altLeft) {
          appData.isAltOptionKeyPressed = false;
        }
      }
      return KeyEventResult.ignored;
    },
    child: ChangeNotifierProvider(
      create: (context) => appData,
      child: const CDKApp(
        defaultAppearance: "system", // system, light, dark
        defaultColor:
            "systemBlue", // systemBlue, systemPurple, systemPink, systemRed, systemOrange, systemYellow, systemGreen, systemGray
        child: Layout(),
      ),
    ),
  ));
}

// Show the window when it's ready
void showWindow(_) async {
  const size = Size(800.0, 600.0);
  windowManager.setSize(size);
  windowManager.setMinimumSize(size);
  await windowManager.setTitle('Vector Editor');
}
