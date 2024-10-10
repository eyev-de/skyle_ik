//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skyle_api/api.dart';

import '../../config/app_state.dart';
import '../main/theme.dart';

// https://github.com/amsokol/flutter-grpc-tutorial/blob/master/flutter_client/lib/api/chat_service.dart

class GuidedStreamView extends ConsumerWidget {
  final Point leftEye;
  final Point rightEye;
  final double opacity;
  final double maxWidth;
  final double maxHeight;
  final PositioningDistance state;

  const GuidedStreamView({
    Key? key,
    required this.leftEye,
    required this.rightEye,
    required this.opacity,
    required this.maxWidth,
    required this.maxHeight,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double size = 70;
    switch (state) {
      case PositioningDistance.close:
        size *= 2;
        break;
      case PositioningDistance.far:
        size /= 2;
        break;
      case PositioningDistance.none:
        break;
      case PositioningDistance.normal:
        break;
    }

    final skyleVersion = ref.watch(AppState().skyleVersionProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey.shade900.withOpacity(0.5),
            // gradient: LinearGradient(
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            //   colors: [
            //     Colors.blue,
            //     Colors.yellow,
            //   ],
            //   tileMode: TileMode.clamp,
            // ),
          ),
        ),
        skyleVersion.when(
          data: (value) => value != null
              ? AnimatedPositioned(
                  key: const Key('LeftEye'),
                  left: leftEye.x / AppState().et.resolution(value.version).width * maxWidth - size / 2,
                  top: leftEye.y / AppState().et.resolution(value.version).height * maxHeight - size / 2,
                  duration: const Duration(milliseconds: 30),
                  child: AnimatedContainer(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(opacity), //SkyleTheme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    duration: const Duration(milliseconds: 100),
                  ),
                )
              : Container(),
          loading: () => Container(),
          error: (_, __) => Container(),
        ),
        skyleVersion.when(
          data: (value) => value != null
              ? AnimatedPositioned(
                  key: const Key('RightEye'),
                  left: rightEye.x / AppState().et.resolution(value!.version).width * maxWidth - size / 2,
                  top: rightEye.y / AppState().et.resolution(value.version).height * maxHeight - size / 2,
                  duration: const Duration(milliseconds: 30),
                  child: AnimatedContainer(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(opacity), //SkyleTheme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    duration: const Duration(milliseconds: 100),
                  ),
                )
              : Container(),
          loading: () => Container(),
          error: (_, __) => Container(),
        ),
        Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: state == PositioningDistance.close ? 1.0 : 0.0,
            child: Text(
              'You are too close, please increase the distance to Skyle.',
              style: SkyleTheme.of(context).primaryTextTheme.bodyLarge,
            ),
          ),
        ),
        Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: state == PositioningDistance.far ? 1.0 : 0.0,
            child: Text(
              'You are too far away, please move closer to Skyle.',
              style: SkyleTheme.of(context).primaryTextTheme.bodyLarge,
            ),
          ),
        ),
      ],
    );
  }
}
