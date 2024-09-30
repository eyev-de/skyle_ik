//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/foundation.dart';

class Configuration {
  static const String updateDestinationURL = 'http://192.168.137.2/api/update/';
  static const String updateURL = 'https://update.eyev.de/check.php';
  static const String isBetaDeviceURL = 'https://update.eyev.de/get_beta.php';
  static const String releaseNotesURL = 'https://update.eyev.de/notes.php';
  static const String updateBaseDirectory = 'updates';

  static String mjpegURL = 'http://192.168.137.2:8080/?action=stream';

  static const bool simulateET = kDebugMode && false;

  // static const grpcPort = 50052;
}
