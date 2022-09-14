//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';

import '../../../../../ui/calibration/calibration_view.dart';
import '../../ui/main/main_view.dart';
import 'util/page_wrapper.dart';
import 'util/unknown_page.dart';
import 'route_state.dart';

enum MainRoutes {
  home('/'),
  capture('/calibration'),
  unknown('/unknown');

  const MainRoutes(this._path);
  final String _path;
  String get path => _path;

  static List<String> stringValues() {
    return [...MainRoutes.values.map((e) => e.path)];
  }

  static Page page(RouteState route) {
    final path = route.route;
    switch (fromPath(path)) {
      case MainRoutes.home:
        return PageWrapper(
          key: ValueKey(fromPath(path)),
          child: const MainView(),
        );
      case MainRoutes.capture:
        return PageWrapper(
          key: ValueKey(fromPath(path)),
          child: const CalibrationView(),
        );
      case MainRoutes.unknown:
        return UnknownPage.page();
    }
  }

  static MainRoutes fromPath(String path) {
    return MainRoutes.values.singleWhere((e) => e.path == path, orElse: () => MainRoutes.unknown);
  }
}
