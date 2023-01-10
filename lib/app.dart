//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaze_interactive/api.dart';
import 'package:skyle_api/api.dart' as skyle;
import 'package:skyle_ik/config/positioning_type_notifier.dart';
import 'package:universal_platform/universal_platform.dart';

import '../util/extensions.dart';
import 'config/app_state.dart';
import 'config/configuration.dart';
import 'config/routes/main_routes.dart';
import 'config/routes/routes.dart';
import 'ui/main/theme.dart';
import 'util/windows_monitor.dart';

class SkyleApp extends ConsumerStatefulWidget {
  const SkyleApp({Key? key}) : super(key: key);

  @override
  ConsumerState<SkyleApp> createState() => _SkyleAppState();
}

// ignore: prefer_mixin
class _SkyleAppState extends ConsumerState<SkyleApp> with WidgetsBindingObserver {
  StreamSubscription<skyle.Connection>? _connectionStreamSubscription;

  _SkyleAppState();

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      if (AppState().et.connection == skyle.Connection.connected) {
        await AppState().et.settings.disableMouse(on: false);
        await AppState().et.settings.video(on: false);
      }
      // Stop Skyle API
      try {
        await AppState().et.disconnect();
      } catch (e) {
        print('Error disconnecting Skyle didChangeAppLifecycle. $e');
      }
    } else if (state == AppLifecycleState.resumed) {
      // Resume Skyle API
      try {
        await AppState().et.connect(grpcPort: Configuration.grpcPort);
      } catch (e) {
        print('Failed to connect Skyle in didChangeAppLifecycle. $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Routes.widgetRef = ref;

    WidgetsBinding.instance.addObserver(this);
    _connectionStreamSubscription = AppState().et.connectionStream.listen(_connectionListener);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      if (Configuration.simulateET) {
        // Test Skyle API
        await AppState().et.testConnectClients(url: 'localhost', port: 8001);
      } else {
        // Start Skyle API
        try {
          await AppState().et.connect(grpcPort: Configuration.grpcPort);
        } catch (e) {
          print('Failed to connect Skyle in initState. $e');
        }
      }
      Routes.currentRoute = MainRoutes.home.path;
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _connectionStreamSubscription?.cancel();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Skyle IK',
      theme: SkyleTheme.data(),
      routerDelegate: ref.read(AppState().routerDelegateProvider),
      routeInformationParser: ref.read(AppState().parserProvider),
    );
  }

  Future<void> _connectionListener(skyle.Connection connection) async {
    try {
      if (connection == skyle.Connection.connected) {
        if (GazeInteractive().active) {
          await AppState().et.settings.disableMouse();
        }
        if (ref.read(AppState().positioningTypeProvider) == PositioningType.video) {
          await AppState().et.settings.video();
        }

        SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
          if (!mounted) return;
          final MediaQueryData? mediaQuery = MediaQuery.maybeOf(context);
          if (mediaQuery != null) {
            final double width = mediaQuery.size.width;
            final double height = mediaQuery.size.height;
            if (UniversalPlatform.isWindows) {
              // final double dpi = mediaQuery.devicePixelRatio;
              // final double pixelPerMM = dpi * 96 / 25.4;
              Size size = WindowsMonitor().getSize();
              if (size.isEmpty) size = WindowsMonitor().getSizeBackup();
              // skyleLogger?.d('Width in mm: $size.width');
              // skyleLogger?.d('Height in mm: $size.height');
              print('Setting size: ${size.width} x ${size.height}.');
              print('Setting resolution: $width x $height.');
              await AppState().et.settings.setResolution(
                    screenSizes: skyle.ScreenSizes(
                      resolution: skyle.Size(
                        width: width,
                        height: height,
                      ),
                      dimensions: skyle.Size(width: size.width, height: size.height),
                    ),
                  );
            }
            if (UniversalPlatform.isIOS || (UniversalPlatform.isMacOS && kDebugMode)) {
              try {
                skyle.IPadModel model;
                final deviceInfo = DeviceInfoPlugin();
                final iosInfo = await deviceInfo.iosInfo;
                final deviceModel = iosInfo.utsname.machine!;
                model = skyle.IPadModel.values.firstWhere((element) => element.name == deviceModel.replaceAll(',', '_'), orElse: () {
                  print('iPad $deviceModel is not compatible with Skyle');
                  return skyle.IPadModel.iPad13_11;
                });
                await AppState().et.settings.setResolution(
                      screenSizes: skyle.ScreenSizes(
                        resolution: skyle.Size(
                          width: width,
                          height: height,
                        ),
                      ),
                    );
                final zoomed = MediaQueryExtension.isZoomed(context);
                final currentSettings = await AppState().et.settings.get();
                print('iPad model: $model');
                if (currentSettings is skyle.DataSuccess) {
                  print(currentSettings.data);
                  skyle.IPadOS iPadOS = currentSettings.data!.iPadOS.copyWith();
                  bool changed = false;
                  if (iPadOS.isNotZoomed != !zoomed) {
                    iPadOS = iPadOS.copyWith(isNotZoomed: !zoomed);
                    changed = true;
                    print('Reset because of isNotZoomed ${!zoomed}');
                  }
                  if (iPadOS.iPadModel != null && iPadOS.iPadModel != model) {
                    iPadOS = iPadOS.copyWith(iPadModel: model);
                    changed = true;
                    print('Reset because of iPadModel = $model');
                  }
                  final isOld = iosInfo.systemVersion!.compareTo('13.4') < 0;
                  if (iPadOS.isOld != isOld) {
                    iPadOS = iPadOS.copyWith(isOld: isOld);
                    changed = true;
                    print('Reset because of isOld $isOld');
                  }
                  if (changed) {
                    try {
                      await AppState().et.settings.setIPadOS(iPadOS: iPadOS);
                      await AppState().et.softDisconnect();
                      await Future.delayed(const Duration(seconds: 2));
                    } finally {
                      await AppState().et.trySoftReconnect();
                    }
                  }
                } else if (currentSettings is skyle.DataFailed) {
                  print(currentSettings.error);
                }
              } catch (error) {
                print(error);
              }
            }
          }
        });
      }
    } catch (error) {
      print('Error in SkyleApp. $error');
    }
  }
}
