//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:async/async.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaze_interactive/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skyle_api/api.dart' as skyle;

import '../config/routes/main_navigator_state.dart';
import '../config/routes/main_route_information_parser.dart';
import '../config/routes/main_router_delegate.dart';
import '../config/routes/route_state.dart';
import '../data/models/update/release_notes_response.dart';
import '../data/models/update/update_response.dart';
import '../data/models/update/update_state.dart';
import '../data/repositories/update_repository_impl.dart';
import '../domain/repositories/update_repository.dart';
import 'local_settings_notifiers.dart';
import 'positioning_type_notifier.dart';

enum SkyleType {
  skyleIntegrationKit(50051),
  skyleForIpad(50052);

  final int port;
  const SkyleType(this.port);
}

enum SkyleVersion {
  skyle1(1),
  skyle2(2),
  skyle3(3);

  final int version;
  const SkyleVersion(this.version);
}

class AppState {
  // Navigator 2.0 stuff
  final parserProvider = Provider<MainRouteInformationParser>((ref) => MainRouteInformationParser());

  // Provider Navigator 2.0
  late final routerDelegateProvider = Provider<MainRouterDelegate>((ref) => MainRouterDelegate(ref: ref));

  final navigatorProvider = StateNotifierProvider<MainNavigatorStateNotifier, List<RouteState>>((ref) => MainNavigatorStateNotifier());

  // Skyle Type stuff
  final skyleTypeProvider = StateProvider((ref) => SkyleType.skyleIntegrationKit);
  late final skyleVersionProvider = FutureProvider.autoDispose((ref) {
    ref.keepAlive();
    final versions = ref.watch(versionsProvider);
    if (versions.value is skyle.DataSuccess && versions.value != null && versions.value!.data != null) {
      if (versions.value!.data!.skyleType.toString().startsWith("3")) {
        return SkyleVersion.skyle3;
      } else {
        return SkyleVersion.skyle2;
      }
    }
  });

  // Skyle API oject
  final skyle.ET et = skyle.ET();

  // Skyle API provider
  late final connectionProvider = StreamProvider.autoDispose((ref) {
    return et.connectionStream;
  });

  late final settingsProvider = FutureProvider.autoDispose((ref) async {
    ref.keepAlive();
    await ref.watch(AppState().connectionProvider.future);
    return et.settings.get();
  });

  late final versionsProvider = FutureProvider.autoDispose((ref) async {
    ref.keepAlive();
    await ref.watch(AppState().connectionProvider.future);
    return et.versions.get();
  });

  late final gazeStreamProvider = StreamProvider((ref) => gazeStreamController.stream);

  late final positioningStreamProvider = StreamProvider(
    (ref) {
      return positioningStreamController.stream;
    },
  );

  late final positioningTypeProvider = StateNotifierProvider<PositioningTypeNotifier, PositioningType>((ref) {
    return PositioningTypeNotifier();
  });

  late final videoStreamProvider = StreamProvider((ref) {
    return videoStreamController.stream;
  });

  late final switchSettingsProvider = StreamProvider.autoDispose((ref) {
    ref
      ..onDispose(et.switchSettings.stop)
      ..keepAlive();
    return et.switchSettings.start();
  });

  late final SharedPreferences sharedPreferences;

  final calibrationPointsProvider = StateNotifierProvider<CalibrationPointsLocalNotifier, skyle.CalibrationPoints>((ref) {
    return CalibrationPointsLocalNotifier();
  });

  final updateRepositoryProvider = Provider<UpdateRepository>((ref) => UpdateRepositoryImpl());

  // This provider always takes at least 500 milliseconds to provide a value.
  // This is for animation purposes.
  final checkForUpdateProvider = FutureProvider.autoDispose.family<skyle.DataState<UpdateResponse>, bool>((ref, beta) async {
    ref.keepAlive();
    const int minTimeInMilliseconds = 500;
    final stopwatch = Stopwatch()..start();
    skyle.DataState<UpdateResponse> ret = const skyle.DataFailed<UpdateResponse>('checkForUpdateProvider error: Skyle is not connected.');
    final connection = await ref.watch(AppState().connectionProvider.future);
    final repository = ref.watch(AppState().updateRepositoryProvider);
    if (connection == skyle.Connection.connected) {
      try {
        final versions = await ref.watch(AppState().versionsProvider.future);
        final version = versions.data!.firmware;
        final serial = versions.data!.serial;

        if (versions is skyle.DataSuccess) ret = await repository.tryCheckForUpdate(version, serial, beta: beta);
      } catch (e) {
        ret = skyle.DataFailed<UpdateResponse>(e.toString());
      }
    }
    if (stopwatch.elapsed.inMilliseconds < minTimeInMilliseconds) {
      await Future.delayed(Duration(milliseconds: minTimeInMilliseconds - stopwatch.elapsed.inMilliseconds));
    }
    return ret;
  });

  final uploadUpdateTriggerProvider = StateProvider((ref) {
    return false;
  });

  final updatingStateProvider = StateProvider((ref) {
    return UpdateState.none;
  });

  late final downloadUpdateProvider = StreamProvider.autoDispose((ref) async* {
    ref.keepAlive();
    final connection = await ref.read(AppState().connectionProvider.future);
    final repository = ref.read(AppState().updateRepositoryProvider);
    final beta = ref.read(AppState().betaFirmwareProvider);
    if (connection == skyle.Connection.connected) {
      try {
        final versions = await ref.read(AppState().versionsProvider.future);
        ref.read(updatingStateProvider.notifier).state = UpdateState.downloading;
        if (versions is skyle.DataSuccess) yield* repository.tryDownloadUpdate(versions.data!.firmware, versions.data!.serial, beta: beta);
      } catch (e) {
        // skyleLogger?.i(e.toString());
      }
    }
  });

  late final uploadUpdateProvider = StreamProvider.autoDispose<skyle.DataState<UpdateState>>((ref) async* {
    ref.keepAlive();
    if (ref.watch(uploadUpdateTriggerProvider)) {
      try {
        ref.read(updatingStateProvider.notifier).state = UpdateState.uploading;
        yield* ref.watch(AppState().updateRepositoryProvider).tryUpdate();
      } catch (e) {
        // skyleLogger?.i(e.toString());
        yield skyle.DataFailed(e.toString());
      }
    }
  });

  late final combinedDownloadingAndUploadingUpdateProvider = StreamProvider.autoDispose<skyle.DataState<UpdateState>>((ref) async* {
    final downloadStream = ref.watch(downloadUpdateProvider.stream);
    final uploadStream = ref.watch(uploadUpdateProvider.stream);
    yield* StreamGroup.merge([downloadStream, uploadStream]);
  });

  late final updatingProvider = StreamProvider.autoDispose<skyle.DataState<UpdateState>>((ref) async* {
    final connection = await ref.watch(AppState().connectionProvider.future);
    if (connection == skyle.Connection.connecting) return;
    if (ref.read(updatingStateProvider) == UpdateState.uploaded && connection == skyle.Connection.disconnected) {
      yield const skyle.DataSuccess(UpdateState.updating);
      ref.read(updatingStateProvider.notifier).state = UpdateState.updating;
      return;
    }
    if (ref.read(updatingStateProvider) == UpdateState.updating && connection == skyle.Connection.connected) {
      yield const skyle.DataSuccess(UpdateState.finished);
      ref.read(updatingStateProvider.notifier).state = UpdateState.none;
      return;
    }
    final updatingStateStream = ref.watch(combinedDownloadingAndUploadingUpdateProvider.stream);
    await for (final updatingState in updatingStateStream) {
      if (updatingState is skyle.DataSuccess) ref.read(updatingStateProvider.notifier).state = updatingState.data!;
      yield updatingState;
    }
  });

  late final newVersionProvider = FutureProvider.autoDispose<skyle.DataState<UpdateResponse>>((ref) async {
    final connection = await ref.watch(AppState().connectionProvider.future);
    if (connection == skyle.Connection.connecting) return const skyle.DataFailed('Not connected');
    final repository = ref.read(AppState().updateRepositoryProvider);
    final versions = await ref.watch(AppState().versionsProvider.future);
    final beta = ref.read(AppState().betaFirmwareProvider);
    if (versions is skyle.DataFailed) return skyle.DataFailed('${versions.error}');
    return repository.tryCheckForUpdate(versions.data!.firmware, versions.data!.serial, beta: beta);
  });

  final releaseNotesProvider = FutureProvider.autoDispose.family<skyle.DataState<ReleaseNotesResponse>?, bool>((ref, beta) async {
    ref.keepAlive();
    final connection = await ref.watch(AppState().connectionProvider.future);
    final repository = ref.watch(AppState().updateRepositoryProvider);
    if (connection == skyle.Connection.connected) {
      try {
        final update = await ref.watch(AppState().checkForUpdateProvider(beta).future);
        final versions = await ref.watch(AppState().versionsProvider.future);
        if (update is skyle.DataSuccess && versions is skyle.DataSuccess) return repository.getReleaseNotes(update.data!.version, versions.data!.serial);
      } catch (e) {
        // skyleLogger?.i(e.toString());
      }
    }
    return null;
  });

  final isBetaProvider = FutureProvider.autoDispose<skyle.DataState<bool>>((ref) async {
    final connection = await ref.watch(AppState().connectionProvider.future);
    try {
      if (connection == skyle.Connection.connected) {
        final versions = await ref.watch(AppState().versionsProvider.future);
        if (versions is skyle.DataSuccess) {
          return ref.watch(AppState().updateRepositoryProvider).isBeta(versions.data!.serial);
        }
        return const skyle.DataFailed('Error checking if Skyle isBeta device.');
      }
      return const skyle.DataFailed('Error checking if Skyle isBeta device: Device disconnected');
    } catch (e) {
      return skyle.DataFailed('Error checking if Skyle isBeta device: ${e.toString()}');
    }
  });

  final betaFirmwareProvider = StateNotifierProvider<BetaFirmwareLocalNotifier, bool>((ref) {
    return BetaFirmwareLocalNotifier();
  });

  static final AppState _instance = AppState._internal();

  factory AppState() {
    return _instance;
  }
  AppState._internal() {
    init();
  }

  StreamSubscription<skyle.Connection>? connectionStreamSubscription;

  Stream<skyle.DataState<skyle.Point>>? gazeStream;
  StreamController<Offset> gazeStreamController = StreamController();
  StreamSubscription<skyle.DataState<skyle.Point>>? gazeStreamSubscription;

  Stream<skyle.DataState<skyle.PositioningMessage>>? positioningStream;
  StreamController<skyle.DataState<skyle.PositioningMessage>> positioningStreamController = StreamController();
  StreamSubscription<skyle.DataState<skyle.PositioningMessage>>? positioningStreamSubscription;

  Stream<skyle.DataState<skyle.RawImage>>? videoStream;
  StreamController<skyle.DataState<skyle.RawImage>> videoStreamController = StreamController();
  StreamSubscription<skyle.DataState<skyle.RawImage>>? videoStreamSubscription;

  Future<void> init() async {
    connectionStreamSubscription = et.connectionStream.listen((connection) {
      if (connection == skyle.Connection.connected) {
        _startGazeStream();
        _startPositioningStream();
        _startVideoStream();
      } else {
        _stopGazeStream();
        _stopPositioningStream();
        _stopVideoStream();
      }
    });
  }

  Future<void> dispose() async {
    await connectionStreamSubscription?.cancel();
  }

  Future<void> _stopGazeStream() async {
    await gazeStreamSubscription?.cancel();
    await et.gaze.stop();
  }

  Future<void> _stopPositioningStream() async {
    await positioningStreamSubscription?.cancel();
    await et.positioning.stop();
  }

  Future<void> _stopVideoStream() async {
    await videoStreamSubscription?.cancel();
    await et.video.stop();
  }

  Future<void> _startGazeStream() async {
    if (et.connection != skyle.Connection.connected) return;
    gazeStream = et.gaze.start();
    gazeStreamSubscription = gazeStream!.listen((gaze) async {
      if (gaze is skyle.DataSuccess) {
        GazeInteractive().onGaze(Offset(gaze.data!.x, gaze.data!.y));
        gazeStreamController.add(Offset(gaze.data!.x, gaze.data!.y));
      } else if (gaze is skyle.DataFailed) {
        await _stopGazeStream();
        await Future.delayed(const Duration(milliseconds: 500));
        await _startGazeStream();
      }
    });
  }

  Future<void> _startPositioningStream() async {
    if (et.connection != skyle.Connection.connected) return;
    positioningStream = et.positioning.start();
    positioningStreamSubscription = positioningStream?.listen((positioning) async {
      if (positioning is skyle.DataFailed) {
        await _stopPositioningStream();
        await Future.delayed(const Duration(milliseconds: 500));
        await _startPositioningStream();
      } else if (positioning is skyle.DataSuccess) {
        positioningStreamController.add(positioning);
      }
    });
  }

  Future<void> _startVideoStream() async {
    if (et.connection != skyle.Connection.connected) return;
    videoStream = et.video.start();
    videoStreamSubscription = videoStream?.listen((video) async {
      if (video is skyle.DataFailed) {
        await _stopVideoStream();
        await Future.delayed(const Duration(milliseconds: 500));
        await _startVideoStream();
      } else if (video is skyle.DataSuccess) {
        videoStreamController.add(video);
      }
    });
  }
}
