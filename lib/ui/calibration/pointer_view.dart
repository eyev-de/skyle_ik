//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PointerView extends ConsumerWidget {
  final bool visible;
  final Animation<double> animation;
  const PointerView({
    Key? key,
    required this.visible,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double size = 10;
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 100),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ScaleTransition(
            scale: animation,
            filterQuality: FilterQuality.high,
            child: const _PointerStyle(
              size: size,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointerStyle extends ConsumerWidget {
  final double size;
  const _PointerStyle({required this.size});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.yellow,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
