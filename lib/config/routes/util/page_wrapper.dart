//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';

class PageWrapper extends Page {
  final Widget child;
  final bool animated;

  PageWrapper({LocalKey? key, required this.child, this.animated = true}) : super(key: key ?? UniqueKey());

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) =>
          Container(color: Colors.black, child: child),
      transitionsBuilder: (
        context,
        animation,
        secondaryAnimation,
        child,
      ) {
        if (!animated) return child;
        const begin = Offset(1, 0);
        const end = Offset.zero;
        const curve = Curves.ease;
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: Container(
            color: Colors.black,
            child: child,
          ),
        );
      },
    );
  }
}
