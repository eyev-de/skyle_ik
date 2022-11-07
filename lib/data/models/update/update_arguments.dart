//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_arguments.freezed.dart';
part 'update_arguments.g.dart';

@freezed
class UpdateArguments with _$UpdateArguments {
  const factory UpdateArguments({
    required String version,
    required BigInt serial,
    bool? beta,
  }) = _UpdateArguments;

  factory UpdateArguments.fromJson(Map<String, Object?> json) => _$UpdateArgumentsFromJson(json);
}
