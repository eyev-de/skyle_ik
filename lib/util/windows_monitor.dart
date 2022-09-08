//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'windows_monitor_stub.dart' if (dart.library.io) 'windows_monitor_windows.dart' if (dart.library.html) 'windows_monitor_web.dart';

import 'dart:ui' as ui;

abstract class WindowsMonitor {
  ui.Size getSize();
  ui.Size getSizeBackup();
  factory WindowsMonitor() => getWindowsMonitor();
}
