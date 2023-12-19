import 'package:editor_vectorial_dj/app_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class LayoutSidebarShapes extends StatelessWidget {
  const LayoutSidebarShapes({super.key});

  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);
    return SizedBox(
      width: double.infinity, // Estira el widget horitzontalment
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
                          child: Text('Shape $index  ')),
                      onTap: () {
                        appData.getRecuadreForm(
                            index, appData.shapesList[index]);
                        appData.paintRecuadre = true;
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
