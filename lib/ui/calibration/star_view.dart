//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:skyle_api/api.dart';

class StarView extends StatelessWidget {
  final double quality;
  final Point point;

  const StarView({Key? key, required this.quality, required this.point}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double rest = quality - quality.floor();
    final int empty = 5 - quality.round();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < quality.floor(); i++)
          const Icon(
            Icons.star_rounded,
            color: Colors.yellow,
          ),
        if (rest >= 0.5)
          const Icon(
            Icons.star_half_rounded,
            color: Colors.yellow,
          ),
        for (var i = 0; i < empty; i++)
          const Icon(
            Icons.star_outline_rounded,
            color: Colors.yellow,
          ),
      ],
    );
  }
}
