//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'route_state.dart';
import 'main_routes.dart';

class MainNavigatorStateNotifier extends StateNotifier<List<RouteState>> {
  MainNavigatorStateNotifier() : super([RouteState(route: MainRoutes.home.path)]);

  List<RouteState> get stack => state;

  RouteState get route => state.last;
  set route(RouteState value) {
    // This ensures the route is never twice in the history.
    // This has to do with the clash of keys if there are duplicates.
    // Not optimal but will suffice for now
    state.removeWhere((element) => element.route.startsWith(value.route));
    // Check if tree was changed, removes all but one.
    if (state.isNotEmpty && !state.last.route.startsWith(value.route) && !value.route.startsWith(state.last.route)) {
      state.removeRange(1, state.length);
    }
    state = [...state, value];
  }

  RouteState pop() {
    final last = state.last;
    if (state.length > 1) state = [for (var i = 0; i < state.length - 1; i++) state[i]];
    return last;
  }

  RouteState popAll() {
    state = [state.first];
    return state.first;
  }

  RouteState ofAllNamed(RouteState value) {
    state = [value];
    return state.last;
  }

  RouteState until(bool Function(RouteState route) predicate, String route) {
    final index = state.indexWhere(predicate);
    state.removeRange(index, state.length - 1);
    state = [...state];
    return state.last;
  }

  void _printStack() {
    for (final route in stack) {
      print(route.route);
    }
  }
}
