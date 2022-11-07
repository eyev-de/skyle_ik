//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// import '../state/logger.dart';
import '../util/multipartrequest.dart';

enum FileState { none, downloading, downloaded, uploading, uploaded, unzipped, failed }

class FileHandler {
  static Future<String> downloadString({
    required String url,
    Map<String, String>? body,
  }) async {
    try {
      final client = http.Client();
      final request = http.Request('POST', Uri.parse(url))
        ..headers.addAll({'Content-Type': 'application/json'})
        ..body = jsonEncode(body);
      final http.StreamedResponse response = await client.send(request);
      final contents = StringBuffer();
      await response.stream.transform(utf8.decoder).forEach(contents.write);
      // skyleLogger?.d(contents.toString());
      return contents.toString();
    } catch (error) {
      // skyleLogger?.e('Error in listen in downloadString.', error, StackTrace.current);
      rethrow;
    }
  }

  static Future<void> download({
    required String url,
    required String path,
    void Function(FileState)? state,
    void Function(double)? progress,
    void Function(double)? speedInMBPS,
  }) async {
    try {
      state?.call(FileState.downloading);
      // skyleLogger?.d(path);
      File file = File(path);
      if (file.existsSync()) file.deleteSync();
      file = await file.create();

      int downloaded = 0;
      final HttpClient client = HttpClient()..connectionTimeout = const Duration(seconds: 5);

      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != 200) {
        throw Exception('Server side failed. ${response.statusCode}');
      }
      final sw = Stopwatch()..start();
      final sink = file.openWrite();
      double lastElapsedSeconds = 0;
      int lastPercentage = 0;
      try {
        await for (final chunk in response) {
          if (response.contentLength > 0) {
            final progressValue = downloaded / response.contentLength;
            final int progressPercentage = (progressValue * 100).round();
            // Only emit progress every 3 Percent to ensure the download
            // speed is not limited by UI updates done in the callback.
            if ((progressPercentage % 3) == 0 && lastPercentage != progressPercentage) {
              lastPercentage = progressPercentage;
              progress?.call(progressValue);
            }
            downloaded += chunk.length;
            final elapsedSeconds = sw.elapsedMilliseconds / 1000;
            final mbPerSecond = (downloaded / (1024 * 1024)) / elapsedSeconds;
            // Only emit speed in MB/s every 0.5 seconds to ensure the download
            // speed is not limited by UI updates done in the callback.
            if ((elapsedSeconds - lastElapsedSeconds) > 0.5) {
              lastElapsedSeconds = elapsedSeconds;
              speedInMBPS?.call(mbPerSecond);
            }
          }
          sink.add(chunk);
        }
      } catch (error) {
        // skyleLogger?.e('Error in listen in download.', error, StackTrace.current);
        state?.call(FileState.failed);
        await sink.close();
        client.close();
        sw.stop();
        return;
      }
      await sink.close();
      client.close();
      sw.stop();
      if (response.contentLength > 0) progress?.call(downloaded / response.contentLength);
      if (response.contentLength > 0) speedInMBPS?.call(0);
      // skyleLogger?.d('Finished download, downloading ${downloaded / 1000000} MB');
      state?.call(FileState.downloaded);
    } catch (error) {
      // skyleLogger?.e('Error in download.', error, StackTrace.current);
      state?.call(FileState.failed);
    }
  }

  static Future<void> upload({
    required String url,
    required String path,
    String? data,
    void Function(FileState)? state,
    void Function(double)? progress,
  }) async {
    try {
      state?.call(FileState.uploading);
      final bytes = await File(path).readAsBytes();
      final request = MultipartRequest('POST', Uri.parse(url), onProgress: (cumulative, total) {
        progress?.call(cumulative / total);
        if (cumulative / total == 1.0) state?.call(FileState.uploaded);
      });
      request.headers['Content-Type'] = 'application/octet-stream';
      request.files.add(
        http.MultipartFile.fromBytes(
          'zipfile',
          bytes,
          filename: 'sample.zip',
          contentType: MediaType('application', 'octet-stream'),
        ),
      );
      if (data != null) {
        request.fields['json'] = data;
      }
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        // skyleLogger?.i(responseString);
        // skyleLogger?.i('Uploading file: Response Status Code 200.');
      } else {
        state?.call(FileState.failed);
        final responseString = await response.stream.bytesToString();
        // skyleLogger?.e(responseString);
        // skyleLogger?.e('Error code: ${response.statusCode}');
        throw Exception('Error code: ${response.statusCode}');
      }
    } catch (error) {
      // skyleLogger?.e('Error uploading a file: $path', error, StackTrace.current);
      state?.call(FileState.failed);
      rethrow;
    }
  }
}

class LoggableHttpClient extends http.BaseClient {
  final http.Client _delegate;

  LoggableHttpClient(this._delegate);

  @override
  void close() {
    _delegate.close();
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    String s = '${request.method} ${request.url} -->';
    s += '\nheader: ${request.headers}';
    if (request is http.Request && request.body.isNotEmpty) {
      s += '\nbody: ${request.body}';
    }
    // skyleLogger?.i(s);
    final response = await _delegate.send(request);
    s = '${request.method} ${request.url} <--';
    s += '\nheader: ${response.headers}';

    // Simple request
    if (request is http.Request) {
      final List<int> bytes = await response.stream.toBytes();
      s += '\nbody: ${utf8.decode(bytes)}';
      // skyleLogger?.i(s);

      return http.StreamedResponse(http.ByteStream.fromBytes(bytes), response.statusCode,
          contentLength: response.contentLength,
          request: request,
          headers: response.headers,
          isRedirect: response.isRedirect,
          persistentConnection: response.persistentConnection,
          reasonPhrase: response.reasonPhrase);
    }

    // skyleLogger?.i(s);

    return response;
  }
}
