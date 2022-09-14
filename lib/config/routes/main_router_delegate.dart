//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_state.dart';

import 'main_routes.dart';
import 'route_state.dart';
import 'routes.dart';

class MainRouterDelegate extends RouterDelegate<RouteState> with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteState> {
  final Ref ref;
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  MainRouterDelegate({required this.ref}) : navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'navigatorKey') {
    final unlisten = ref.listen<List<RouteState>>(AppState().navigatorProvider, (oldList, newList) {
      Routes.currentRoute = newList.last.route;
      notifyListeners();
    });
    ref.onDispose(unlisten.close);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Flexible(
            child: Navigator(
              key: navigatorKey,
              pages: ref.read(AppState().navigatorProvider.notifier).stack.map(MainRoutes.page).toList(),
              onPopPage: (route, result) {
                if (!route.didPop(result)) {
                  return false;
                }
                final notifier = ref.read(AppState().navigatorProvider.notifier);
                if (notifier.stack.length <= 1) return false;
                notifier.pop();
                return true;
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  RouteState get currentConfiguration => ref.read(AppState().navigatorProvider.notifier).route;

  // @override
  // GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  @override
  Future<void> setNewRoutePath(RouteState configuration) async {
    ref.read(AppState().navigatorProvider.notifier).route = configuration;
    return SynchronousFuture(null);
  }
}
