//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:gaze_interactive/api.dart';

import '../main/theme.dart';

class LogoButton extends StatelessWidget {
  final bool visible;
  final void Function() onTap;
  final String route;

  const LogoButton({Key? key, required this.visible, required this.onTap, required this.route}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/SkyleLogoBright/SkyleLogoBright.png'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'calibration',
                      style: SkyleTheme.of(context).primaryTextTheme.bodyText1,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: 300,
              height: 100,
              child: GazeButton(
                properties: GazeButtonProperties(
                  text: 'Done',
                  backgroundColor: SkyleTheme.of(context).primaryColor,
                  gazeInteractive: visible,
                  route: route,
                ),
                onTap: visible ? onTap : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
