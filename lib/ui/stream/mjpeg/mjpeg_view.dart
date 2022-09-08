//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skyle_api/api.dart';
import 'package:skyle_ik/config/positioning_type_notifier.dart';

import '../../../config/configuration.dart';
import '../../../config/app_state.dart';
import '../../main/theme.dart';

class MjpegView extends ConsumerStatefulWidget {
  final BoxFit? fit;
  final double? width;
  final double? height;
  final WidgetBuilder? loading;
  final Widget Function(BuildContext context, Exception? error)? error;

  const MjpegView({
    Key? key,
    this.width,
    this.height,
    this.fit,
    this.error,
    this.loading,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MjpegViewState();
}

class _MjpegViewState extends ConsumerState<MjpegView> {
  late final streamProvider = StreamProvider(
    (ref) async* {
      final positioningType = ref.watch(AppState().positioningTypeProvider);
      if (positioningType == PositioningType.video) {
        await for (final image in AppState().et.stream.request(url: Configuration.mjpegURL)) {
          if (image is DataSuccess) {
            final memoryImage = MemoryImage(Uint8List.fromList(image.data!));
            if (mounted) {
              await precacheImage(memoryImage, context);
            }
            yield memoryImage;
          }
        }
      }
    },
  );

  @override
  Future<void> dispose() async {
    super.dispose();
    await AppState().et.stream.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final streamData = ref.watch(streamProvider);
    return streamData.when(data: (image) {
      return Image(
        image: image,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }, error: (error, __) {
      print('Error in mjpeg stream. $error');
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: _error(context, error),
      );
    }, loading: () {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: widget.loading != null
            ? widget.loading!(context)
            : Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(SkyleTheme.of(context).primaryColor),
                ),
              ),
      );
    });
  }

  Widget _error(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          error.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
