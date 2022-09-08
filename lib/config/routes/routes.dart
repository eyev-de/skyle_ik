//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaze_interactive/state.dart';
import '../routes/main_routes.dart';

import '../app_state.dart';
import 'route_state.dart';

class Routes {
  static late WidgetRef widgetRef;
  static String get currentRoute => GazeInteractive().currentRoute;
  // // Do not call during build!!!
  static set currentRoute(String route) {
    print('Before: ${GazeInteractive().currentRoute} -> After: $route');
    GazeInteractive().currentRoute = route;
  }

  static void backOnlyRoute() {
    final temp = GazeInteractive().currentRoute;
    if (temp.split('/').length > 1) {
      String route = temp.substring(0, temp.lastIndexOf('/'));
      if (route == '') route = MainRoutes.home.path;
      currentRoute = route;
    } else {
      currentRoute = MainRoutes.home.path;
    }
  }

  static void route(String path, {String? id}) {
    widgetRef.read(AppState().navigatorProvider.notifier).route = RouteState(route: path, id: id);
  }

  static void back() {
    widgetRef.read(AppState().navigatorProvider.notifier).pop();
  }

  static void backAll() {
    widgetRef.read(AppState().navigatorProvider.notifier).popAll();
  }

  static void dialog() {
    currentRoute += '/dialog';
  }

  static bool gazeInteractionPredicate(Rect itemRect, Rect gazePointerRect, String itemRoute, String currentRoute) {
    // final intersection = itemRect.intersect(gazePointerRect);
    // if (intersection.width.isNegative || intersection.height.isNegative) return false;
    // final intersectionArea = intersection.width * intersection.height;
    // final gazePointerArea = gazePointerRect.width * gazePointerRect.height;
    // itemRect.overlaps(gazePointerRect)
    // Check in case of Dialog
    // intersectionArea >= gazePointerArea / 2
    // skyleLogger?.i('$itemRoute ?== $currentRoute');
    if (currentRoute.endsWith('dialog')) {
      if (itemRoute == currentRoute && itemRect.contains(gazePointerRect.center)) {
        return true;
      } else {
        return false;
      }
    }
    // Check in case of Regular Route
    if ((itemRoute == currentRoute) && itemRect.contains(gazePointerRect.center)) {
      return true;
    }
    return false;
  }
}
