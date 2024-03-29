import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_desktop_kit/cdk_theme.dart';
import 'app_click_selector.dart';
import 'app_data_actions.dart';
import 'util_shape.dart';
import 'package:file_picker/file_picker.dart'; 
import 'dart:convert';
import 'package:xml/xml.dart';

class AppData with ChangeNotifier {
  // Access appData globaly with:
  // AppData appData = Provider.of<AppData>(context);
  // AppData appData = Provider.of<AppData>(context, listen: false)

  ActionManager actionManager = ActionManager();
  late BuildContext cont;
  bool isAltOptionKeyPressed = false;
  bool closeShape = false;
  double zoom = 95;
  Size docSize = const Size(500, 400);
  String toolSelected = "shape_drawing";
  Shape newShape = ShapeDrawing();
  List<Shape> shapesList = [];
  int shapeSelected = -1;
  int shapeSelectedPrevious = -1;
  bool firstMultilineClick = true; 
  String fileName = ""; ///////////////
  String directoryPath = ""; /////////////

  Color backgroundColor = Colors.transparent;
  Color oldBackColor = Colors.transparent;
  Color shapeFillColor = Colors.transparent;
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

  void setCloseShape(bool value) {
    closeShape = value;
    if (shapeSelected > -1) {
      shapesList[shapeSelected].closed = value;
      actionManager.register(ActionChangeClosed(this, shapeSelected, value));
    }
    notifyListeners();
  }

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

  void setBackgroundColor(Color color) {
    actionManager
        .register(ActionChangeBackgroundColor(this, oldBackColor, color));
    backgroundColor = color;
    oldBackColor = color;
    notifyListeners();
  }

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

  void setShapePosition(Offset newShapePosition) {
    actionManager.register(ActionChangePosition(this, shapeSelected, shapesList[shapeSelected].position, newShapePosition));
    shapesList[shapeSelected].setPosition(newShapePosition);
    notifyListeners();
  }

  void setShapeStrokeColor(Color newColor) {
    actionManager.register(ActionChangeStrokeColor(this, shapeSelected, shapesList[shapeSelected].strokeColor, newColor));
    shapesList[shapeSelected].strokeColor = newColor; 
    newShape.strokeColor = newColor;
    strokeColor = newColor;
    notifyListeners();
  }

  void setShapeFillColor(Color newColor) {
    actionManager.register(ActionChangeFillColor(this, shapeSelected, shapesList[shapeSelected].fillColor, newColor));
    shapesList[shapeSelected].fillColor = newColor;
    newShape.fillColor = newColor;
    shapeFillColor = newColor;
    forceNotifyListeners();
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
    newShape.setClosed(closeShape);
    newShape.setFillColor(shapeFillColor);
    notifyListeners();
  }

  void addNewSquare(Offset position) {
    newShape.setPosition(position);
    newShape.setInitialPosition(newShape.position);
    notifyListeners();
  }

  void addSquare(Offset position) {
    newShape.addRelativePoint(Offset(position.dx, newShape.initialPosition.dy));
    newShape.addRelativePoint(Offset(position.dx, position.dy));
    newShape.addRelativePoint(Offset(newShape.initialPosition.dx, position.dy));
    newShape.addRelativePoint(
        Offset(newShape.initialPosition.dx, newShape.initialPosition.dy));
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

  void moveLastVertice(Offset point) {
    if (newShape.getVertices().length >= 2) {
      newShape.getVertices().removeLast();
    }
    newShape.addRelativePoint(point);
    notifyListeners();
  }

  void moveSquareVertices(Offset point) {
    if (newShape.getVertices().length >= 4) {
      newShape.getVertices().removeLast();
      newShape.getVertices().removeLast();
      newShape.getVertices().removeLast();
      newShape.getVertices().removeLast();
    }
    addSquare(point);
  }

  void addNewShapeToShapesList() {
    // Si no hi ha almenys 2 punts, no es podrà dibuixar res
    if (newShape.vertices.length >= 2) {
      newShape.setStrokeColor(strokeColor);
      double strokeWidthConfig = newShape.strokeWidth;
      actionManager.register(ActionAddNewShape(this, newShape));
      newShape = ShapeDrawing();
      newShape.setStrokeWidth(strokeWidthConfig);
    }
  }

  void addNewEllipseToShapeList() {
    if (newShape.vertices.length >= 2) {
      ShapeEllipsis shape = ShapeEllipsis();
      shape.setAttributesFromOtherShape(newShape);
      shape.setStrokeColor(strokeColor);
      double strokeWidthConfig = shape.strokeWidth;
      actionManager.register(ActionAddNewShape(this, shape));
      newShape = ShapeDrawing();
      newShape.setStrokeWidth(strokeWidthConfig);
    }
  }

  void setShapeStrokeWidth(double newValue) {
    actionManager.register(ActionChangeStrokeWidth(this, shapeSelected, shapesList[shapeSelected].strokeWidth, newValue));
    shapesList[shapeSelected].strokeWidth = newValue;
    newShape.strokeWidth = newValue;
    getRecuadreForm(shapeSelected);
    notifyListeners();
  }

  void setNewShapeStrokeWidth(double value) {
    newShape.setStrokeWidth(value);
    notifyListeners();
  }

  void deleteShapeFromList(int shapeIndex) {
    //shapesList.remove(shapesList[shapeIndex]);
    actionManager.register(ActionDeleteShape(this, shapeIndex, shapesList[shapeSelected]));
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

  Future<void> loadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        File file = File(result.files.single.path!);
        if (!file.existsSync()) {
          print("El archivo no existe.");
          return;
        }

        String resultString = await file.readAsString();
        try {
          Map<String, dynamic> jsonData = jsonDecode(resultString);

          if (jsonData.containsKey('drawings')) {
            List<dynamic> drawings = jsonData['drawings'];
            for (var item in drawings) {
              Shape newShape = Shape.fromMap(item);
              shapesList.add(newShape);
              notifyListeners();
            }
          } else {
            print("El archivo no contiene la clave 'drawings'.");
          }
        } catch (e) {
          print("Error al decodificar el JSON: $e");
        }
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> saveFileToJSON() async {
    if (directoryPath == "") {
      await getDirectoryPath();
    }
    List<dynamic> JSONShapesList = [];
    for (int shape = 0; shape < shapesList.length; shape++) {
      JSONShapesList.add(jsonEncode(shapesList[shape].toMap()));
    }

    String jsonString = '{"drawings": $JSONShapesList}';

    File file = File("$directoryPath/$fileName.json");
    print(file.path);
    IOSink writer;

  try {
    writer = file.openWrite();
    
    writer.write(jsonString);

    print('DONE!');
  } catch (e) {
    print('Error al escribir: $e');
  } 
  }

  Future<void> getDirectoryPath() async {
      String? path = await FilePicker.platform.getDirectoryPath();
      if (path != null) {
          directoryPath = path;
      }
      print(directoryPath);
      notifyListeners();
  }

  saveToSVG() async {
    
    if (directoryPath == "") {
      await getDirectoryPath();
    }
    List<dynamic> JSONShapesList = [];
    for (int shape = 0; shape < shapesList.length; shape++) {
      JSONShapesList.add(jsonEncode(shapesList[shape].toMap()));
    }

    String jsonString = '{"drawings": $JSONShapesList}';


  Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  }

  createSvgFileWithShapes(List<Shape> shapes) {
    final svgDocument = XmlDocument([
      XmlProcessing('xml', 'version="1.0" encoding="UTF-8"'),
      XmlElement(XmlName('svg'), [
        XmlAttribute(XmlName('width'), docSize.width.toString()), // Ajusta el ancho del SVG
        XmlAttribute(XmlName('height'), docSize.height.toString()), // Ajusta la altura del SVG
      ], [
          for (var shape in shapes)
            if (shape is ShapeEllipsis) 
              XmlElement(XmlName('ellipse'), [
              XmlAttribute(XmlName('cx'), '${shape.vertices[0].dx + shape.position.dx}'), // Posicion de inicio (x)
              XmlAttribute(XmlName('cy'), '${shape.vertices[1].dy + shape.position.dy}'), // Posicion de inicio (y)
              XmlAttribute(XmlName('rx'), '${shape.vertices[1].dx/2-shape.vertices[0].dx/2}'), // Radio de x
              XmlAttribute(XmlName('ry'), '${shape.vertices[1].dy/2-shape.vertices[0].dy/2}'), // Radio de y
              XmlAttribute(XmlName('stroke'), '#${shape.strokeColor.value.toRadixString(16).substring(2)}'),// Color de la línea 
              XmlAttribute(XmlName('stroke-width'), shape.strokeWidth.toString()), // Grosor de la línea
              XmlAttribute(XmlName('stroke-opacity'), (int.parse('0x${shape.strokeColor.value.toRadixString(16).substring(0,2)}')/255).toString() /*(hex/255).toString()*/), // Opacidad de la línea
              XmlAttribute(XmlName('fill'), shape.fillColor == Colors.transparent ? 'none' : '#${shape.fillColor.value.toRadixString(16).substring(2)}') // Color de relleno (si tiene)
            ])
            else 
              XmlElement(shape.closed ? XmlName("polygon") : XmlName("polyline"), [
                XmlAttribute(XmlName('points'), shape.vertices.map((e) => '${e.dx + shape.position.dx},${e.dy + shape.position.dy}').join(' ')), // vertices
                XmlAttribute(XmlName('stroke'), '#${shape.strokeColor.value.toRadixString(16).substring(2)}'), // Color de la línea 
                XmlAttribute(XmlName('stroke-width'), shape.strokeWidth.toString()), // Grosor de la línea
                XmlAttribute(XmlName('stroke-opacity'), (int.parse('0x${shape.strokeColor.value.toRadixString(16).substring(0,2)}')/255).toString()), // Opacidad de la línea
                XmlAttribute(XmlName('fill'), shape.fillColor == Colors.transparent ? 'none' : '#${shape.fillColor.value.toRadixString(16).substring(2)}') // Color de relleno (si tiene)
            ]),
      ]),
    ]);

    final svgString = svgDocument.toXmlString(pretty: true);

    // Guarda el contenido SVG en un archivo
    final file = File('mi_archivo.svg');
    file.writeAsStringSync(svgString);
  }

}
