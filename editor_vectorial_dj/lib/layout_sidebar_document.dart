import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutSidebarDocument extends StatefulWidget {
  const LayoutSidebarDocument({super.key});

  @override
  LayoutSidebarDocumentState createState() => LayoutSidebarDocumentState();
}

class LayoutSidebarDocumentState extends State<LayoutSidebarDocument> {
  //Para backgroundColor
  late Widget _preloadedColorPicker;
  final GlobalKey<CDKDialogPopoverState> _anchorColorButton = GlobalKey();
  final ValueNotifier<Color> _valueColorNotifier =
      ValueNotifier(CDKTheme.black);
  Color backColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    _preloadedColorPicker = _buildPreloadedColorPicker(appData);

    TextStyle fontBold =
        const TextStyle(fontSize: 12, fontWeight: FontWeight.bold);
    TextStyle font = const TextStyle(fontSize: 12, fontWeight: FontWeight.w400);

    return Container(
      padding: const EdgeInsets.all(4.0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double labelsWidth = constraints.maxWidth * 0.5;
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Document properties:", style: fontBold),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                      alignment: Alignment.centerRight,
                      width: labelsWidth,
                      child: Text("Width:", style: font)),
                  const SizedBox(width: 4),
                  Container(
                      alignment: Alignment.centerLeft,
                      width: 80,
                      child: CDKFieldNumeric(
                        value: appData.docSize.width,
                        min: 1,
                        max: 2500,
                        units: "px",
                        increment: 100,
                        decimals: 0,
                        onValueChanged: (value) {
                          appData.setDocWidth(value);
                        },
                      )),
                ]),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        alignment: Alignment.centerRight,
                        width: labelsWidth,
                        child: Text("Height:", style: font)),
                    const SizedBox(width: 4),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: 80,
                        child: CDKFieldNumeric(
                          value: appData.docSize.height,
                          min: 1,
                          max: 2500,
                          units: "px",
                          increment: 100,
                          decimals: 0,
                          onValueChanged: (value) {
                            appData.setDocHeight(value);
                          },
                        ))
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        alignment: Alignment.centerRight,
                        width: labelsWidth,
                        child: Text("Background color:", style: font)),
                    const SizedBox(width: 4),
                    CDKButtonColor(
                      key: _anchorColorButton,
                      color: appData.backgroundColor,
                      onPressed: () {
                        _showPopoverColor(context, _anchorColorButton, appData);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ]);
        },
      ),
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
              data.backgroundColor = color;
<<<<<<< HEAD
              backColor = color;
=======
              backColor = color; ///////////////
>>>>>>> 1d4c9663ef3eab8824693425171690915420852b
              data.notifyListeners();
            },
          );
        },
      ),
    );
  }

  void _showPopoverColor(
      BuildContext context, GlobalKey anchorKey, AppData data) {
    final GlobalKey<CDKDialogPopoverArrowedState> key = GlobalKey();

    if (anchorKey.currentContext == null) {
      print("Error: anchorKey not assigned to a widget");
      return;
    }
    CDKDialogsManager.showPopoverArrowed(
        key: key,
        context: context,
        anchorKey: anchorKey,
        isAnimated: true,
        isTranslucent: true,
        child: _preloadedColorPicker,
        ///////////////
        onHide: () {
          data.setBackgroundColor(backColor);
        }
        ///////////
        );
  }
}
