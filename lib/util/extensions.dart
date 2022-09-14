//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:universal_platform/universal_platform.dart';

// import 'dart:html';

// void goFullScreen() {
//   document.documentElement.requestFullscreen();
// }

extension ThemeDataExtension on ThemeData {
  EdgeInsets get switchButtonPadding => !kIsWeb
      ? (UniversalPlatform.isMacOS || UniversalPlatform.isWindows || UniversalPlatform.isLinux)
          ? const EdgeInsets.fromLTRB(15, 35, 15, 35)
          : const EdgeInsets.fromLTRB(15, 35, 15, 35)
      : const EdgeInsets.fromLTRB(15, 35, 15, 35);
  EdgeInsets get segmentedPadding => !kIsWeb
      ? (UniversalPlatform.isMacOS || UniversalPlatform.isWindows || UniversalPlatform.isLinux)
          ? const EdgeInsets.fromLTRB(30, 30, 30, 30)
          : const EdgeInsets.fromLTRB(20, 10, 20, 10)
      : const EdgeInsets.fromLTRB(30, 30, 30, 30);
}

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject != null) {
      return renderObject.paintBounds.shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}

extension IterableExtensions<E> on Iterable<E> {
  Iterable<List<E>> chunked(int chunkSize) sync* {
    if (length <= 0) {
      yield [];
      return;
    }
    int skip = 0;
    while (skip < length) {
      final chunk = this.skip(skip).take(chunkSize);
      yield chunk.toList(growable: false);
      skip += chunkSize;
      if (chunk.length < chunkSize) return;
    }
  }
}

T enumFromString<T>(List<T> values, String value) {
  return values.firstWhere((v) => v.toString().split('.')[1] == value, orElse: () => values[0]);
}

extension MediaQueryExtension on MediaQuery {
  static bool isZoomed(BuildContext context) {
    // Zoomed = 1024.0, 768.0
    // Standard = 1366.0, 1024.0
    print('Size of viewport: ${MediaQuery.of(context).size}');
    return MediaQuery.of(context).size == const Size(1024, 768);
  }
}
