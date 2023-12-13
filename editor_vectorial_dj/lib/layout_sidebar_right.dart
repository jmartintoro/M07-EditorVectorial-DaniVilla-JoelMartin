import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';
import 'layout_sidebar_tools.dart';
import 'util_tab_views.dart';

class LayoutSidebarRight extends StatefulWidget {
  const LayoutSidebarRight({Key? key}) : super(key: key);

  @override
  _LayoutSidebarRightState createState() => _LayoutSidebarRightState();
}

class _LayoutSidebarRightState extends State<LayoutSidebarRight> {
  late AppData appData;
  late CDKTheme theme;

  Color backgroundColor = Colors.white; // Provide a default color
  double screenHeight = 0;

  TextStyle fontBold =
      const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
  TextStyle font = const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  bool _isSwitched = false;
  int _selectedRadio = 1;
  int _indexButtonSelect0 = 1;
  int _indexButtonSelect1 = 1;
  late Widget _preloadedColorPicker;
  final GlobalKey<CDKDialogPopoverState> _anchorColorButton = GlobalKey();
  final ValueNotifier<Color> _valueColorNotifier =
      ValueNotifier(CDKTheme.green);

  @override
  void initState() {
    super.initState();
    // Initialize state variables here
  }

  @override
  Widget build(BuildContext context) {
    appData = Provider.of<AppData>(context);
    theme = CDKThemeNotifier.of(context)!.changeNotifier;

    backgroundColor = theme.backgroundSecondary2;
    screenHeight = MediaQuery.of(context).size.height;

    _preloadedColorPicker = _buildPreloadedColorPicker(appData);
    return Container(
        color: backgroundColor,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 1.0),
              height: screenHeight - 45,
              color: backgroundColor,
              child: UtilTabViews(
                isAccent: true,
                options: const [
                  Text('Document'),
                  Text('Format'),
                  Text('Shapes'),
                ],
                views: [
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Document dimensions:", style: fontBold),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text("Width:", style: font),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 80,
                                child: CDKFieldNumeric(
                                  value: appData.docSize.width,
                                  min: 100,
                                  max: 2500,
                                  units: "px",
                                  increment: 100,
                                  decimals: 0,
                                  onValueChanged: (value) {
                                    appData.setDocWidth(value);
                                  },
                                ),
                              ),
                              Expanded(child: Container()),
                              Text("Height:", style: font),
                              const SizedBox(width: 4),
                              SizedBox(
                                width: 80,
                                child: CDKFieldNumeric(
                                  value: appData.docSize.height,
                                  min: 100,
                                  max: 2500,
                                  units: "px",
                                  increment: 100,
                                  decimals: 0,
                                  onValueChanged: (value) {
                                    appData.setDocHeight(value);
                                  },
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LayoutSidebarTools(),
                        Expanded(
                          child: Visibility(
                            visible: true,
                            child:
                                _buildToolWidget(appData.toolSelected, context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        children: [
                          Text('List of shapes'),
                          SizedBox(
                            width: double.infinity,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: appData.shapesList.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    child: Container(
                                        padding: EdgeInsets.all(8),
                                        child: Text('Shape $index     ${appData.shapesWeight[index]}px')),
                                    onTap: () {
                                      appData.getRecuadreForm(index);
                                      appData.paintRecuadre = true;
                                    },
                                  );
                                }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  void _showPopoverColor(BuildContext context, GlobalKey anchorKey) {
    final GlobalKey<CDKDialogPopoverArrowedState> key = GlobalKey();
    if (anchorKey.currentContext == null) {
      // ignore: avoid_print
      print("Error: anchorKey not assigned to a widget");
      return;
    }
    CDKDialogsManager.showPopoverArrowed(
      key: key,
      context: context,
      anchorKey: anchorKey,
      isAnimated: true,
      isTranslucent: false,
      onHide: () {
        // ignore: avoid_print
        print("hide slider $key");
      },
      child: _preloadedColorPicker,
    );
  }

  Widget _buildPreloadedColorPicker(AppData data) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ValueListenableBuilder<Color>(
        valueListenable: _valueColorNotifier,
        builder: (context, value, child) {
          return CDKPickerColor(
            color: value,
            onChanged: (color) {
              setState(() {
                data.strokeColor = color;
                _valueColorNotifier.value = color;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildToolWidget(String selectedTool, BuildContext context) {
    switch (selectedTool) {
      case "pointer_shapes":
        return Container(
          child: Text('Widget para pointer_shapes'),
        );
      case "shape_drawing":
        return Container(
          padding: EdgeInsets.only(left: 10),
          width: double.infinity,
          child: Column(
            children: [
              Text(
                'Stroke and fill:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Row(children: [
                Text(
                  'Stroke width: ',
                  style: TextStyle(fontSize: 15),
                ),
                Container(
                    width: 50,
                    child: CDKFieldNumeric(
                      value: appData.strokeWeight,
                      onValueChanged: (value) {
                        setState(() {
                          value = value <= 100 ? value : 100;
                          appData.strokeWeight = value;
                        });
                      },
                    ))
              ]),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Text('Stroke Color: ', style: TextStyle(fontSize: 15)),
                  CDKButtonColor(
                    key: _anchorColorButton,
                    color: _valueColorNotifier.value,
                    onPressed: () {
                      _showPopoverColor(context, _anchorColorButton);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      case "view_grab":
        return Container(
          child: Text('Widget para view_grab'),
        );
      default:
        return Container();
    }
  }
}
