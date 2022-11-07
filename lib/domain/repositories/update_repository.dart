//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:skyle_api/api.dart';

import '../../data/models/update/release_notes_response.dart';
import '../../data/models/update/update_response.dart';
import '../../data/models/update/update_state.dart';

abstract class UpdateRepository {
  Future<DataState<bool>> isBeta(
    BigInt serial, {
    String url,
  });

  Future<DataState<ReleaseNotesResponse>> getReleaseNotes(
    String version,
    BigInt serial, {
    String url,
  });

  Future<DataState<UpdateResponse>> tryCheckForUpdate(
    String version,
    BigInt serial, {
    bool beta,
    String url,
  });

  Stream<DataState<UpdateState>> tryDownloadUpdate(
    String version,
    BigInt serial, {
    String url,
    String directory,
    bool beta,
  });

  Stream<DataState<UpdateState>> tryUpdate({
    String url,
    String directory,
    String fileName,
  });
}
