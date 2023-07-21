/*
 * This file is part of hsas_h4o5f_app.
 * Copyright (c) 2023 HSAS H4o5F Team. All Rights Reserved.
 *
 * hsas_h4o5f_app is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * hsas_h4o5f_app is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * hsas_h4o5f_app. If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:hsas_h4o5f_app/preference/preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StringPreference extends Preference<String> {
  const StringPreference({
    required super.key,
    super.beforeSetValue,
    super.onValueChanged,
  });
}

extension StringPreferencesExtension on SharedPreferences {
  Future<bool> setStringPreference(
    StringPreference preference,
    String value,
  ) async {
    String finalValue = value;
    if (preference.beforeSetValue != null) {
      final hookResult = preference.beforeSetValue!(value);
      if (hookResult != null) {
        finalValue = hookResult;
      } else {
        return false;
      }
    }
    final result = await setString(preference.key, value);
    if (preference.onValueChanged != null && result) {
      preference.onValueChanged!(value);
    }
    return result;
  }

  String? getStringPreference(StringPreference preference) {
    return getString(preference.key);
  }
}
