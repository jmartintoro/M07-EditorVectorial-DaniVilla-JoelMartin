import 'package:editor_vectorial_dj/app_data.dart';
import 'package:editor_vectorial_dj/cositas/cdk.dart';
import 'package:editor_vectorial_dj/sidebar_shapes_painter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LayoutSidebarShapes extends StatelessWidget {
  const LayoutSidebarShapes({super.key});

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    return SizedBox(
      width: double.infinity, // Estira el widget horitzontalment
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(color: Colors.transparent),
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              Text('List of shapes'),
              SizedBox(height: 10,),
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: appData.shapesList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Container(
                            decoration: BoxDecoration(
                                color: appData.shapeSelected == index
                                    ? Colors.blueAccent
                                    : Colors.transparent,
                                border: Border.all(
                                    color: Colors.black54, width: 2.5)),
                            height: 50,
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Shape $index  '),
                                CustomPaint(
                                  painter: SidebarShapePainter(
                                      appData.shapesList[index]),
                                  size: Size(50, 50),
                                )
                              ],
                            )),
                        onTap: () {
                          appData.getRecuadreForm(index);
                          appData.setShapeSelected(appData.shapeSelected == index ? -1 : index);
                          appData.setToolSelected("pointer_shapes");
                        },
                      );
                    }),
              ),
            ],
          ),
        ),
        onTap: () {
          appData.setShapeSelected(-1);
          appData.forceNotifyListeners();
        },
      ),
    );
  }
}
