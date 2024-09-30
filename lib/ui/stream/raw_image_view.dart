//  Skyle
//
//  Created by the eyeV app dev team.
//  Copyright © 2023 eyeV GmbH. All rights reserved.
//

import 'dart:typed_data';

import 'package:bitmap/bitmap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_state.dart';

class RawImageView extends ConsumerWidget {
  const RawImageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(AppState().videoStreamProvider);
    return image.when(
      data: (data) {
        if (data.data == null) return Container();
        return Image.memory(
          transformGRAYRawToRGBABitmap(Uint8List.fromList(data.data!.data), data.data!.width, data.data!.height),
          scale: 0.5,
          gaplessPlayback: true,
        );
      },
      error: (error, stackTrace) => Text(error.toString()),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  static Uint8List transformBGRRAWToRGBABitmap(Uint8List bgrImage, int width, int height) {
    final pixelCount = width * height;
    final Uint8List rgbaImage = Uint8List(pixelCount * 4);
    for (int i = 0; i < pixelCount; i++) {
      final int bgrIndex = i * 3;
      final int rgbaIndex = i * 4;

      // Extract BGR values
      final int blue = bgrImage[bgrIndex];
      final int green = bgrImage[bgrIndex + 1];
      final int red = bgrImage[bgrIndex + 2];

      // Assign RGBA values
      rgbaImage[rgbaIndex] = red;
      rgbaImage[rgbaIndex + 1] = green;
      rgbaImage[rgbaIndex + 2] = blue;
      rgbaImage[rgbaIndex + 3] = 255; // Full opacity
    }
    final bitmap = Bitmap.fromHeadless(width, height, rgbaImage);
    final uint8List = bitmap.buildHeaded();

    return uint8List;
  }

  static Uint8List transformGRAYRawToRGBABitmap(Uint8List grayImage, int width, int height) {
    final pixelCount = width * height;
    final Uint8List rgbaImage = Uint8List(pixelCount * 4);
    for (int i = 0; i < pixelCount; i++) {
      final int rgbaIndex = i * 4;

      rgbaImage[rgbaIndex] = grayImage[i];
      rgbaImage[rgbaIndex + 1] = grayImage[i];
      rgbaImage[rgbaIndex + 2] = grayImage[i];
      rgbaImage[rgbaIndex + 3] = 255; // Full opacity
    }
    final bitmap = Bitmap.fromHeadless(width, height, rgbaImage);
    final uint8List = bitmap.buildHeaded();

    return uint8List;
  }
}
