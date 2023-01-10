//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaze_interactive/api.dart';
import 'package:skyle_ik/ui/main/theme.dart';
import 'package:skyle_ik/util/responsive.dart';

class GazeSlider extends ConsumerWidget {
  final AutoDisposeStateProvider<double> valueProvider;
  final bool interactive;
  final String route;
  final void Function(double) onChanged;

  const GazeSlider({
    super.key,
    required this.valueProvider,
    required this.interactive,
    required this.route,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentValue = ref.watch(valueProvider);
    final size = Responsive.getResponsiveValue(
      forLargeScreen: 80.0,
      forMediumScreen: 60.0,
      forSmallScreen: 40.0,
      context: context,
    );
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: GazeButton(
            properties: GazeButtonProperties(
              route: route,
              icon: Icon(
                Icons.arrow_upward,
                color: SkyleTheme.of(context).primaryColor,
              ),
              borderColor: SkyleTheme.of(context).primaryColor,
              horizontal: true,
              gazeInteractive: interactive,
              innerPadding: const EdgeInsets.all(0),
            ),
            onTap: () {
              double newValue = currentValue + 0.1;
              if (newValue > 1) {
                newValue = 1;
              }
              onChanged(newValue);
            },
          ),
        ),
        Flexible(
          child: RotatedBox(
            quarterTurns: -1,
            child: Slider(
              value: currentValue,
              onChanged: interactive
                  ? (newValue) {
                      ref.watch(valueProvider.notifier).state = newValue;
                    }
                  : null,
              onChangeEnd: interactive ? onChanged : null,
              activeColor: SkyleTheme.of(context).primaryColor,
              inactiveColor: Colors.grey.shade900,
              thumbColor: SkyleTheme.of(context).primaryColor,
            ),
          ),
        ),
        SizedBox(
          width: size,
          height: size,
          child: GazeButton(
            properties: GazeButtonProperties(
              route: route,
              icon: Icon(
                Icons.arrow_downward,
                color: SkyleTheme.of(context).primaryColor,
              ),
              borderColor: SkyleTheme.of(context).primaryColor,
              horizontal: true,
              gazeInteractive: interactive,
              innerPadding: const EdgeInsets.all(0),
            ),
            onTap: () {
              double newValue = currentValue - 0.1;
              if (newValue < 0) {
                newValue = 0;
              }
              onChanged(newValue);
            },
          ),
        ),
      ],
    );
  }
}
