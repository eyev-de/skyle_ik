//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_request.freezed.dart';
part 'update_request.g.dart';

@freezed
class UpdateRequest with _$UpdateRequest {
  const factory UpdateRequest({
    required String version,
    required BigInt serial,
    required bool beta,
  }) = _UpdateRequest;

  factory UpdateRequest.fromJson(Map<String, Object?> json) => _$UpdateRequestFromJson(json);
}
