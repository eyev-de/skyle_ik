//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skyle_api/api.dart';

import '../../util/responsive.dart';
import 'theme.dart';

class LogoTabbar extends StatelessWidget {
  final Connection connection;
  const LogoTabbar({Key? key, required this.connection}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double size = Responsive.getResponsiveValue(forLargeScreen: 106, forMediumScreen: 86, context: context);
    return Container(
      padding: Responsive.padding(context, const EdgeInsets.fromLTRB(0, 40, 0, 40)),
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: connection == Connection.connected
                  ? SkyleTheme.of(context).primaryColor
                  : connection == Connection.connecting
                      ? Colors.yellow
                      : Colors.red,
            ),
          ),
          Container(
            width: size - 6,
            height: size - 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.shade900,
            ),
          ),
          SvgPicture.asset(
            'assets/images/SkyleEye.svg',
            width: size,
            height: size,
          )
        ],
      ),
    );
  }
}
