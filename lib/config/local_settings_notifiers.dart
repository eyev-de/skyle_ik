//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:enum_to_string/enum_to_string.dart';
import 'package:skyle_api/api.dart';

import '../../../config/app_state.dart';
import '../../core/local_store_notifier.dart';

class CalibrationPointsLocalNotifier extends LocalStoreNotifier<CalibrationPoints> {
  CalibrationPointsLocalNotifier()
      : super(
          AppState().sharedPreferences,
          'calibrationPoints',
          CalibrationPoints.nine,
          initialValue: EnumToString.fromString(
                CalibrationPoints.values,
                AppState().sharedPreferences.getString('calibrationPoints') ?? '',
              ) ??
              CalibrationPoints.nine,
        );
}

class UploadSampleLocalNotifier extends LocalStoreNotifier<bool> {
  UploadSampleLocalNotifier() : super(AppState().sharedPreferences, 'uploadSample', false);
}

class FirstLaunchLocalNotifier extends LocalStoreNotifier<bool> {
  FirstLaunchLocalNotifier() : super(AppState().sharedPreferences, 'firstLaunch', true);
}

class BetaFirmwareLocalNotifier extends LocalStoreNotifier<bool> {
  BetaFirmwareLocalNotifier() : super(AppState().sharedPreferences, 'betaFirmware', false);
}
