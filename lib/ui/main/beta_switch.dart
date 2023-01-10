//  Skyle IK
//
//  Created by Konstantin Wachendorff.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaze_interactive/api.dart';
import 'package:skyle_api/api.dart' as skyle;

import '../../../config/theme/app_theme.dart';

import '../../../util/responsive.dart';
import '../../config/app_state.dart';
import '../../config/routes/main_routes.dart';
import '../../data/models/update/update_state.dart';

class BetaSwitch extends ConsumerWidget {
  final AutoDisposeStreamProvider<skyle.DataState<UpdateState>> downloadUpdateProvider;

  const BetaSwitch({Key? key, required this.downloadUpdateProvider}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final isBeta = ref.watch(AppState().isBetaProvider).valueOrNull ?? const skyle.DataSuccess(false);
    // if (isBeta is skyle.DataSuccess && isBeta.data!) {
    return GazeSwitchButton(
      properties: GazeSwitchButtonProperties(
        state: GazeSwitchButtonState(toggled: ref.read(AppState().betaFirmwareProvider)),
        toggledColor: AppTheme.of(context).primaryColor,
        unToggledColor: Colors.grey.shade700,
        innerPadding: const EdgeInsets.all(10),
        margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
        size: const Size(50, 50),
        route: '${MainRoutes.home.path}/dialog',
      ),
      onToggled: (toggled) async {
        try {
          await ref.read(AppState().betaFirmwareProvider.notifier).update(toggled);
          // print(toggled);
          // ref.read(AppState().uploadUpdateTriggerProvider.notifier).state = false;
          ref
            // ..invalidate(AppState().uploadUpdateProvider)
            ..invalidate(AppState().checkForUpdateProvider(toggled))
            ..invalidate(downloadUpdateProvider)
            ..invalidate(AppState().releaseNotesProvider(toggled));
          // await update.doYourThing(et.version);
          return true;
        } catch (error) {
          // skyleLogger?.e('Error switching to ${toggled ? 'beta' : 'stable'} channel.', error, StackTrace.current);
          return false;
        }
      },

      // loading: () => Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: [
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: const [
      //         CircularProgressIndicator(),
      //       ],
      //     ),
      //   ],
      // ),
      // error: (_, __) => Container(),
    );
    // }
    // return Container();
    // },
    // );
  }
}
