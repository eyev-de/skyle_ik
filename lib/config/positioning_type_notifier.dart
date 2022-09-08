//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';

enum PositioningType { video, guided }

class PositioningTypeNotifier extends StateNotifier<PositioningType> {
  PositioningTypeNotifier() : super(PositioningType.guided);

  Future<void> setState(PositioningType type) async {
    state = type;
    if (state == PositioningType.video) {
      await AppState().et.settings.video();
    } else {
      await AppState().et.settings.video(on: false);
    }
  }
}
