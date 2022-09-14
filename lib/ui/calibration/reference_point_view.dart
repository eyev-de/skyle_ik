//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:skyle_api/api.dart';

import '../calibration/star_view.dart';

class ReferencePointView extends StatelessWidget {
  final Point point;
  final int index;
  final CalibrationQualityMessage message;

  static const double width = 320;
  static const double height = 320;

  const ReferencePointView({
    Key? key,
    required this.point,
    required this.index,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: point.x - width / 2.0,
      top: point.y - height / 2.0,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade100,
                    width: 20,
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: _calculateEdgeInsets(index, message.quality!.qualities.length),
                child: StarView(
                  quality: message.quality!.qualities[index].quality,
                  point: point,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  EdgeInsets _calculateEdgeInsets(int index, int lenght) {
    final pts = CalibrationPoints.fromInt(lenght);
    final id = pts.array[index];
    switch (id) {
      case 0:
        return const EdgeInsets.only(top: 100, left: 200);
      case 1:
        return const EdgeInsets.only(top: 100);
      case 2:
        return const EdgeInsets.only(top: 100, right: 200);
      case 3:
        return const EdgeInsets.only(left: 200);
      case 4:
        return const EdgeInsets.only(top: 100);
      case 5:
        return const EdgeInsets.only(right: 200);
      case 6:
        return const EdgeInsets.only(bottom: 100, left: 200);
      case 7:
        return const EdgeInsets.only(bottom: 100);
      case 8:
        return const EdgeInsets.only(bottom: 100, right: 200);
    }
    return const EdgeInsets.all(0);
  }
}
