import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_desktop_kit/cdk.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

class LayoutSidebarFormat extends StatefulWidget {
  const LayoutSidebarFormat({super.key});

  @override
  LayoutSidebarFormatState createState() => LayoutSidebarFormatState();
}

class LayoutSidebarFormatState extends State<LayoutSidebarFormat> {

  late Widget _preloadedColorPicker;
  final GlobalKey<CDKDialogPopoverState> _anchorColorButton = GlobalKey();
  final ValueNotifier<Color> _valueColorNotifier =
      ValueNotifier(CDKTheme.black);

  @override
  void initState() {
    super.initState();
    AppData appData = Provider.of<AppData>(context, listen: false);

    _preloadedColorPicker = _buildPreloadedColorPicker(appData);
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

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
                Text("Stroke and fill:", style: fontBold),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                      alignment: Alignment.centerRight,
                      width: labelsWidth,
                      child: Text("Stroke width:", style: font)),
                  const SizedBox(width: 4),
                  Container(
                      alignment: Alignment.centerLeft,
                      width: 80,
                      child: CDKFieldNumeric(
                        value: appData.newShape.strokeWidth,
                        min: 0.01,
                        max: 100,
                        units: "px",
                        increment: 0.5,
                        decimals: 2,
                        onValueChanged: (value) {
                          appData.setNewShapeStrokeWidth(value);
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
                        child: Text("Stroke color:", style: font)),
                    const SizedBox(width: 4),
                    CDKButtonColor(
                      key: _anchorColorButton,
                      color: _valueColorNotifier.value,
                      onPressed: () {
                        _showPopoverColor(context, _anchorColorButton);
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


void _showPopoverColor(BuildContext context, GlobalKey anchorKey) {
  final GlobalKey<CDKDialogPopoverArrowedState> key = GlobalKey();
  if (anchorKey.currentContext == null || !mounted) {
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
}
