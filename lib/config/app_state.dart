//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaze_interactive/gaze_interactive.dart';
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

class AppState {
  // Navigator 2.0 stuff
  final parserProvider = Provider<MainRouteInformationParser>((ref) => MainRouteInformationParser());

  // Provider Navigator 2.0
  late final routerDelegateProvider = Provider<MainRouterDelegate>((ref) => MainRouterDelegate(ref: ref));

  final navigatorProvider = StateNotifierProvider<MainNavigatorStateNotifier, List<RouteState>>((ref) => MainNavigatorStateNotifier());

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
        if (versions is skyle.DataSuccess) ret = await repository.tryCheckForUpdate(versions.data!.firmware, versions.data!.serial, beta: beta);
      } catch (e) {
        ret = skyle.DataFailed<UpdateResponse>(e.toString());
      }
    }
    if (stopwatch.elapsed.inMilliseconds < minTimeInMilliseconds) {
      await Future.delayed(Duration(milliseconds: minTimeInMilliseconds - stopwatch.elapsed.inMilliseconds));
    }
    return ret;
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

  final GazeInteractive gazeInteractive = GazeInteractive();

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

  Future<void> init() async {
    connectionStreamSubscription = et.connectionStream.listen((connection) {
      if (connection == skyle.Connection.connected) {
        _startGazeStream();
        _startPositioningStream();
      } else {
        _stopGazeStream();
        _stopPositioningStream();
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

  Future<void> _startGazeStream() async {
    if (et.connection != skyle.Connection.connected) return;
    gazeStream = et.gaze.start();
    gazeStreamSubscription = gazeStream!.listen((gaze) async {
      if (gaze is skyle.DataSuccess) {
        gazeInteractive.onGaze(Offset(gaze.data!.x, gaze.data!.y));
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
}
