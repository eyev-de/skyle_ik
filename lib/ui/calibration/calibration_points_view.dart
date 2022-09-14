//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';

import '../../util/responsive.dart';

class CalibrationPointsView extends StatelessWidget {
  final List<int> points;
  final Color color;

  const CalibrationPointsView({Key? key, required this.points, this.color = Colors.yellow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var maxWidth = constraints.maxHeight * 16 / 9;
      if (maxWidth > constraints.maxWidth) maxWidth = constraints.maxWidth;
      var maxHeight = constraints.maxWidth * 9 / 16;
      if (maxHeight > constraints.maxHeight) maxHeight = constraints.maxHeight;
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight, maxWidth: maxWidth),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (var j = i * 3; j < 3 + i * 3; j++)
                      CalibrationPointView(
                        id: j,
                        ids: points,
                        color: color,
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

class CalibrationPointView extends StatelessWidget {
  final int id;
  final List<int> ids;
  final Color color;

  const CalibrationPointView({Key? key, required this.id, required this.ids, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: ids.contains(id) ? 1.0 : 0.0,
      child: Container(
        // padding: EdgeInsets.fromLTRB(50, 50, 50, 50),
        width: Responsive.getResponsiveValue(forLargeScreen: 10, forMediumScreen: 7, context: context),
        height: Responsive.getResponsiveValue(forLargeScreen: 10, forMediumScreen: 7, context: context),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
