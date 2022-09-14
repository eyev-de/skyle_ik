//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaze_interactive/gaze_interactive.dart';
import 'package:minimize_app/minimize_app.dart';
import 'package:skyle_api/api.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../config/routes/main_routes.dart';
import '../../config/routes/routes.dart';
import '../../config/app_state.dart';
import '../../util/responsive.dart';
import '../settings/gaze_speed_settings.dart';
import 'logo.dart';
import 'theme.dart';
import '../stream/stream_view.dart';
import '../calibration/calibration_points_view.dart';

class MainView extends ConsumerWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(AppState().connectionProvider).valueOrNull ?? Connection.disconnected;
    return Stack(
      children: [
        Container(color: Colors.black),
        Row(
          children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: LogoTabbar(connection: connection),
                  ),
                  const Spacer(
                    flex: 3,
                  ),
                  _ExitButton(),
                ],
              ),
            ),
            Flexible(
              flex: 7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 4,
                    child: Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: GazeSpeedSettings(),
                        ),
                        Flexible(
                          flex: 8,
                          child: StreamView(),
                        ),
                        const Spacer(
                          flex: 2,
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: _CalibrationPointsSelection(),
                  ),
                ],
              ),
            ),
            _StartButton(),
          ],
        ),
        GazePointerView(),
      ],
    );
  }
}

class _CalibrationPointsSelection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(AppState().calibrationPointsProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var item in CalibrationPoints.values)
          Builder(
            builder: (context) {
              final backgroundColor = points.index == item.index ? Colors.grey.shade900 : Colors.grey.shade900;
              final borderColor = points.index == item.index ? SkyleTheme.of(context).primaryColor : Colors.transparent;
              return Flexible(
                child: Padding(
                  padding: Responsive.padding(context, const EdgeInsets.fromLTRB(20, 25, 20, 25)),
                  child: GazeButton(
                    properties: GazeButtonProperties(
                      key: GlobalKey(),
                      backgroundColor: backgroundColor,
                      borderColor: borderColor,
                      gazeInteractive: points != item,
                      child: CalibrationPointsView(
                        points: item.array,
                        color: Colors.yellow,
                      ),
                      route: MainRoutes.home.path,
                    ),
                    onTap: points == item
                        ? null
                        : () async {
                            await ref.read(AppState().calibrationPointsProvider.notifier).update(item);
                          },
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _StartButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: Responsive.padding(context, const EdgeInsets.all(20)),
        child: GazeButton(
          properties: GazeButtonProperties(
            key: GlobalKey(),
            backgroundColor: SkyleTheme.of(context).primaryColor,
            text: 'Calibrate',
            icon: Icon(
              Icons.remove_red_eye_sharp,
              color: Colors.white,
              size: Responsive.getResponsiveValue(forLargeScreen: 35, forMediumScreen: 20, context: context),
            ),
            route: MainRoutes.home.path,
          ),
          onTap: () {
            Routes.route(MainRoutes.capture.path);
          },
        ),
      ),
    );
  }
}

class _ExitButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Flexible(
      child: Padding(
        padding: Responsive.padding(context, const EdgeInsets.all(20)),
        child: GazeButton(
          properties: GazeButtonProperties(
            key: GlobalKey(),
            text: 'Exit',
            backgroundColor: SkyleTheme.of(context).primaryColor,
            icon: Icon(
              Icons.highlight_off_rounded,
              color: Colors.white,
              size: Responsive.getResponsiveValue(forLargeScreen: 35, forMediumScreen: 20, context: context),
            ),
            innerPadding: const EdgeInsets.all(0),
            route: MainRoutes.home.path,
          ),
          onTap: () async {
            await AppState().et.settings.video(on: false);
            if (UniversalPlatform.isLinux || UniversalPlatform.isMacOS) exit(0);
            if (UniversalPlatform.isWindows) {
              exit(0);
            } else if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
              await AppState().et.settings.disableMouse(on: false);
              await MinimizeApp.minimizeApp();
            }
          },
        ),
      ),
    );
  }
}
