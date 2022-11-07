//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gaze_interactive/gaze_interactive.dart';
import 'package:skyle_api/api.dart';

import '../../config/app_state.dart';
import '../../config/routes/main_routes.dart';
import '../../config/routes/routes.dart';
import '../../config/theme/app_theme.dart';
import '../../data/models/update/release_notes_response.dart';
import '../../data/models/update/update_response.dart';
import '../../data/models/update/update_state.dart';
import '../../util/responsive.dart';
import 'beta_switch.dart';

class SearchForFirmwareUpdateButton extends ConsumerWidget {
  const SearchForFirmwareUpdateButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final beta = ref.watch(AppState().betaFirmwareProvider);
    final update = ref.watch(AppState().checkForUpdateProvider(beta));
    return Flexible(
      child: Padding(
        padding: Responsive.padding(context, const EdgeInsets.all(20)),
        child: update.isRefreshing
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                    ],
                  ),
                ],
              )
            : update.when(
                data: (data) => _button(data, ref),
                error: (error, st) => _button(DataFailed(error.toString()), ref),
                loading: () => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _button(DataState<UpdateResponse> data, WidgetRef ref) {
    return Builder(
      builder: (context) => GazeButton(
        properties: GazeButtonProperties(
          key: GlobalKey(),
          text: data is DataSuccess && data.data!.newupdate ? 'Update firmware' : 'Search for firmware update',
          textStyle: const TextStyle(color: Colors.white, fontSize: 11),
          icon: Icon(
            Icons.upgrade,
            color: Colors.white,
            size: Responsive.getResponsiveValue(forLargeScreen: 35, forMediumScreen: 20, context: context),
          ),
          innerPadding: const EdgeInsets.only(left: 10, right: 10),
          route: MainRoutes.home.path,
        ),
        onTap: () async {
          if (data is DataSuccess && data.data!.newupdate) {
            await showUpdateInstallDialog(context);
          } else {
            final beta = ref.read(AppState().betaFirmwareProvider);
            ref.refresh(AppState().checkForUpdateProvider(beta));
          }
        },
      ),
    );
  }

  static Future<void> showUpdateInstallDialog(BuildContext context) {
    final uploadUpdateTriggerProvider = StateProvider((ref) {
      return false;
    });

    final updatingStateProvider = StateProvider((ref) {
      return UpdateState.none;
    });

    final downloadUpdateProvider = StreamProvider.autoDispose((ref) async* {
      ref.keepAlive();
      final connection = await ref.read(AppState().connectionProvider.future);
      final repository = ref.read(AppState().updateRepositoryProvider);
      final beta = ref.read(AppState().betaFirmwareProvider);
      if (connection == Connection.connected) {
        try {
          final versions = await ref.read(AppState().versionsProvider.future);
          ref.read(updatingStateProvider.notifier).state = UpdateState.downloading;
          if (versions is DataSuccess) yield* repository.tryDownloadUpdate(versions.data!.firmware, versions.data!.serial, beta: beta);
        } catch (e) {
          // skyleLogger?.i(e.toString());
        }
      }
    });

    late final uploadUpdateProvider = StreamProvider.autoDispose<DataState<UpdateState>>((ref) async* {
      ref.keepAlive();
      if (ref.watch(uploadUpdateTriggerProvider)) {
        try {
          ref.read(updatingStateProvider.notifier).state = UpdateState.uploading;
          yield* ref.watch(AppState().updateRepositoryProvider).tryUpdate();
        } catch (e) {
          // skyleLogger?.i(e.toString());
          yield DataFailed(e.toString());
        }
      }
    });

    late final combinedDownloadingAndUploadingUpdateProvider = StreamProvider.autoDispose<DataState<UpdateState>>((ref) async* {
      final downloadStream = ref.watch(downloadUpdateProvider.stream);
      final uploadStream = ref.watch(uploadUpdateProvider.stream);
      yield* StreamGroup.merge([downloadStream, uploadStream]);
    });

    late final updatingProvider = StreamProvider.autoDispose<DataState<UpdateState>>((ref) async* {
      final connection = await ref.watch(AppState().connectionProvider.future);
      if (connection == Connection.connecting) return;
      if (ref.read(updatingStateProvider) == UpdateState.updating && connection == Connection.connected) {
        yield const DataSuccess(UpdateState.finished);
        ref.read(updatingStateProvider.notifier).state = UpdateState.none;
        return;
      }
      final updatingStateStream = ref.watch(combinedDownloadingAndUploadingUpdateProvider.stream);
      await for (final updatingState in updatingStateStream) {
        if (updatingState is DataSuccess && updatingState.data! == UpdateState.uploaded && connection == Connection.disconnected) {
          yield const DataSuccess(UpdateState.updating);
          ref.read(updatingStateProvider.notifier).state = UpdateState.updating;
          return;
        }
        yield updatingState;
      }
    });

    Routes.dialog();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            // final isBeta = ref.watch(AppState().isBetaProvider).valueOrNull ?? const DataSuccess(false);

            final updatingState = ref.watch(updatingProvider).valueOrNull ?? const DataSuccess(UpdateState.none);

            final downloading = updatingState is DataSuccess && updatingState.data! == UpdateState.downloading ||
                (updatingState is DataLoading && ref.read(updatingStateProvider) == UpdateState.downloading);
            final downloaded = updatingState is DataSuccess && updatingState.data! == UpdateState.downloaded;
            final uploading = updatingState is DataSuccess && updatingState.data! == UpdateState.uploading ||
                (updatingState is DataLoading && ref.read(updatingStateProvider) == UpdateState.uploading);
            final uploaded = updatingState is DataSuccess && updatingState.data! == UpdateState.uploaded;
            final updating = updatingState is DataSuccess && updatingState.data! == UpdateState.updating;
            final finished = updatingState is DataSuccess && updatingState.data! == UpdateState.finished;
            final failed = updatingState is DataFailed;
            // if (updatingState is DataSuccess) print(updatingState.data!);
            // if (updatingState is DataFailed) print(updatingState.error!);
            // if (updatingState is DataLoading) print(updatingState.progress!);
            return AlertDialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              title: const Text('Update Firmware'),
              content: SizedBox(
                width: 500,
                height: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!finished)
                      Expanded(
                        flex: 3,
                        child: _text(updatingState, ref.read(updatingStateProvider) == UpdateState.uploading),
                      ),
                    const Spacer(),
                    if (finished || failed)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(failed ? '' : 'Installed update successfully.'),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Icon(
                                  failed ? Icons.cancel_rounded : Icons.check_circle,
                                  color: failed ? Colors.red : Colors.green,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    if (updating || uploading || uploaded)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(),
                            ],
                          ),
                        ],
                      ),
                    if (downloading || downloaded)
                      _DownloadUploadUpdate(
                        updatingProvider: updatingProvider,
                      ),
                    // if (isBeta is DataSuccess && isBeta.data! && !updating && !uploaded && !uploading && !finished)
                    //   Row(
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       const Text('Receive beta updates?'),
                    //       const Spacer(),
                    //       BetaSwitch(downloadUpdateProvider: downloadUpdateProvider),
                    //     ],
                    //   ),
                    const Spacer(),
                    Padding(
                      padding: Responsive.padding(context, const EdgeInsets.fromLTRB(0, 0, 0, 0)),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: GazeButton(
                              properties: GazeButtonProperties(
                                key: GlobalKey(),
                                text: 'Cancel',
                                textColor: uploading || uploaded || updating || finished ? Colors.grey : Colors.red,
                                route: GazeInteractive().currentRoute,
                                gazeInteractive: !(uploading || uploaded || updating || finished),
                              ),
                              onTap: uploading || uploaded || updating || finished
                                  ? null
                                  : () {
                                      Routes.backOnlyRoute();
                                      Navigator.pop(context);
                                    },
                            ),
                          ),
                          Expanded(
                            child: GazeButton(
                              properties: GazeButtonProperties(
                                key: GlobalKey(),
                                text: finished || failed ? 'Dismiss' : 'Install',
                                textColor: downloaded || finished ? Colors.blue : Colors.grey,
                                gazeInteractive: false,
                                route: GazeInteractive().currentRoute,
                              ),
                              onTap: finished || failed
                                  ? () {
                                      Routes.backOnlyRoute();
                                      Navigator.pop(context);
                                    }
                                  : downloaded
                                      ? () async {
                                          // Trigger Update
                                          ref.read(uploadUpdateTriggerProvider.notifier).state = true;
                                        }
                                      : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _text(DataState<UpdateState> updatingState, bool up) {
    if (updatingState is DataFailed) return const Text('Firmware update failed. Please try again later.');
    if ((updatingState is DataLoading && !up) || updatingState is DataSuccess && updatingState.data! == UpdateState.downloading) {
      return const Text('Firmware update is downloading.');
    }
    if (updatingState is DataSuccess && updatingState.data! == UpdateState.downloaded) {
      return const Text('Firmware update is downloaded and ready to be installed.');
    }
    if ((updatingState is DataLoading && up) || updatingState is DataSuccess && updatingState.data! == UpdateState.uploading) {
      return const Text('Firmware update is uploading to Skyle.');
    }
    if (updatingState is DataSuccess && updatingState.data! == UpdateState.uploaded) {
      return const Text('Firmware update is uploaded, Skyle will reboot. Please do not unplug Skyle or exit the app.');
    }
    if (updatingState is DataSuccess && updatingState.data! == UpdateState.finished) return const Text('');
    if (updatingState is DataSuccess && updatingState.data! == UpdateState.none) return const Text('');
    return const Text('Firmware update is uploaded, Skyle will reboot. Please do not unplug Skyle or exit the app.');
  }
}

class _DownloadUploadUpdate extends ConsumerWidget {
  final AutoDisposeStreamProvider<DataState<UpdateState>> updatingProvider;

  const _DownloadUploadUpdate({Key? key, required this.updatingProvider}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateState = ref.watch(updatingProvider).valueOrNull ?? const DataSuccess(UpdateState.none);
    final isBeta = ref.read(AppState().betaFirmwareProvider);
    final releaseNotes = ref.watch(AppState().releaseNotesProvider(isBeta)).valueOrNull ?? const DataSuccess(ReleaseNotesResponse(notes: '', version: ''));
    if (updateState is DataFailed) {
      return const Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          'Failed downloading update.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    if (updateState is DataLoading || updateState is DataSuccess) {
      String text = '';
      if (updateState is DataSuccess) {
        text = 'Downloaded ${releaseNotes is DataSuccess && releaseNotes.data!.version != '' ? 'version: ${releaseNotes.data!.version}' : ''}';
      }
      if (updateState is DataLoading) {
        text = 'Downloading ${releaseNotes is DataSuccess && releaseNotes.data!.version != '' ? 'version: ${releaseNotes.data!.version}' : ''}';
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                text,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: 3,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double width = 0;
                          if (updateState is DataSuccess && updateState.data! == UpdateState.downloaded) {
                            width = constraints.maxWidth * 1;
                          }
                          if (updateState is DataLoading) {
                            width = constraints.maxWidth * updateState.progress!;
                          }
                          return Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  color: Colors.grey,
                                ),
                              ),
                              AnimatedPositioned(
                                left: 0,
                                height: 3,
                                width: width,
                                duration: const Duration(milliseconds: 100),
                                child: Container(
                                  color: AppTheme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return Container();
  }
}
