import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme.dart';
import 'app_click_selector.dart';
import 'app_data_actions.dart';
import 'util_shape.dart';

class AppData with ChangeNotifier {
  // Access appData globaly with:
  // AppData appData = Provider.of<AppData>(context);
  // AppData appData = Provider.of<AppData>(context, listen: false)

  ActionManager actionManager = ActionManager();
  late BuildContext cont;
  bool isAltOptionKeyPressed = false;
  bool closeShape = false; //////////////////////////
  double zoom = 95;
  Size docSize = const Size(500, 400);
  String toolSelected = "shape_drawing";
  Shape newShape = Shape();
  List<Shape> shapesList = [];
  int shapeSelected = -1;
  int shapeSelectedPrevious = -1;

  Color backgroundColor = Colors.transparent;
  Color oldBackColor = Colors.transparent; ///////////////////////
  Color shapeFillColor = Colors.transparent; ///////////////
  Color strokeColor = CDKTheme.black;
  List<double> recuadrePositions = []; //[x1,x2,y1,y2]

  bool readyExample = false;
  late dynamic dataExample;

  void forceNotifyListeners() {
    super.notifyListeners();
  }

  void setZoom(double value) {
    zoom = value.clamp(25, 500);
    notifyListeners();
  }

  ////////
  void setCloseShape(bool value) {
    closeShape = value;
    if (shapeSelected > -1) {
      shapesList[shapeSelected].closed = value;
      actionManager.register(ActionChangeClosed(this, shapeSelected, value));
    }
    notifyListeners();
  }
  ////////

  void setZoomNormalized(double value) {
    if (value < 0 || value > 1) {
      throw Exception(
          "AppData setZoomNormalized: value must be between 0 and 1");
    }
    if (value < 0.5) {
      double min = 25;
      zoom = zoom = ((value * (100 - min)) / 0.5) + min;
    } else {
      double normalizedValue = (value - 0.51) / (1 - 0.51);
      zoom = normalizedValue * 400 + 100;
    }
    notifyListeners();
  }

  double getZoomNormalized() {
    if (zoom < 100) {
      double min = 25;
      double normalized = (((zoom - min) * 0.5) / (100 - min));
      return normalized;
    } else {
      double normalizedValue = (zoom - 100) / 400;
      return normalizedValue * (1 - 0.51) + 0.51;
    }
  }

  void setDocWidth(double value) {
    double previousWidth = docSize.width;
    actionManager.register(ActionSetDocWidth(this, previousWidth, value));
  }

  void setDocHeight(double value) {
    double previousHeight = docSize.height;
    actionManager.register(ActionSetDocHeight(this, previousHeight, value));
  }

  ///////////////
  void setBackgroundColor(Color color) {
    actionManager
        .register(ActionChangeBackgroundColor(this, oldBackColor, color));
    backgroundColor = color;
    oldBackColor = color;
    notifyListeners();
  }
  ////////////

  void setToolSelected(String name) {
    toolSelected = name;
    notifyListeners();
  }

  void setShapeSelected(int index) {
    shapeSelected = index;

    if (index > -1) {
      newShape.strokeWidth = shapesList[index].strokeWidth;
      strokeColor = shapesList[index].strokeColor;
    }
    notifyListeners();
  }

  void changeShapePosition(Offset newShapePosition) {
    Shape oldShape = shapesList[shapeSelected];
    shapesList[shapeSelected].setPosition(newShapePosition);
  }

  Future<void> selectShapeAtPosition(Offset docPosition, Offset localPosition,
      BoxConstraints constraints, Offset center) async {
    shapeSelectedPrevious = shapeSelected;
    shapeSelected = -1;
    setShapeSelected(await AppClickSelector.selectShapeAtPosition(
        this, docPosition, localPosition, constraints, center));
  }

  void addNewShape(Offset position) {
    newShape.setPosition(position);
    newShape.addPoint(const Offset(0, 0));
    newShape.setInitialPosition(newShape.position);
    newShape.setClosed(closeShape);        /////////////////////
    newShape.setFillColor(shapeFillColor); ///////////////////////
    notifyListeners();
  }

  Future<void> addNewShapeFromClipboard() async {
    try {
      ClipboardData? clipboardData =
          await Clipboard.getData(Clipboard.kTextPlain);
      String? t = clipboardData?.text;

      if (clipboardData != null) {
        Shape newShape = Shape.fromMap(json.decode(t!) as Map<String, dynamic>);
        shapesList.add(newShape);
        //actionManager.register(ActionAddNewShape(this, newShape));
      } else {}
    } catch (e) {
      print('Error al obtener datos del portapapeles: $e');
    }

    notifyListeners();
  }

  void addRelativePointToNewShape(Offset point) {
    newShape.addRelativePoint(point);
    notifyListeners();
  }

  void addNewShapeToShapesList() {
    // Si no hi ha almenys 2 punts, no es podrà dibuixar res
    if (newShape.vertices.length >= 2) {
      newShape.setStrokeColor(strokeColor);
      double strokeWidthConfig = newShape.strokeWidth;
      actionManager.register(ActionAddNewShape(this, newShape));
      newShape = Shape();
      newShape.setStrokeWidth(strokeWidthConfig);
    }
  }

  void setNewShapeStrokeWidth(double value) {
    newShape.setStrokeWidth(value);
    notifyListeners();
  }

  void deleteShapeFromList(int shapeIndex) {
    shapesList.remove(shapesList[shapeIndex]);
    //actionManager.register(ActionDeleteShape(this, shapeIndex, shapesList));
    setShapeSelected(-1);
    notifyListeners();
  }

  Future<void> copyToClipboard() async {
    await Clipboard.setData(
        ClipboardData(text: jsonEncode(shapesList[shapeSelected].toMap())));
  }

  void getRecuadreForm(int shapeIndex) {
    Shape shape = shapesList[shapeIndex];
    double initialX = shape.position.dx;
    double initialY = shape.position.dy;

    double strokeWidth = shape.strokeWidth;

    double x1 = shapesList[shapeIndex].vertices[0].dx +
        initialX -
        strokeWidth / 2; //x més baixa
    double x2 = 0; //x més alta
    double y1 = shapesList[shapeIndex].vertices[0].dy +
        initialY -
        strokeWidth / 2; //y més baixa
    double y2 = 0; //y més alta

    for (Offset of in shapesList[shapeIndex].vertices) {
      if (of.dx + initialX - strokeWidth / 2 < x1) {
        x1 = of.dx + initialX - strokeWidth / 2;
      } else if (of.dx + initialX + strokeWidth / 2 > x2) {
        x2 = of.dx + initialX + strokeWidth / 2;
      }

      if (of.dy + initialY - strokeWidth / 2 < y1) {
        y1 = of.dy + initialY - strokeWidth / 2;
      } else if (of.dy + initialY + strokeWidth / 2 > y2) {
        y2 = of.dy + initialY + strokeWidth / 2;
      }
    }

    recuadrePositions.clear();
    recuadrePositions.add(x1);
    recuadrePositions.add(x2);
    recuadrePositions.add(y1);
    recuadrePositions.add(y2);
    notifyListeners();
  }
}
