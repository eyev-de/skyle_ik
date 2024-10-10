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

import '../../config/app_state.dart';
import '../../config/routes/main_routes.dart';
import '../../data/models/update/update_state.dart';

class BetaSwitch extends ConsumerWidget {
  final AutoDisposeStreamProvider<skyle.DataState<UpdateState>> downloadUpdateProvider;

  const BetaSwitch({super.key, required this.downloadUpdateProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final isBeta = ref.watch(AppState().isBetaProvider).valueOrNull ?? const skyle.DataSuccess(false);
    // if (isBeta is skyle.DataSuccess && isBeta.data!) {
    return GazeSwitchButton(
      route: '${MainRoutes.home.path}/dialog',
      value: ref.read(AppState().betaFirmwareProvider),
      properties: GazeSwitchButtonProperties(
        activeColor: AppTheme.of(context).primaryColor,
        inactiveColor: Colors.grey.shade700,
        innerPadding: const EdgeInsets.all(10),
        margin: const EdgeInsets.fromLTRB(10, 20, 10, 20),
        size: const Size(50, 50),
      ),
      onChanged: (toggled) async {
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
        } catch (error) {
          // skyleLogger?.e('Error switching to ${toggled ? 'beta' : 'stable'} channel.', error, StackTrace.current);
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
