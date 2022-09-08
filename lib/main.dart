//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaze_interactive/gaze_interactive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyle_api/api.dart' as skyle;
import 'package:universal_platform/universal_platform.dart';
import 'package:window_size/window_size.dart';

import 'app.dart';
import 'config/app_state.dart';
import 'config/routes/routes.dart';
import 'package:logger/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GazeInteractive().predicate = Routes.gazeInteractionPredicate;
  AppState().sharedPreferences = await SharedPreferences.getInstance();
  skyle.ET.logger = Logger();

  if (UniversalPlatform.isMacOS) {
    final Screen screen = (await getCurrentScreen())!;
    setWindowFrame(screen.frame);
    setWindowMinSize(const Size(1024, 768));
  }

  runApp(const ProviderScope(child: SkyleApp()));
}
