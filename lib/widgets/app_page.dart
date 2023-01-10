//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:gaze_interactive/api.dart';

import '../../util/responsive.dart';
import '../config/routes/routes.dart';
import '../ui/main/theme.dart';

class AppPage extends StatelessWidget {
  final Widget child;
  final String? title;
  final void Function()? onTap;
  final Widget? helpPage;
  final bool gazeInteractive;
  final String route;

  const AppPage({
    Key? key,
    this.title,
    required this.child,
    this.onTap,
    this.helpPage,
    this.gazeInteractive = true,
    required this.route,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: Responsive.padding(context, const EdgeInsets.all(20)),
                child: GazeButton(
                  properties: GazeButtonProperties(
                    innerPadding: Responsive.padding(context, const EdgeInsets.fromLTRB(20, 20, 100, 20)),
                    text: 'back',
                    textColor: Colors.blue,
                    horizontal: true,
                    icon: Icon(
                      Icons.chevron_left,
                      color: Colors.blue,
                      size: Responsive.getResponsiveValue(forLargeScreen: 35, forMediumScreen: 20, context: context),
                    ),
                    gazeInteractive: gazeInteractive,
                    route: route,
                  ),
                  onTap: onTap ?? Routes.back,
                ),
              ),
              if (title != null)
                Text(
                  title!,
                  style: SkyleTheme.of(context).primaryTextTheme.headline1,
                ),
              Opacity(
                opacity: helpPage != null ? 1.0 : 0.0,
                child: Padding(
                  padding: Responsive.padding(context, const EdgeInsets.fromLTRB(0, 20, 200, 0)),
                  child: GazeButton(
                    properties: GazeButtonProperties(
                      icon: Icon(
                        Icons.help,
                        color: Colors.white,
                        size: Responsive.getResponsiveValue(forLargeScreen: 35, forMediumScreen: 20, context: context),
                      ),
                      backgroundColor: SkyleTheme.of(context).primaryColor,
                      horizontal: true,
                      borderRadius: BorderRadius.circular(100),
                      route: route,
                    ),
                    onTap: helpPage != null
                        ? () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppPage(
                                  title: 'Help',
                                  route: '$route/help',
                                  child: helpPage!,
                                ),
                              ),
                            );
                            // await Get.to(
                            //   () => SkylePage(
                            //     title: 'Help',
                            //     id: id,
                            //     child: helpPage!,
                            //   ),
                            // );
                          }
                        : null,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}
