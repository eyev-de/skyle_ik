//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:skyle_api/api.dart';

// import '../../../state/logger.dart';
import '../../../util/file_handler.dart';
import '../../../util/multipartrequest.dart';
import '../../config/configuration.dart';
import '../../domain/repositories/update_repository.dart';
import '../models/update/release_notes_response.dart';
import '../models/update/update_request.dart';
import '../models/update/update_response.dart';
import '../models/update/update_state.dart';

class UpdateRepositoryImpl implements UpdateRepository {
  @override
  Future<DataState<ReleaseNotesResponse>> getReleaseNotes(String version, BigInt serial, {String url = Configuration.releaseNotesURL}) async {
    final String _url = '$url?serial=$serial&version=$version';
    try {
      final response = await http.get(Uri.parse(_url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> map = jsonDecode(response.body);
        final notes = ReleaseNotesResponse.fromJson(map);
        if (notes.notes != '' && notes.version != '') return DataSuccess(notes);
        throw Exception('Release Notes Empty');
      }
      throw Exception('Getting release notes returned status code ${response.statusCode}.');
    } catch (error) {
      // skyleLogger?.e('getReleaseNotes failed: ', error, StackTrace.current);
      return DataFailed(error.toString());
    }
  }

  @override
  Future<DataState<bool>> isBeta(BigInt serial, {String url = Configuration.isBetaDeviceURL}) async {
    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'serial': serial.toString(),
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> map = jsonDecode(response.body);
        if (map['beta']) {
          return const DataSuccess(true);
        } else {
          return const DataSuccess(false);
        }
      }
      return DataFailed('Checking if ET is a beta device failed: status code ${response.statusCode.toString()}');
    } catch (error) {
      // skyleLogger?.e('isBeta failed: ', error, StackTrace.current);
      return DataFailed('Checking if ET is a beta device failed: ${error.toString()}');
    }
  }

  @override
  Stream<DataState<UpdateState>> tryDownloadUpdate(
    String version,
    BigInt serial, {
    String url = Configuration.updateURL,
    String directory = Configuration.updateBaseDirectory,
    bool beta = false,
  }) async* {
    try {
      final DataState<UpdateResponse> result = await tryCheckForUpdate(
        version,
        serial,
        beta: beta,
        url: url,
      );
      if (result is DataFailed) {
        yield DataFailed(result.error!);
        return;
      }
      final response = result.data!;
      // skyleLogger?.i('Downloading update from ${response.download}');
      if (response.newupdate) {
        yield* _downloadUpdate(version, serial, response.download, directory, 'skyle.fw');
      }
    } catch (error) {
      // skyleLogger?.e('tryDownloadUpdate failed: ', error, StackTrace.current);
      yield DataFailed(error.toString());
    }
  }

  @override
  Stream<DataState<UpdateState>> tryUpdate({
    String url = Configuration.updateDestinationURL,
    String directory = Configuration.updateBaseDirectory,
    String fileName = 'skyle.fw',
  }) async* {
    try {
      final progressStream = StreamController<DataState<UpdateState>>();
      final request = MultipartRequest('POST', Uri.parse(url), onProgress: (cumulative, total) async {
        final value = cumulative / total;
        if (value == 1.0) {
          progressStream
            ..add(const DataLoading(1))
            ..add(const DataSuccess(UpdateState.uploaded));
          // ..add(const DataSuccess(UpdateState.updating));
          // skyleLogger?.i('Finished uploading update.');
          await progressStream.close();
        } else {
          progressStream.add(DataLoading(value));
        }
      });
      late final String dir;
      try {
        final applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
        dir = applicationDocumentsDirectory.path;
      } catch (_) {
        dir = './';
      }
      final String filePath = p.join(dir, directory, fileName);
      yield const DataSuccess(UpdateState.uploading);

      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      // skyleLogger?.i('Uploading update from $filePath to $url');

      final response = await request.send();

      if (response.statusCode != 200) {
        throw HttpException('MultipartRequest faild: status code: ${response.statusCode}');
      }
      yield* progressStream.stream;
    } catch (error) {
      // skyleLogger?.e('Error uploading update.', error, StackTrace.current);
      yield DataFailed(error.toString());
    }
  }

  @override
  Future<DataState<UpdateResponse>> tryCheckForUpdate(String version, BigInt serial, {bool beta = false, String url = Configuration.updateURL}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(UpdateRequest(version: version, serial: serial, beta: beta).toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> map = jsonDecode(response.body);
        return DataSuccess(UpdateResponse.fromJson(map));
      }
      return DataFailed('Server returned: ${response.statusCode}');
    } catch (error) {
      // skyleLogger?.e('tryCheckForUpdate failed: ', error, StackTrace.current);
      return DataFailed(error.toString());
    }
  }

  static Stream<DataState<UpdateState>> _downloadUpdate(String version, BigInt serial, String url, String directory, String fileName) async* {
    try {
      late final String dir;
      try {
        final applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
        dir = applicationDocumentsDirectory.path;
      } catch (_) {
        dir = './';
      }
      final _directory = p.join(dir, directory);
      if (!Directory(_directory).existsSync()) await Directory(_directory).create(recursive: true);

      final String filePath = p.join(_directory, fileName);
      final progressStream = StreamController<DataState<UpdateState>>();
      unawaited(FileHandler.download(
        url: url,
        path: filePath,
        state: (_s) async {
          if (_s == FileState.downloaded) {
            progressStream
              ..add(const DataLoading(1))
              ..add(const DataSuccess(UpdateState.downloaded));
            // skyleLogger?.i('Finished downloading file $filePath from $url');
            await progressStream.close();
          } else if (_s == FileState.failed) {
            if (!progressStream.isClosed) progressStream.add(const DataFailed('Error in FilesHandler'));
          } else if (_s == FileState.downloading) {
            progressStream.add(const DataSuccess(UpdateState.downloading));
          }
        },
        progress: (value) async {
          if (!progressStream.isClosed) progressStream.add(DataLoading(value));
        },
        speedInMBPS: (value) {
          //mbPerSecond = value;
        },
      ));
      yield* progressStream.stream;
    } catch (error) {
      // skyleLogger?.e('_downloadUpdate failed: ', error, StackTrace.current);
      yield DataFailed(error.toString());
    }
  }
}
