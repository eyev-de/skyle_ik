//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'dart:ui' as ui;

import 'windows_monitor.dart';

class WindowsMonitorWeb implements WindowsMonitor {
  @override
  ui.Size getSize() {
    return const ui.Size(0, 0);
  }

  @override
  ui.Size getSizeBackup() {
    return const ui.Size(0, 0);
  }
}

WindowsMonitor getWindowsMonitor() => WindowsMonitorWeb();
