// Cada acció ha d'implementar les funcions undo i redo
import 'dart:ui';

import 'app_data.dart';
import 'util_shape.dart';

abstract class Action {
  void undo();
  void redo();
}

// Gestiona la llista d'accions per poder desfer i refer
class ActionManager {
  List<Action> actions = [];
  int currentIndex = -1;

  void register(Action action) {
    // Elimina les accions que estan després de l'índex actual
    if (currentIndex < actions.length - 1) {
      actions = actions.sublist(0, currentIndex + 1);
    }
    actions.add(action);
    currentIndex++;
    action.redo();
  }

  void undo() {
    if (currentIndex >= 0) {
      actions[currentIndex].undo();
      currentIndex--;
    }
  }

  void redo() {
    if (currentIndex < actions.length - 1) {
      currentIndex++;
      actions[currentIndex].redo();
    }
  }
}

class ActionSetDocWidth implements Action {
  final double previousValue;
  final double newValue;
  final AppData appData;

  ActionSetDocWidth(this.appData, this.previousValue, this.newValue);

  _action(double value) {
    appData.docSize = Size(value, appData.docSize.height);
    appData.forceNotifyListeners();
  }

  @override
  void undo() {
    _action(previousValue);
  }

  @override
  void redo() {
    _action(newValue);
  }
}

class ActionSetDocHeight implements Action {
  final double previousValue;
  final double newValue;
  final AppData appData;

  ActionSetDocHeight(this.appData, this.previousValue, this.newValue);

  _action(double value) {
    appData.docSize = Size(appData.docSize.width, value);
    appData.forceNotifyListeners();
  }

  @override
  void undo() {
    _action(previousValue);
  }

  @override
  void redo() {
    _action(newValue);
  }
}

class ActionAddNewShape implements Action {
  final AppData appData;
  final Shape newShape;

  ActionAddNewShape(this.appData, this.newShape);

  @override
  void undo() {
    appData.shapesList.remove(newShape);
    appData.forceNotifyListeners();
  }

  @override
  void redo() {
    appData.shapesList.add(newShape);
    appData.forceNotifyListeners();
  }
}

//////////////////////////////////////////7
class ActionChangeBackgroundColor implements Action {
  final AppData appData;
  final Color oldColor;
  final Color newColor;

  ActionChangeBackgroundColor(this.appData, this.oldColor, this.newColor);

  @override
  void undo() {
    appData.backgroundColor = oldColor;
    appData.notifyListeners();
  }

  @override
  void redo() {
    appData.backgroundColor = newColor;
    appData.notifyListeners();
  }
}
/////////////////////////////////////

class ActionDeleteShape implements Action {
  final AppData appData;
  final int id;
  final List<Shape> shapeList;

  ActionDeleteShape(this.appData, this.id, this.shapeList);

  @override
  void undo() {
    appData.shapesList.clear();
    appData.shapesList = shapeList;
  }

  @override
  void redo() {
    appData.deleteShapeFromList(id);
  }
}

////////////////////
class ActionChangeClosed implements Action {
  final AppData appData;
  final bool newValue;
  final int id;

  ActionChangeClosed(this.appData, this.id, this.newValue);

  @override
  void undo() {
    appData.shapesList[id].setClosed(!newValue);
    appData.notifyListeners();
  }

  @override
  void redo() {
    appData.shapesList[id].setClosed(newValue);
    appData.notifyListeners();
  }
}
  //////////////////
