//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:gaze_interactive/api.dart';
import 'package:millimeters/millimeters.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyle_api/api.dart' as skyle;
import 'package:universal_platform/universal_platform.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'config/app_state.dart';
import 'config/routes/routes.dart';
import 'package:logger/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GazeInteractive().predicate = Routes.gazeInteractionPredicate;
  AppState().sharedPreferences = await SharedPreferences.getInstance();
  skyle.ET.logger = Logger();

  if (UniversalPlatform.isDesktop) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(center: true,
        minimumSize: Size(1440, 900),
        titleBarStyle: TitleBarStyle.hidden);
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setSize(const Size(1440, 900));
    });

  }

  runApp(
    Millimeters.fromView(
      child: GazeContext(
        sharedPreferences: AppState().sharedPreferences,
        child: const SkyleApp(),
      ),
    ),
  );
}
