//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_response.freezed.dart';
part 'update_response.g.dart';

@freezed
class UpdateResponse with _$UpdateResponse {
  const factory UpdateResponse({
    required bool newupdate,
    required String version,
    required String download,
  }) = _UpdateResponse;

  factory UpdateResponse.fromJson(Map<String, Object?> json) => _$UpdateResponseFromJson(json);
}
