//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaze_interactive/gaze_interactive.dart';
import 'package:skyle_api/api.dart' as skyle;

import '../../config/routes/main_routes.dart';
import '../../config/routes/routes.dart';
import '../../config/app_state.dart';
import '../calibration/logo_button.dart';
import '../calibration/pointer_view.dart';
import '../calibration/reference_points_view.dart';

class CalibrationView extends ConsumerStatefulWidget {
  const CalibrationView({Key? key}) : super(key: key);

  @override
  ConsumerState<CalibrationView> createState() => _CalibrationViewState();
}

class _CalibrationViewState extends ConsumerState<CalibrationView> with SingleTickerProviderStateMixin {
  final List<skyle.Point> _referencePoints = [];
  bool _buttonandlogovisible = false;

  late final AnimationController controller = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> animation = Tween<double>(
    begin: 0.1,
    end: 1,
  ).animate(controller);

  AutoDisposeStreamProvider<skyle.DataState<skyle.CalibrationMessage>>? calibrationProvider;

  // @override
  // void reassemble() {
  //   super.reassemble();
  // if (Routes.currentRoute == CalibrationRoutes.capture.path) _init();
  // }

  @override
  void initState() {
    super.initState();
    if (Routes.currentRoute == MainRoutes.capture.path) _init();
  }

  void _init() {
    _referencePoints.clear();
    _buttonandlogovisible = false;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        calibrationProvider = StreamProvider.autoDispose((ref) {
          ref.onDispose(() {
            AppState().et.calibration.abort();
          });
          final MediaQueryData mediaQuery = MediaQuery.of(context);
          final calibrationPoints = ref.read(AppState().calibrationPointsProvider);

          return AppState().et.calibration.calibrate(
                calibrationPoints,
                screenSizes: skyle.ScreenSizes(resolution: skyle.Size(width: mediaQuery.size.width, height: mediaQuery.size.height)),
              );
        });
        setState(() {
          _buttonandlogovisible = false;
        });
      }
    });
    AppState().et.connectionStream.listen(_listener);
  }

  Future<void> _listener(skyle.Connection connection) async {
    if (connection == skyle.Connection.disconnected) {
      Routes.backAll();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    bool pointervisible = true;
    bool referencePointsVisible = false;
    skyle.Point pointerPosition = const skyle.Point();
    // Set point to mid
    pointerPosition = skyle.Point(x: mediaQuery.size.width / 2, y: mediaQuery.size.height / 2);

    bool buttonandlogovisible = _buttonandlogovisible;
    bool showGazePoint = false;
    final _calibrationProvider = calibrationProvider;
    final message = _calibrationProvider != null ? ref.watch(_calibrationProvider).value : null;
    if (message != null && message is skyle.DataFailed && message.error != null) print(message.error);

    if (message != null && message is skyle.DataSuccess && message.data != null && message.data! is skyle.CalibrationQualityMessage) {
      print('finished calibration...');
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(seconds: 1));
        if (AppState().gazeInteractive.active) {
          await AppState().et.settings.disableMouse();
        }
      });
      controller.stop();
      pointervisible = false;
      buttonandlogovisible = true;
      referencePointsVisible = true;
      showGazePoint = true;
    }
    if (message != null &&
        message is skyle.DataSuccess &&
        message.data != null &&
        message.data is skyle.CalibrationPointMessage &&
        message.data!.point != null &&
        message.data!.point!.coordinates.x > 0 &&
        message.data!.point!.coordinates.y > 0) {
      if (_referencePoints.isEmpty) buttonandlogovisible = false;
      _referencePoints.add(message.data!.point!.coordinates);
      pointerPosition = message.data!.point!.coordinates;
      pointervisible = true;
      print(message.data!.point!.coordinates);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onDoubleTap: () {
              setState(() {
                _buttonandlogovisible = true;
              });
            },
          ),
          AnimatedPositioned(
            left: _left(pointerPosition.x, 20),
            top: _top(pointerPosition.y, 20),
            duration: const Duration(milliseconds: 200),
            child: PointerView(
              visible: pointervisible,
              animation: animation,
            ),
          ),
          LogoButton(
            visible: buttonandlogovisible,
            onTap: () async {
              SchedulerBinding.instance.addPostFrameCallback((_) async {
                await AppState().et.calibration.abort();
                await Future.delayed(const Duration(seconds: 1));
                if (AppState().gazeInteractive.active) {
                  await AppState().et.settings.disableMouse();
                }
              });
              Routes.backAll();
            },
            route: MainRoutes.capture.path,
          ),
          if (referencePointsVisible &&
              message != null &&
              message is skyle.DataSuccess &&
              message.data != null &&
              message.data is skyle.CalibrationQualityMessage)
            ReferencePointsView(
              visible: referencePointsVisible,
              points: _referencePoints,
              message: message.data! as skyle.CalibrationQualityMessage,
            ),
          if (showGazePoint) GazePointerView(),
          // if (UniversalPlatform.isIOS || kDebugMode)
          //   CursorCalibrationOverlay(
          //     state: AppState().cursorCalibrationOverlayState,
          //   ),
        ],
      ),
    );
  }

  double _left(double x, double size) {
    if (x - size / 2.0 < 0) return 0;
    return x - size / 2.0;
  }

  double _top(double y, double size) {
    if (y - size / 2.0 < 0) return 0;
    return y - size / 2.0;
  }
}
