//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skyle_api/api.dart';

import '../../config/app_state.dart';
import '../../config/routes/main_routes.dart';
import '../../widgets/gaze_slider.dart';
import '../../util/responsive.dart';

class GazeSpeedSettings extends ConsumerWidget {
  final gazeSpeedValueProvider = StateProvider.autoDispose((ref) {
    ref.watch(AppState().connectionProvider);
    final settingsState = ref.watch(AppState().settingsProvider).valueOrNull ?? const DataFailed('error');
    final settings = settingsState is DataSuccess ? settingsState.data! : const Settings();
    return 1 - (3 - settings.filter.gaze).abs() / 30;
  });

  final gazeSpeedAfterFixationValueProvider = StateProvider.autoDispose((ref) {
    ref.watch(AppState().connectionProvider);
    final settingsState = ref.watch(AppState().settingsProvider).valueOrNull ?? const DataFailed('error');
    final settings = settingsState is DataSuccess ? settingsState.data! : const Settings();
    return 1 - (3 - settings.filter.fixation).abs() / 30;
  });

  GazeSpeedSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(AppState().connectionProvider).valueOrNull ?? Connection.disconnected;
    final interactive = connection == Connection.connected;
    final settingsState = ref.watch(AppState().settingsProvider).valueOrNull ?? const DataFailed('error');
    final settings = settingsState is DataSuccess ? settingsState.data! : const Settings();
    return Row(
      children: [
        Flexible(
          child: Column(
            children: [
              const Spacer(
                flex: 2,
              ),
              const SizedBox(
                height: 70,
                child: Text('Gaze speed'),
              ),
              Flexible(
                flex: 8,
                child: Padding(
                  padding: Responsive.padding(context, const EdgeInsets.fromLTRB(0, 40, 0, 20)),
                  child: GazeSlider(
                    valueProvider: gazeSpeedValueProvider,
                    interactive: interactive,
                    route: MainRoutes.home.path,
                    onChanged: (newValue) async {
                      try {
                        await AppState().et.settings.setFilter(
                              filter: Filter(
                                gaze: (33 - newValue * 30).abs().round(),
                                fixation: settings.filter.fixation,
                              ),
                            );
                        await ref.refresh(AppState().settingsProvider.future);
                      } catch (error) {
                        print('Error saving filter.');
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          child: Column(
            children: [
              const Spacer(
                flex: 2,
              ),
              const SizedBox(
                height: 70,
                child: Text('Gaze speed after a fixation'),
              ),
              Flexible(
                flex: 8,
                child: Padding(
                  padding: Responsive.padding(context, const EdgeInsets.fromLTRB(0, 40, 0, 20)),
                  child: GazeSlider(
                    valueProvider: gazeSpeedAfterFixationValueProvider,
                    interactive: interactive,
                    route: MainRoutes.home.path,
                    onChanged: (newValue) async {
                      try {
                        await AppState().et.settings.setFilter(
                              filter: Filter(
                                fixation: (33 - newValue * 30).abs().round(),
                                gaze: settings.filter.gaze,
                              ),
                            );
                        await ref.refresh(AppState().settingsProvider.future);
                      } catch (error) {
                        print('Error saving filter.');
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
