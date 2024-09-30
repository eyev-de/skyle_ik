//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'dart:io';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaze_interactive/api.dart';
import 'package:minimize_app/minimize_app.dart';
import 'package:skyle_api/api.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../config/routes/main_routes.dart';
import '../../config/routes/routes.dart';
import '../../config/app_state.dart';

import '../../util/responsive.dart';
import '../settings/gaze_speed_settings.dart';
import 'logo.dart';
import 'search_for_update_button.dart';
import 'theme.dart';
import '../stream/stream_view.dart';
import '../calibration/calibration_points_view.dart';

class MainView extends ConsumerWidget {
  MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(AppState().connectionProvider).valueOrNull ?? Connection.disconnected;
    final beta = ref.watch(AppState().betaFirmwareProvider);
    final update = ref.watch(AppState().checkForUpdateProvider(beta)).valueOrNull ?? const DataFailed('error');
    final versions = ref.watch(AppState().versionsProvider).valueOrNull ?? const DataFailed('error');
    return Stack(
      children: [
        Container(color: Colors.black),
        Row(
          children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    flex: 2,
                    child: LogoTabbar(connection: connection),
                  ),
                  if (versions is DataSuccess)
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Material(
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(versions.data!.firmware),
                              ),
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: versions.data!.firmware));
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5),
                          child: Material(
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text('${versions.data!.serial}'),
                              ),
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: '${versions.data!.serial}'));
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  Consumer(
                    builder: (context, loalRef, child) {
                      final skyleVersion = loalRef.watch(AppState().skyleVersionProvider);
                      return Column(
                        children: <Widget>[
                          ListTile(
                            title: const Text('Skyle 2'),
                            leading: Radio<SkyleVersion>(
                              value: SkyleVersion.skyle2,
                              groupValue: skyleVersion,
                              onChanged: (SkyleVersion? value) async {
                                ref.read(AppState().skyleVersionProvider.notifier).state = value!;
                                await AppState().et.disconnect();
                                await AppState().et.connect(grpcPort: value.version);
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text('Sykle 3'),
                            leading: Radio<SkyleVersion>(
                              value: SkyleVersion.skyle3,
                              groupValue: skyleVersion,
                              onChanged: (SkyleVersion? value) async {
                                ref.read(AppState().skyleVersionProvider.notifier).state = value!;
                                await AppState().et.disconnect();
                                await AppState().et.connect(grpcPort: value.version);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(),
                  Consumer(
                    builder: (context, loalRef, child) {
                      final skyleType = loalRef.watch(AppState().skyleTypeProvider);

                      return Column(
                        children: <Widget>[
                          ListTile(
                            title: const Text('SIK'),
                            leading: Radio<SkyleType>(
                              value: SkyleType.skyleIntegrationKit,
                              groupValue: skyleType,
                              onChanged: (SkyleType? value) async {
                                ref.read(AppState().skyleTypeProvider.notifier).state = value!;
                                await AppState().et.disconnect();
                                await AppState().et.connect(grpcPort: value.port);
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text('SFI'),
                            leading: Radio<SkyleType>(
                              value: SkyleType.skyleForIpad,
                              groupValue: skyleType,
                              onChanged: (SkyleType? value) async {
                                ref.read(AppState().skyleTypeProvider.notifier).state = value!;
                                await AppState().et.disconnect();
                                await AppState().et.connect(grpcPort: value.port);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  badges.Badge(
                    position: badges.BadgePosition.topEnd(top: 20, end: 10),
                    badgeContent: const Padding(
                      padding: EdgeInsets.all(5),
                      child: Text('1'),
                    ),
                    showBadge: update is DataSuccess && update.data!.newupdate,
                    child: Container(),
                  ),
                  const SearchForFirmwareUpdateButton(),
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
                    color: backgroundColor,
                    properties: GazeButtonProperties(
                      gazeInteractive: points != item,
                      route: MainRoutes.home.path,
                    ),
                    onTap: points == item
                        ? null
                        : () async {
                            await ref.read(AppState().calibrationPointsProvider.notifier).update(item);
                          },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: borderColor,
                            width: 3,
                          )),
                      child: CalibrationPointsView(
                        points: item.array,
                        color: Colors.yellow,
                      ),
                    ),
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
          color: SkyleTheme.of(context).primaryColor,
          properties: GazeButtonProperties(
            text: const Text('Calibrate'),
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
          color: SkyleTheme.of(context).primaryColor,
          properties: GazeButtonProperties(
            text: const Text('Exit'),
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
