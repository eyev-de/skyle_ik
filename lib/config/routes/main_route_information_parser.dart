//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'route_state.dart';

class MainRouteInformationParser extends RouteInformationParser<RouteState> {
  @override
  Future<RouteState> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location!);
    String? id;
    return RouteState(route: uri.path, id: id);
  }

  @override
  RouteInformation restoreRouteInformation(RouteState configuration) {
    return RouteInformation(location: configuration.route);
  }
}
