//  Skyle IK
//
//  Created by Konstantin Wachendorff on 07.09.2022.
//  Copyright © 2022 eyeV GmbH. All rights reserved.
//

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStoreNotifier<T> extends StateNotifier<T> {
  LocalStoreNotifier(
    this.sharedPreferences,
    this.sharedPreferencesKey,
    this.defaultValue, {
    T? initialValue,
  }) : super(initialValue ?? sharedPreferences.get(sharedPreferencesKey) as T? ?? defaultValue);

  SharedPreferences sharedPreferences;
  String sharedPreferencesKey;
  T defaultValue;

  Future<void> update(T value) async {
    if (value is String) {
      await sharedPreferences.setString(sharedPreferencesKey, value);
    } else if (value is bool) {
      await sharedPreferences.setBool(sharedPreferencesKey, value);
    } else if (value is int) {
      await sharedPreferences.setInt(sharedPreferencesKey, value);
    } else if (value is double) {
      await sharedPreferences.setDouble(sharedPreferencesKey, value);
    } else if (value is List<String>) {
      await sharedPreferences.setStringList(sharedPreferencesKey, value);
    } else if (value is Enum) {
      await sharedPreferences.setString(sharedPreferencesKey, EnumToString.convertToString(value));
    }
    state = value;
  }

  T get getState => state;

  // @override
  // set state(T value) {
  //   assert(false, "Don't use the setter for state. Instead use `await update(value)`.");
  //   Future(() async {
  //     await update(value);
  //   });
  // }
}
