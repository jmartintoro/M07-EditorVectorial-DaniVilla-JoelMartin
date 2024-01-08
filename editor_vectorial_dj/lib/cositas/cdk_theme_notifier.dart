import 'package:flutter/cupertino.dart';
import 'cdk_theme.dart';

// Copyright © 2023 Albert Palacios. All Rights Reserved.
// Licensed under the BSD 3-clause license, see LICENSE file for details.

// To notify widgets of theme changes
class CDKThemeNotifier extends InheritedWidget {
  final CDKTheme changeNotifier;

  const CDKThemeNotifier({
    Key? key,
    required Widget child,
    required this.changeNotifier,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }

  static CDKThemeNotifier? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CDKThemeNotifier>();
  }
}
