//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaze_interactive/gaze_interactive.dart';
import 'package:skyle_api/api.dart';

import '../../config/routes/main_routes.dart';
import '../../config/app_state.dart';
import '../../config/positioning_type_notifier.dart';
import '../../util/responsive.dart';
import '../main/theme.dart';
import '../stream/guided_stream_container_view.dart';
import 'mjpeg/mjpeg_view.dart';

class StreamView extends ConsumerWidget {
  final PositioningTypeNotifier state;
  StreamView({Key? key})
      : state = PositioningTypeNotifier(),
        super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connection = ref.watch(AppState().connectionProvider).valueOrNull ?? Connection.disconnected;
    final positioningType = ref.watch(AppState().positioningTypeProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: Responsive.padding(context, const EdgeInsets.fromLTRB(0, 20, 0, 0)),
              child: Text(
                'Skyle IK',
                style: SkyleTheme.of(context).primaryTextTheme.headline1,
              ),
            ),
          ],
        ),
        if (connection != Connection.connected)
          Padding(
            padding: Responsive.padding(context, const EdgeInsets.fromLTRB(0, 20, 0, 0)),
            child: Text(
              'Skyle is not connected...',
              style: SkyleTheme.of(context).primaryTextTheme.bodyText1,
            ),
          ),
        if (connection == Connection.connected) _buttons(context, ref, true, positioningType == PositioningType.guided),
        if (connection == Connection.connected)
          Flexible(
            child: Container(
              padding: Responsive.padding(context, const EdgeInsets.fromLTRB(20, 0, 20, 20)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  var maxWidth = constraints.maxHeight * PositioningRepository.width / PositioningRepository.height;
                  if (maxWidth > constraints.maxWidth) maxWidth = constraints.maxWidth;
                  var maxHeight = constraints.maxWidth * PositioningRepository.height / PositioningRepository.width;
                  if (maxHeight > constraints.maxHeight) maxHeight = constraints.maxHeight;
                  return ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: maxWidth),
                    // child: Stack(
                    //   children: [
                    //     _mjpeg(context, maxWidth, maxWidth),
                    //     GuidedStreamContainerView(
                    //       et: et,
                    //       maxWidth: maxWidth,
                    //       maxHeight: maxHeight,
                    //     )
                    //   ],
                    // ),
                    child: positioningType == PositioningType.guided
                        ? GuidedStreamContainerView(
                            maxWidth: maxWidth,
                            maxHeight: maxHeight,
                          )
                        : _mjpeg(context, maxWidth, maxWidth),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _mjpeg(BuildContext context, double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: MjpegView(
        width: width,
        height: height,
        fit: BoxFit.fill,
        error: (context, error) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.videocam_off,
                    color: SkyleTheme.of(context).primaryColor,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _buttons(BuildContext context, WidgetRef ref, bool connected, bool guided) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        Flexible(
          flex: 2,
          child: Padding(
            padding: Responsive.padding(context, const EdgeInsets.fromLTRB(0, 20, 10, 20)),
            child: GazeButton(
              properties: GazeButtonProperties(
                key: GlobalKey(),
                text: 'Video',
                icon: Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: Responsive.getResponsiveValue(forLargeScreen: 35, forMediumScreen: 20, context: context),
                ),
                horizontal: true,
                backgroundColor: Colors.grey.shade900,
                borderColor: guided
                    ? Colors.transparent
                    : connected
                        ? SkyleTheme.of(context).primaryColor
                        : Colors.grey.shade700,
                route: MainRoutes.home.path,
                gazeInteractive: connected,
              ),
              onTap: connected
                  ? () async {
                      await ref.read(AppState().positioningTypeProvider.notifier).setState(PositioningType.video);
                    }
                  : null,
            ),
          ),
        ),
        Flexible(
          flex: 2,
          child: Padding(
            padding: Responsive.padding(context, const EdgeInsets.fromLTRB(10, 20, 0, 20)),
            child: GazeButton(
              properties: GazeButtonProperties(
                key: GlobalKey(),
                text: 'Positioning',
                icon: Icon(
                  Icons.remove_red_eye,
                  color: Colors.white,
                  size: Responsive.getResponsiveValue(forLargeScreen: 35, forMediumScreen: 20, context: context),
                ),
                horizontal: true,
                backgroundColor: Colors.grey.shade900,
                borderColor: guided
                    ? connected
                        ? SkyleTheme.of(context).primaryColor
                        : Colors.grey.shade700
                    : Colors.transparent,
                route: MainRoutes.home.path,
                gazeInteractive: connected,
              ),
              onTap: connected
                  ? () async {
                      await ref.read(AppState().positioningTypeProvider.notifier).setState(PositioningType.guided);
                    }
                  : null,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
