//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:skyle_api/api.dart';

import '../../util/extensions.dart';
import '../calibration/reference_point_view.dart';

class ReferencePointsView extends StatelessWidget {
  final bool visible;
  final List<Point> points;
  final CalibrationQualityMessage message;

  const ReferencePointsView({
    Key? key,
    required this.visible,
    required this.points,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: visible ? 1.0 : 0.0,
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(),
              ),
            ],
          ),
          if (visible)
            for (var widget in points.mapIndexed((point, index) {
              if (message.quality!.qualities.asMap().containsKey(index)) {
                return ReferencePointView(
                  point: point,
                  index: index,
                  message: message,
                );
              }
              return Container();
            }))
              widget,
        ],
      ),
    );
  }
}
