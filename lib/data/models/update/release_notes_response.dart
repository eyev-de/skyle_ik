//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'release_notes_response.freezed.dart';
part 'release_notes_response.g.dart';

@freezed
class ReleaseNotesResponse with _$ReleaseNotesResponse {
  const factory ReleaseNotesResponse({
    required String notes,
    required String version,
  }) = _ReleaseNotesResponse;

  factory ReleaseNotesResponse.fromJson(Map<String, Object?> json) => _$ReleaseNotesResponseFromJson(json);
}
