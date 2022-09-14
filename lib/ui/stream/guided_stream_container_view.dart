//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:skyle_api/api.dart';

import '../../config/app_state.dart';
import '../../util/responsive.dart';
import '../stream/guided_stream_view.dart';

class GuidedStreamContainerView extends ConsumerWidget {
  final double maxWidth;
  final double maxHeight;
  const GuidedStreamContainerView({
    Key? key,
    required this.maxWidth,
    required this.maxHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(AppState().positioningStreamProvider);

    return position.when(
      data: (value) {
        if (value is DataFailed) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                ],
              ),
            ],
          );
        }
        final data = value.data!;
        final double size = Responsive.getResponsiveValue(forLargeScreen: 20, forMediumScreen: 15, context: context);

        // print('{ ');
        // print("'left': { 'x': ${positioning.data.leftEye.x}, 'y': ${positioning.data.leftEye.y} },");
        // print("'right': { 'x': ${positioning.data.rightEye.x}, 'y': ${positioning.data.rightEye.y} }");
        // print(' },');
        var opacity = 1.0;
        if (data.distance == PositioningDistance.none) opacity = 0.0;
        return Stack(
          children: [
            GuidedStreamView(
              leftEye: data.eyes.left,
              rightEye: data.eyes.right,
              opacity: opacity,
              maxWidth: maxWidth,
              maxHeight: maxHeight,
              state: data.distance,
            ),
            _verticalQualityView(context, size, AppState().et.connection == Connection.connected),
            _horizontalQualityView(context, size, AppState().et.connection == Connection.connected),
            _verticalQualityIndicatorView(context, data, size),
            _horizontalQualityIndicatorView(context, data, size),
          ],
        );
      },
      loading: () => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
            ],
          ),
        ],
      ),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: Theme.of(context).textTheme.headline6!.copyWith(color: Colors.red),
        ),
      ),
    );
  }

  static Widget _verticalQualityView(BuildContext context, double size, bool connected) {
    return Container(
      // padding: EdgeInsets.fromLTRB(0, 0, 40, 40),
      alignment: Alignment.centerRight,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: size,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    if (connected) Colors.cyan.shade800 else Colors.grey.shade800,
                    if (connected) Colors.green else Colors.grey.shade500,
                    if (connected) Colors.cyan.shade800 else Colors.grey.shade800,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _horizontalQualityView(BuildContext context, double size, bool connected) {
    return Container(
      // padding: EdgeInsets.fromLTRB(40, 0, 40, 40),
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: size,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  colors: [
                    if (connected) Colors.cyan.shade800 else Colors.grey.shade800,
                    if (connected) Colors.green else Colors.grey.shade500,
                    if (connected) Colors.cyan.shade800 else Colors.grey.shade800,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _horizontalQualityIndicatorView(BuildContext context, PositioningMessage positioning, double size) {
    return Container(
      // padding: EdgeInsets.fromLTRB(40, 0, 40, 40),
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 10),
                left: gradientPosition(
                  positioning.quality.vertical.toDouble(),
                  constraints.maxWidth,
                ),
                top: constraints.maxHeight - size,
                child: Container(
                  height: size,
                  width: size,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _verticalQualityIndicatorView(BuildContext context, PositioningMessage positioning, double size) {
    return Container(
      // padding: EdgeInsets.fromLTRB(40, 0, 40, 40),
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 10),
                left: constraints.maxWidth - size,
                top: gradientPosition(
                  positioning.quality.horizontal.toDouble(),
                  constraints.maxHeight,
                ),
                child: Container(
                  height: size,
                  width: size,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static double gradientPosition(double quality, double measure) {
    return quality / 50 * measure / 2 + measure / 2;
  }
}
